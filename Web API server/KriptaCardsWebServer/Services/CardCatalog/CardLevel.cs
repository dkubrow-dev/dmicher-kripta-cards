// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

namespace KriptaCards.WebApi.Services.CardCatalog;

/// <summary>
/// Определение уровня карточек
/// </summary>
/// <param name="Id">Номер уровня</param>
/// <param name="Name">Название уровня</param>
/// <param name="Description">Описание уровня</param>
public sealed record CardLevel(
    int Id,
    string Name,
    string Description);
