// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

namespace KriptaCards.WebApi.Contracts.Cards;

/// <summary>
/// Запрос на получение данных о списке карточек
/// </summary>
/// <param name="LevelConstraint">Ограничение на уровнь карточки</param>
/// <param name="NameConstraint">Ограничение на имя карточки</param>
public sealed record GetCardsListRequest(int? LevelConstraint, string? NameConstraint);