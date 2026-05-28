# Карточки Крипты

**Версия модуля: 1.1.2.**

**Карточки Крипты** - модуль Foundry VTT для работы с игровыми карточками, которые хранятся на отдельном сервере **Kripta Cards Web API Server**.

## Требования

- Foundry VTT: `13+`.
- Проверенная совместимость: `14`.
- Настроенный **Kripta Cards Web API Server** версии `1.1.2`.

Модуль не является самостоятельным хранилищем карточек. Он работает как интерфейс к серверу контента.

## Документация

В модуль встроены два PDF-файла:

- `assets/docs/setup-guide.pdf` - установка и настройка модуля, сервера и пользовательских комплектов;
- `assets/docs/content-creation-guide.pdf` - создание наборов карточек и локализаций интерфейса.

Ссылки на эти документы находятся в окне настроек модуля.

## Установка

Для установки через Foundry VTT используйте URL манифеста:

```text
https://raw.githubusercontent.com/dkubrow-dev/dmicher-kripta-cards/main/Foundry%20module/dmicher-kripta-cards/module.json
```

Для ручной установки распакуйте архив модуля в папку модулей Foundry VTT так, чтобы `module.json` находился в корне папки `dmicher-kripta-cards`.

## Настройка

После включения модуля в мире Foundry VTT откройте:

```text
Настройки игры -> Настройки модулей -> Карточки Крипты
```

Укажите:

- адрес сервера;
- ID и ключ технического пользователя `Reader`;
- ID и ключ технического пользователя `Writer`.

Язык интерфейса берётся из настроек Foundry VTT. Встроены локализации `ru` и `en`.

## Дополнительные локализации

Пользовательская локализация устанавливается как папка `add_custom_lang` в корне модуля. В ней должны быть:

- `manifest.json`;
- `lang.json`.

Для установки используйте один из скриптов, которые распространяются вместе с модулем:

- `add-locale.bat` для Windows;
- `add-locale.sh` для Linux.

Подробности описаны в `assets/docs/content-creation-guide.pdf`.

## Основные окна

### Каталог карточек

Показывает все карточки, зарегистрированные на сервере.

Доступно:

- выбор категории;
- поиск карточки внутри категории;
- режимы отображения `Таблица` и `Плитки`;
- вывод карточки в чат;
- открытие подробной информации;
- выдача карточки игроку мастером или ассистентом мастера.

### Карточки игрока

Показывает карточки выбранного игрока.

Доступно:

- просмотр карточек в режиме таблицы и плиток;
- открытие подробной информации;
- использование карточки;
- списание карточки мастером или ассистентом мастера;
- запрос новой карточки.

В плитках и таблице используются одинаковые действия карточки. Описания карточек проходят HTML-санитаризацию.

### Получить карточку

Позволяет игроку запросить случайную или выбранную карточку у мастера.

### Управление игроками

Окно мастера для привязки пользователей Foundry VTT к игрокам сервера, просмотра карточек игроков и выдачи карточек.

### Реестр игроков

Окно мастера для создания, изменения и удаления игроков сервера.

## Изображения карточек

Сервер возвращает в JSON карточки поле `ImagePath`. Модуль использует это значение для загрузки изображения:

```text
/api/Cards/getCardImage/{imagePath}
```

Модуль не переводит контент карточек программно: названия категорий, названия карточек и описания берутся из выбранного контентного набора.

## Лицензия

Модуль распространяется под лицензией Apache License 2.0.

Оригинальный проект: https://github.com/dkubrow-dev/kripta-cards

# English

**Module version: 1.1.2.**

**Kripta Cards** is a Foundry VTT module for game cards stored on a separate **Kripta Cards Web API Server**.

## Requirements

- Foundry VTT: `13+`.
- Verified compatibility: `14`.
- Configured **Kripta Cards Web API Server** version `1.1.2`.

The module is not a standalone card storage. It is the Foundry interface for the content server.

## Documentation

The module includes two PDF files:

- `assets/docs/setup-guide.pdf` - installing and configuring the module, server, and user packages;
- `assets/docs/content-creation-guide.pdf` - creating card sets and interface localizations.

Links to these documents are shown in the module settings window.

## Installation

Manifest URL:

```text
https://raw.githubusercontent.com/dkubrow-dev/dmicher-kripta-cards/main/Foundry%20module/dmicher-kripta-cards/module.json
```

For manual installation, extract the module archive into the Foundry VTT modules folder so that `module.json` is in the root of the `dmicher-kripta-cards` folder.

## Setup

After enabling the module in a Foundry VTT world, open:

```text
Configure Settings -> Module Settings -> Kripta Cards
```

Enter:

- server address;
- `Reader` technical user ID and key;
- `Writer` technical user ID and key.

The interface language is taken from Foundry VTT settings. Built-in localizations are `ru` and `en`.

## Custom Localizations

A custom localization is installed as an `add_custom_lang` folder in the module root. It must contain:

- `manifest.json`;
- `lang.json`.

Use one of the bundled scripts:

- `add-locale.bat` for Windows;
- `add-locale.sh` for Linux.

Details are in `assets/docs/content-creation-guide.pdf`.

## Main Windows

### Card Catalog

Shows all cards registered on the server.

Available actions:

- choose a category;
- search cards within a category;
- switch between `Table` and `Tiles`;
- output a card to chat;
- open detailed information;
- give a card to a player as Game Master or Assistant Game Master.

### Player Cards

Shows cards owned by the selected player.

Available actions:

- view cards as table or tiles;
- open detailed information;
- use a card;
- take a card as Game Master or Assistant Game Master;
- request a new card.

Tiles and table rows expose the same card actions. Card descriptions are sanitized before rendering.

### Request Card

Lets a player request a random or selected card from the Game Master.

### Manage Players

Game Master window for binding Foundry VTT users to server players, viewing player cards, and giving cards.

### Player Registry

Game Master window for creating, editing, and deleting server players.

## Card Images

The server returns `ImagePath` in card JSON. The module uses it to load an image:

```text
/api/Cards/getCardImage/{imagePath}
```

The module does not translate card content programmatically: category names, card names, and descriptions come from the selected content package.

## License

Licensed under the Apache License 2.0.

Original project: https://github.com/dkubrow-dev/kripta-cards
