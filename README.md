# Карточки Крипты / Kripta Cards

**Актуальная версия публикации: 1.1.2.**

**Карточки Крипты** - модульная система для Foundry VTT: отдельный Web API сервер хранит каталог карточек, изображения, игроков и выданные карточки, а модуль Foundry VTT предоставляет игровой интерфейс для каталога, запросов, выдачи, списания и использования карточек.

## Состав

- `Foundry module/dmicher-kripta-cards` - модуль Foundry VTT версии `1.1.2`.
- `Web API server/KriptaCardsWebServer` - сервер контента версии `1.1.2`.
- `Content sets` - локальные комплекты карточек и дополнительных локализаций, не входящие в git-индекс.
- `.sources` - исходники документации и рабочие материалы, не входящие в релиз.
- `release/1.1.2` - готовая папка публикации.

## Документация

Готовая пользовательская документация входит в модуль:

- `Foundry module/dmicher-kripta-cards/assets/docs/setup-guide.pdf` - настройка модуля и сервера.
- `Foundry module/dmicher-kripta-cards/assets/docs/content-creation-guide.pdf` - создание карточек и локализаций.

Эти же PDF доступны пользователю из окна настроек модуля. Исходные Word-файлы лежат в `.sources` и в релиз не попадают.

## Что входит в выпуск 1.1.2

- модуль Foundry VTT с локализациями `ru` и `en`;
- PDF-документация внутри модуля;
- универсальные `add-locale.bat` и `add-locale.sh` для установки пользовательских локализаций интерфейса;
- сервер контента с тестовым набором карточек;
- ZIP-комплекты карточек `dmicher-cards-ru`, `dmicher-cards-en`, `kripta-cards-ru`, `kripta-cards-en`;
- ZIP-комплекты пользовательских локализаций интерфейса.

## Установка

Подробный порядок установки описан в `setup-guide.pdf`.

Коротко:

1. Установите модуль Foundry VTT.
2. Скачайте сервер контента версии `1.1.2`.
3. Настройте `appsettings.json`: CORS, адрес сервера, технических пользователей `Reader` и `Writer`.
4. Запустите сервер.
5. В настройках модуля укажите адрес сервера и ключи технических пользователей.

Для установки через манифест:

```text
https://raw.githubusercontent.com/dkubrow-dev/dmicher-kripta-cards/main/Foundry%20module/dmicher-kripta-cards/module.json
```

## Контент

Сервер читает карточки из:

```text
Content/CardsReg.json
Content/Cards/
```

Если карточка содержит `ImagePath`, сервер ищет общее изображение в `Content/Cards/Common/{ImagePath}.*`. Если `ImagePath` не задан, сервер ищет изображение карточки в `Content/Cards/{Level}/{Number}.*`.

Создание своих комплектов карточек и локализаций описано в `content-creation-guide.pdf`.

## Локализация

В модуле встроены русская и английская локализации интерфейса. Дополнительные локализации устанавливаются через папку `add_custom_lang` и скрипты `add-locale.bat` / `add-locale.sh`, которые входят в модуль.

Контент карточек не переводится программно: названия категорий, названия карточек и описания находятся в конкретном контентном наборе.

## Лицензия

Проект распространяется под лицензией Apache License 2.0.

- Автор оригинального проекта: dmicher abathur kubrow.
- Оригинальный проект: https://github.com/dkubrow-dev/kripta-cards

# English

**Current release version: 1.1.2.**

**Kripta Cards** is a modular Foundry VTT system: a separate Web API server stores the card catalog, images, players, and issued cards, while the Foundry VTT module provides the in-game interface for browsing, requesting, giving, taking, and using cards.

## Parts

- `Foundry module/dmicher-kripta-cards` - Foundry VTT module version `1.1.2`.
- `Web API server/KriptaCardsWebServer` - content server version `1.1.2`.
- `Content sets` - local card and localization packages, not tracked by git.
- `.sources` - documentation sources and working materials, not included in the release.
- `release/1.1.2` - prepared release folder.

## Documentation

User documentation is bundled with the module:

- `Foundry module/dmicher-kripta-cards/assets/docs/setup-guide.pdf` - module and server setup.
- `Foundry module/dmicher-kripta-cards/assets/docs/content-creation-guide.pdf` - creating cards and localizations.

The same PDFs are available from the module settings window. Word source files stay in `.sources` and are not part of the release.

## Release 1.1.2 Includes

- Foundry VTT module with built-in `ru` and `en` localizations;
- PDF documentation inside the module;
- universal `add-locale.bat` and `add-locale.sh` scripts for installing custom interface localizations;
- content server with test card data;
- card package ZIP files: `dmicher-cards-ru`, `dmicher-cards-en`, `kripta-cards-ru`, `kripta-cards-en`;
- custom interface localization ZIP files.

## Installation

The full installation workflow is described in `setup-guide.pdf`.

In short:

1. Install the Foundry VTT module.
2. Download the matching content server version `1.1.2`.
3. Configure `appsettings.json`: CORS, server address, and `Reader` / `Writer` technical users.
4. Start the server.
5. Enter the server address and technical user credentials in the module settings.

Manifest URL:

```text
https://raw.githubusercontent.com/dkubrow-dev/dmicher-kripta-cards/main/Foundry%20module/dmicher-kripta-cards/module.json
```

## Content

The server reads card content from:

```text
Content/CardsReg.json
Content/Cards/
```

If a card has `ImagePath`, the server looks for a shared image in `Content/Cards/Common/{ImagePath}.*`. If `ImagePath` is not set, it looks for the card image in `Content/Cards/{Level}/{Number}.*`.

Creating custom card sets and localization packages is described in `content-creation-guide.pdf`.

## Localization

The module includes Russian and English interface localizations. Additional localizations are installed through the `add_custom_lang` folder and the bundled `add-locale.bat` / `add-locale.sh` scripts.

Card content is not translated by the module: category names, card names, and descriptions belong to the selected content package.

## License

Licensed under the Apache License 2.0.

- Original author: dmicher abathur kubrow.
- Original project: https://github.com/dkubrow-dev/kripta-cards
