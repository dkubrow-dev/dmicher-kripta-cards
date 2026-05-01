// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

namespace KriptaCards.WebApi.Services.CardCatalog;

/// <summary>
/// Реестр зарегистрированных карт Крипты (собираемый из файла контента)
/// </summary>
public class CardsRegistry
{
    /// <summary>
    /// Список зарегистрированных уровней карточек
    /// </summary>
    public List<CardLevel>? Levels { get; set; }

    /// <summary>
    /// Список всех зарегистрированных карточек
    /// </summary>
    public List<Card>? Cards { get; set; }
}
