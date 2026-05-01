// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

namespace KriptaCards.WebApi.Contracts.Players;

/// <summary>
/// Запрос на добавление пользователя
/// </summary>
/// <param name="Name">Имя нового пользователя</param>
/// <param name="Comment">Комментарий для пользователя</param>
public sealed record PlayerRequest(
    string Name,
    string? Comment = null);
