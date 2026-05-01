// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using KriptaCards.WebApi.Domain.Users;
using KriptaCards.WebApi.Middleware.Auth;
using KriptaCards.WebApi.Services.Interfaces;
using KriptaCards.WebApi.Domain.Players;

using Microsoft.AspNetCore.Mvc;
using KriptaCards.WebApi.Contracts.Players;
using KriptaCards.WebApi.Services.CardCatalog;

namespace KriptaCards.WebApi.Controllers;

/// <summary>
/// Управляет игроками
/// </summary>
/// <param name="playersService">Сервис управления игроками</param>
/// <param name="logger">Общий логгер</param>
[ApiController]
[Route("api/[controller]")]
public class PlayersCardsController(IPlayersCardsService playersService, ILogger<PlayersCardsController> logger) : Controller
{
    /// <summary>
    /// Сервис управления игроками и их карточками
    /// </summary>
    private readonly IPlayersCardsService _players = playersService;

    /// <summary>
    /// Логгер контроллера
    /// </summary>
    private readonly ILogger<PlayersCardsController> _logger = logger;

    /// <summary>
    /// (Writer) Возвращает список всех зарегистрированных игроков
    /// </summary>
    [HttpGet("getPlayersList")]
    [Base64Authorize(UserRoles.Writer)]
    [ProducesResponseType<List<PlayerGridRowDto>>(StatusCodes.Status200OK)]
    public ActionResult<List<PlayerGridRowDto>> GetPlayersList()
    {
        List<PlayerGridRowDto> playerDtos = _players.GetPlayersList;
        _logger.LogInformation($"Action \"{nameof(GetPlayersList)}\" results in count: {playerDtos.Count}.");
        return Ok(playerDtos);
    }

