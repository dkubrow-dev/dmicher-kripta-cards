// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using KriptaCards.WebApi.Domain.Players;
using Microsoft.EntityFrameworkCore;

namespace KriptaCards.WebApi.DataBases.Players;

/// <summary>
/// Контекст SQLite для хранения данных игроков Foundry
/// </summary>
public sealed class PlayersDbContext(DbContextOptions<PlayersDbContext> options) : DbContext(options)
{
    /// <summary>
    /// Набор игроков
    /// </summary>
    public DbSet<PlayerEntity> Players => Set<PlayerEntity>();

    /// <summary>
    /// Наборы карточек, выданных игрокам
    /// </summary>
    public DbSet<PlayersCardEntity> Cards => Set<PlayersCardEntity>();

    /// <summary>
    /// Сессионные ключи входа игроков на сервер
    /// </summary>
    public DbSet<PlayerSessionEntity> PlayerSessions => Set<PlayerSessionEntity>();

    /// <summary>
    /// Строит модель в базе даннхых
    /// </summary>
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<PlayerEntity>(entity =>
        {
            entity.ToTable("players");
            entity.HasKey(x => x.Id);

            entity.Property(x => x.Id)
                .ValueGeneratedNever();

            entity.Property(x => x.Name)
                .IsRequired()
                .HasMaxLength(250);

            entity.Property(x => x.Login)
                .IsRequired()
                .HasMaxLength(250);

            entity.Property(x => x.Pin)
                .IsRequired()
                .HasMaxLength(5);

            entity.Property(x => x.Comments)
                .HasMaxLength(10_000);

            entity.HasIndex(x => x.Login);
        });

        modelBuilder.Entity<PlayersCardEntity>(entity =>
        {
            entity.ToTable("cards");
            entity.HasKey(x => x.Id);

            entity.Property(x => x.Id)
                .ValueGeneratedNever();

            entity.Property(x => x.Level)
                .IsRequired();
            
            entity.Property(x => x.Number)
                .IsRequired();

            entity.Property(x => x.Count)
                .HasDefaultValue(1)
                .IsRequired();

            entity.HasIndex(x => new { x.PlayerId, x.Level, x.Number })
                .IsUnique();

            entity.HasOne(x => x.Owner)
                .WithMany(x => x.Cards)
                .HasForeignKey(x => x.PlayerId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<PlayerSessionEntity>(entity =>
        {
            entity.ToTable("player_sessions");
            entity.HasKey(x => x.Id);

            entity.Property(x => x.Id)
                .ValueGeneratedNever();

            entity.Property(x => x.PlayerId)
                .IsRequired();

            entity.Property(x => x.CreatedAtUtc)
                .IsRequired();

            entity.Property(x => x.ExpiresAtUtc)
                .IsRequired();

            entity.HasIndex(x => x.PlayerId);
            entity.HasIndex(x => x.ExpiresAtUtc);

            entity.HasOne(x => x.Owner)
                .WithMany(x => x.Sessions)
                .HasForeignKey(x => x.PlayerId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
