// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

namespace KriptaCards.WebApi.Services.CardCatalog;

/// <summary>
/// Карточка каталога
/// </summary>
/// <param name="Level">Номер уровня карточки</param>
/// <param name="Number">Номер карточки в уровне</param>
/// <param name="Name">Название карточки</param>
/// <param name="Description">Описание карточки</param>
public sealed record Card(
    int Level,
    int Number,
    string Name,
    string Description)
{
    /// <summary>
    /// Путь до изображения
    /// </summary>
    public string? ImagePath { get; set; }
}