// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

namespace KriptaCards.WebApi.Contracts.Players;

/// <summary>
/// Запрос изменения пин-кода игрока сервера
/// </summary>
/// <param name="Pin">Новый пятизначный пин-код</param>
public sealed record PlayerPinRequest(string Pin);