    /// <summary>
    /// (Reader) Возвращает подробную информацию об игроках по указанным идентификаторам
    /// </summary>
    /// <param name="players">Идентификаторы игроков для выдачи подробной информации</param>
    /// <returns>Список данных по игрокам и их карточкам</returns>
    [HttpPost("getPlayersInfo")]
    [Base64Authorize(UserRoles.Reader, UserRoles.Writer)]
    [ProducesResponseType<List<PlayerDto>>(StatusCodes.Status200OK)]
    [ProducesResponseType<UnauthorizedObjectResult>(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType<ObjectResult>(StatusCodes.Status403Forbidden)]
    public async Task<ActionResult<List<PlayerDto>>> GetPlayersInfo([FromBody] List<Guid> players)
    {
        PlayerDto?[] playerDtosRaw = await Task.WhenAll(players.Select(async playerGuid =>
        {
            PlayerEntity? playerEntity = await _players.GetPlayerByIdAsync(playerGuid);
            if (playerEntity == null)
            {
                return null;
            }

            return new PlayerDto
            {
                Guid = playerEntity.Id.ToString(),
                Name = playerEntity.Name,
                Comments = playerEntity.Comments,
                CardDtos = [.. playerEntity.Cards
                    .Select(cardEntity => new PlayersCardDto
                    {
                        Guid = cardEntity.Id.ToString(),
                        Level = cardEntity.Level,
                        Number = cardEntity.Number,
                        Count = cardEntity.Count,
                        OwnerGuid = cardEntity.PlayerId.ToString()
                    })]
            };
        }));

        List<PlayerDto> playerDtos = [.. playerDtosRaw
            .Where(x => x is not null)
            .Select(x => x!)];

        _logger.LogInformation($"Action \"{nameof(GetPlayersInfo)}\" results in count: {playerDtos.Count}.");
        return Ok(playerDtos);
    }

    /// <summary>
    /// (Writer) Добавляет игрока в сервис
    /// </summary>
    /// <param name="newPlayer">Информация о новом игроке</param>
    [HttpPost("addPlayer")]
    [Base64Authorize(UserRoles.Writer)]
    [ProducesResponseType<PlayerDto>(StatusCodes.Status200OK)]
    [ProducesResponseType<UnauthorizedObjectResult>(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType<ObjectResult>(StatusCodes.Status403Forbidden)]
    [ProducesResponseType<BadRequestObjectResult>(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<PlayerDto>> AddPlayer([FromBody] PlayerRequest newPlayer)
    {
        try
        {
            PlayerEntity playerEntity = await _players.AddPlayerAsync(newPlayer.Name, newPlayer.Comment);
            PlayerDto playerDto = new()
            { 
                Guid = playerEntity.Id.ToString(),
                Name = playerEntity.Name,
                Comments = playerEntity.Comments,
                CardDtos = [.. playerEntity.Cards.Select(cardEntity =>
                {
                    return new PlayersCardDto
                    {
                        Guid = cardEntity.Id.ToString(),
                        Level = cardEntity.Level,
                        Number = cardEntity.Number,
                        OwnerGuid = cardEntity.PlayerId.ToString(),
                        Count = cardEntity.Count,
                    };
                })]
            };

            _logger.LogWarning($"User created. Guid: {playerDto.Guid}, Name: {playerDto.Name}.");
            return Ok(playerDto);
        }
        catch (Exception ex)
        {
            string message = "Internal server exception. ";
            _logger.LogError(message, ex);
            return BadRequest(ex.Message);
        }
    }

    /// <summary>
    /// (Writer) Обновляет информацию игрока в сервисе
    /// </summary>
    /// <param name="playerGuid">Идентификатор игрока для обновления</param>
    /// <param name="newPlayer">Новая информация об игроке</param>
    [HttpPost("updatePlayer")]
    [Base64Authorize(UserRoles.Writer)]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType<UnauthorizedObjectResult>(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType<ObjectResult>(StatusCodes.Status403Forbidden)]
    [ProducesResponseType<BadRequestObjectResult>(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult> UpdatePlayer(Guid playerGuid, [FromBody] PlayerRequest newPlayer)
    {
        try
        {
            await _players.UpdatePlayerAsync(playerGuid, newPlayer.Name, newPlayer.Comment);
            _logger.LogWarning($"User updated. Guid: {playerGuid}, new-name: {newPlayer.Name}, new-comment: {newPlayer.Comment}.");
            return Ok();
        }
        catch (Exception ex)
        {
            string message = "Internal server exception. ";
            _logger.LogError(message, ex);
            return BadRequest(ex.Message);
        }
    }

    /// <summary>
    /// (Writer) Удаляет игрока из сервиса вместе со списком его карточек
    /// </summary>
    /// <remarks>Внимание! Действие необратимо</remarks>
    /// <param name="playerId">Идентификатор игрока</param>
    [HttpDelete("deletePlayer")]
    [Base64Authorize(UserRoles.Writer)]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType<UnauthorizedObjectResult>(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType<ObjectResult>(StatusCodes.Status403Forbidden)]
    [ProducesResponseType<BadRequestObjectResult>(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult> DeletePlayer(Guid playerId)
    {
        try
        {
            await _players.DeletePlayerByGuidAsync(playerId);
            _logger.LogWarning($"User deleted. Guid: {playerId}.");
            return Ok();
        }
        catch (Exception ex)
        {
            string message = "Internal server exception. ";
            _logger.LogError(message, ex);
            return BadRequest(ex.Message);
        }
    }

    /// <summary>
    /// (Reader) Из указанного уровня карточек случайно выбирает одну и возвращает её метаданные
    /// </summary>
    /// <param name="level">Уровень карточек для выбора</param>
    /// <returns>Метаданные карточки</returns>
    [HttpPost("rollCard")]
    [Base64Authorize(UserRoles.Reader, UserRoles.Writer)]
    [ProducesResponseType<CardRandomRollResults>(StatusCodes.Status200OK)]
    [ProducesResponseType<BadRequestObjectResult>(StatusCodes.Status400BadRequest)]
    [ProducesResponseType<UnauthorizedObjectResult>(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType<NotFoundObjectResult>(StatusCodes.Status404NotFound)]
    public ActionResult<CardRandomRollResults> RollRandomCard(int level)
    {
        try
        {
            RollCardResult rollResult = _players.RollRandomCard(level);
            CardRandomRollResults result = new()
            {
                RequestedCardLevel = level,
                TotalCardsCountInLevel = rollResult.TotalCardsCountInLevel,
                RolledCard = new()
                {
                    Guid = null,
                    Level = rollResult.RolledCard?.Level,
                    Number = rollResult.RolledCard?.Number,
                    OwnerGuid = null,
                    Count = 1
                }
            };

            _logger.LogInformation($"Action \"getPlayerCards\" results in card name: {rollResult.RolledCard?.Name} (l:{result.RolledCard.Level} n:{result.RolledCard.Number}).");
            return Ok(result);
        }
        catch (ArgumentException ex)
        {
            string message = "Object not found. ";
            _logger.LogError(message, ex);
            return NotFound(ex.Message);
        }
        catch (Exception ex)
        {
            string message = "Internal server exception. ";
            _logger.LogError(message, ex);
            return BadRequest(ex.Message);
        }
    }

    /// <summary>
    /// (Writer) Указанному игроку выдаёт указанную карту
    /// </summary>
    /// <param name="player">Идентификатор игрока</param>
    /// <param name="level">Уровень карточки</param>
    /// <param name="card">Номер карты в уровне</param>
    /// <param name="count">Количество карт этого типа для выдачи</param>
    [HttpPost("giveCard")]
    [Base64Authorize(UserRoles.Writer)]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType<UnauthorizedObjectResult>(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType<ObjectResult>(StatusCodes.Status403Forbidden)]
    [ProducesResponseType<NotFoundObjectResult>(StatusCodes.Status404NotFound)]
    [ProducesResponseType<BadRequestObjectResult>(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult> GiveCardToPlayer(Guid player, int level, int card, int? count = 1)
    {
        try
        {
            await _players.GiveCardToPlayer(player, level, card, (count ?? 1));
            _logger.LogWarning($"Player {player} gets card l:{level} n:{card} with count {count}.");
            return Ok();
        }
        catch (ArgumentException ex)
        {
            string message = "Object not found. ";
            _logger.LogError(message, ex);
            return NotFound(ex.Message);
        }
        catch (Exception ex)
        {
            string message = "Internal server exception. ";
            _logger.LogError(message, ex);
            return BadRequest(ex.Message);
        }
    }

    /// <summary>
    /// (Writer) Забирает у указанного игрока указанную карту
    /// </summary>
    /// <param name="player">Идентификатор игрока</param>
    /// <param name="level">Уровень карточки</param>
    /// <param name="card">Номер карты в уровне</param>
    /// <param name="count">Количество карт этого типа для отъёма</param>
    [HttpPost("takeCard")]
    [Base64Authorize(UserRoles.Writer)]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType<UnauthorizedObjectResult>(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType<ObjectResult>(StatusCodes.Status403Forbidden)]
    [ProducesResponseType<NotFoundObjectResult>(StatusCodes.Status404NotFound)]
    [ProducesResponseType<BadRequestObjectResult>(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult> TakeCardFromPlayer(Guid player, int level, int card, int? count = 1)
    {
        try
        {
            await _players.TakeCardFromPlayer(player, level, card, (count ?? 1));
            _logger.LogWarning($"Player {player} lost his card l:{level} n:{card} with count {count}.");
            return Ok();
        }
        catch (ArgumentException ex)
        {
            string message = "Object not found. ";
            _logger.LogError(message, ex);
            return NotFound(ex.Message);
        }
        catch (Exception ex)
        {
            string message = "Internal server exception. ";
            _logger.LogError(message, ex);
            return BadRequest(ex.Message);
        }
    }
}
