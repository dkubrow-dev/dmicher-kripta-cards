// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using KriptaCards.WebApi.Contracts.Cards;
using KriptaCards.WebApi.Domain.Users;
using KriptaCards.WebApi.Middleware.Auth;
using KriptaCards.WebApi.Services.CardCatalog;
using KriptaCards.WebApi.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.StaticFiles;

namespace KriptaCards.WebApi.Controllers;

/// <summary>
/// Выдаёт информацию по карточкам. 
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class CardsController(ICardCatalogService cardsService, ILogger<CardsController> logger) : Controller
{
    /// <summary>
    /// Сервис карточек
    /// </summary>
    private readonly ICardCatalogService _cardsService = cardsService;

    /// <summary>
    /// Логгер
    /// </summary>
    private readonly ILogger<CardsController> _logger = logger;

    /// <summary>
    /// (Reader) Возвращает список уровней карточек
    /// </summary>
    /// <returns>Список уровней</returns>
    [HttpGet("getLevelsList")]
    [Base64Authorize(UserRoles.Reader, UserRoles.Writer)]
    [ProducesResponseType<List<CardLevel>>(StatusCodes.Status200OK)]
    [ProducesResponseType<UnauthorizedObjectResult>(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType<ObjectResult>(StatusCodes.Status403Forbidden)]
    public ActionResult<List<CardLevel>> GetLevelsList()
    {
        List<CardLevel> cardsList = _cardsService.Levels;
        _logger.LogInformation($"Action \"getLevelsList\" results in count: {cardsList.Count}.");
        return cardsList;
    }

    /// <summary>
    /// (Reader) Возвращает список карточек на основе переданных ограничений
    /// </summary>
    /// <param name="requestConstraints">Ограничения запроса</param>
    /// <returns>Список карточек</returns>
    [HttpPost("getCardsList")]
    [Base64Authorize(UserRoles.Reader, UserRoles.Writer)]
    [ProducesResponseType<List<CardResponseRow>>(StatusCodes.Status200OK)]
    [ProducesResponseType<UnauthorizedObjectResult>(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType<ObjectResult>(StatusCodes.Status403Forbidden)]
    public ActionResult<List<CardResponseRow>> GetCardsList([FromBody] GetCardsListRequest requestConstraints)
    {
        IEnumerable<Card> cards = _cardsService.Cards;

        if (requestConstraints.LevelConstraint != null && requestConstraints.LevelConstraint >= 0)
        {
            cards = cards.Where(x => x.Level == requestConstraints.LevelConstraint.Value);
        }

        if (!string.IsNullOrWhiteSpace(requestConstraints.NameConstraint))
        {
            string nameConstraint = requestConstraints.NameConstraint.ToUpper().Trim();
            cards = cards.Where(x => x.Name.ToUpper().Trim().Contains(nameConstraint));
        }

        List<CardResponseRow> responseInfo = [.. cards
            .Select(x => new CardResponseRow
            {
                Level = x.Level,
                Number = x.Number,
                Name = x.Name
            })];

        _logger.LogInformation($"Action \"getCardsList\" results in count: {responseInfo.Count}.");
        return responseInfo;
    }

    /// <summary>
    /// (Reader) Выдаёт метаинформацию по идентификатору уровня и карточки
    /// </summary>
    /// <param name="level">Уровень карточки</param>
    /// <param name="card">Номер карточки</param>
    /// <returns>Метаинформация по карточке</returns>
    [HttpGet("getCardMeta/{level:int}/{card:int}")]
    [Base64Authorize(UserRoles.Reader, UserRoles.Writer)]
    [ProducesResponseType<Card>(StatusCodes.Status200OK)]
    [ProducesResponseType<UnauthorizedObjectResult>(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType<ObjectResult>(StatusCodes.Status403Forbidden)]
    [ProducesResponseType<NotFoundObjectResult>(StatusCodes.Status404NotFound)]
    public ActionResult<Card> GetCardById(int level, int card)
    {
        Card? result = _cardsService.GetCardById(level, card);
        if (result == null)
        {
            return NotFound("Card is not registered.");
        }

        _logger.LogInformation($"Action \"getCardMeta\" results in card: {result.Name} (l:{result.Level} c:{result.Number}).");
        return Ok(result);
    }

    /// <summary>
    /// (Reader) Возвращает изображение карточки по идентификатору
    /// </summary>
    /// <param name="level">Уровень карточки</param>
    /// <param name="card">Номер карточки в уровне</param>
    /// <returns>Файл изображения карточки</returns>
    [HttpGet("getCardImage/{level:int}/{card:int}")]
    [Base64Authorize(UserRoles.Reader, UserRoles.Writer)]
    [ProducesResponseType<FileStreamResult>(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status304NotModified)]
    [ProducesResponseType<UnauthorizedObjectResult>(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType<BadRequestObjectResult>(StatusCodes.Status400BadRequest)]
    [ProducesResponseType<ObjectResult>(StatusCodes.Status403Forbidden)]
    [ProducesResponseType<NotFoundObjectResult>(StatusCodes.Status404NotFound)]
    [ProducesResponseType<ObjectResult>(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetCardImage(int level, int card)
    {
        if (level < 0 || card < 0)
        {
            _logger.LogInformation($"No level or card id is in request l:{level}, c:{card}");
            return BadRequest("No level or card id is in request.");
        }

        Card? cardMeta = _cardsService.GetCardById(level, card);
        if (cardMeta == null)
        {
            _logger.LogInformation($"Card is not registered l:{level}, c:{card}");
            return NotFound("Card is not registered.");
        }

        try
        {
            string imagePath = _cardsService.ImagePathById(cardMeta);

            FileInfo fileInfo = new FileInfo(imagePath);
            DateTimeOffset fileLastModified = fileInfo.LastWriteTimeUtc;
            long length = fileInfo.Length;
            string eTag = $"\"{fileLastModified.ToUnixTimeSeconds()}-{length}\"";

            if (Request.Headers.IfNoneMatch == eTag)
            {
                return StatusCode(StatusCodes.Status304NotModified);
            }

            if (Request.Headers.IfModifiedSince.Count > 0
                && DateTimeOffset.TryParse(Request.Headers.IfModifiedSince, out var requestModifiedTime)
                && fileLastModified <= requestModifiedTime)
            {
                return StatusCode(StatusCodes.Status304NotModified);
            }

            Response.Headers.ETag = eTag;
            Response.Headers.LastModified = fileLastModified.ToString("R");
            Response.Headers.CacheControl = "public,max-age=86400";

            FileExtensionContentTypeProvider contentTypeProvider = new();
            if (!contentTypeProvider.TryGetContentType(imagePath, out string? contentType))
            {
                contentType = "application/octet-stream";
            }

            return File(System.IO.File.OpenRead(imagePath), contentType);
        }
        catch (FileNotFoundException ex)
        {
            string message = $"Card not found for level:{level} id:{card}. ";
            _logger.LogError(message, ex);
            return NotFound(message);
        }
        catch (IOException ex)
        {
            string message = $"IO Exception:{level} id:{card}. ";
            _logger.LogError(message, ex);
            return BadRequest(message + ex.Message);
        }
        catch (Exception ex)
        {
            string message = $"Inner exception:{level} id:{card}. ";
            _logger.LogError(message, ex);
            return Problem(message + ex.Message);
        }
    }
}
