// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using KriptaCards.WebApi.Services.CardCatalog;

namespace KriptaCards.WebApi.Services.Interfaces;

/// <summary>
/// Интерфейс сервиса работы с карточками
/// </summary>
public interface ICardCatalogService
{
    /// <summary>
    /// Выдать перечисление всех уровней карточек (метаданные)
    /// </summary>
    public List<CardLevel> Levels { get; }

    /// <summary>
    /// Выдать перечисление всех карточек
    /// </summary>
    public List<Card> Cards { get; }

    /// <summary>
    /// Выдать метаданные одной карты по идентификатору уровня и карты
    /// </summary>
    /// <param name="levelId">Номер уровня</param>
    /// <param name="cardId">Номер карты в уровне</param>
    public Card? GetCardById(int levelId, int cardId);

    /// <summary>
    /// Получить информацию о файле по пути до него
    /// </summary>
    /// <param name="path">Путь до файла изображения (записан в карточке)</param>
    public FileInfo GetFile(string path);
}
