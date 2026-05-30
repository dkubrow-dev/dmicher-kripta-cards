// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using System.Security.Cryptography;
using System.Text.RegularExpressions;

namespace KriptaCards.WebApi.Services.Players;

/// <summary>
/// Общие правила для логинов и пин-кодов игроков сервера
/// </summary>
public static partial class PlayerCredentials
{
    /// <summary>
    /// Длина пин-кода
    /// </summary>
    public const int PinLength = 5;

    /// <summary>
    /// Максимальная длина логина
    /// </summary>
    public const int LoginMaxLength = 250;

    /// <summary>
    /// Сгенерировать пятизначный пин-код
    /// </summary>
    public static string GeneratePin()
    {
        return RandomNumberGenerator.GetInt32(1, 100_000).ToString("D5");
    }

    /// <summary>
    /// Сгенерировать короткий логин игрока
    /// </summary>
    public static string GenerateLogin()
    {
        int suffix = RandomNumberGenerator.GetInt32(0, 1_000_000);
        return $"player-{suffix:D6}";
    }

    /// <summary>
    /// Проверить пин-код
    /// </summary>
    public static bool IsValidPin(string? pin)
    {
        string value = NormalizePin(pin);
        return PinRegex().IsMatch(value) && value != "00000";
    }

    /// <summary>
    /// Нормализовать пин-код
    /// </summary>
    public static string NormalizePin(string? pin)
    {
        return Value(pin).Trim();
    }

    /// <summary>
    /// Нормализовать логин
    /// </summary>
    public static string NormalizeLogin(string? login)
    {
        return Value(login).Trim();
    }

    /// <summary>
    /// Проверить логин
    /// </summary>
    public static bool IsValidLogin(string? login)
    {
        string value = NormalizeLogin(login);
        return value.Length is > 0 and <= LoginMaxLength;
    }

    private static string Value(string? value) => value ?? string.Empty;

    [GeneratedRegex("^\\d{5}$")]
    private static partial Regex PinRegex();
}
