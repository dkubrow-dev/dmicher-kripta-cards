# Kripta Cards Web API Server

**Версия сервера: 1.1.2.**

**Kripta Cards Web API Server** - сервер контента для модуля **Карточки Крипты** в Foundry VTT.

Сервер хранит каталог карточек, изображения карточек, игроков и выданные игрокам карточки. Модуль Foundry VTT подключается к серверу по REST API и использует его как постоянное хранилище игрового процесса.

## Документация

Пользовательская документация входит в модуль Foundry VTT:

- `assets/docs/setup-guide.pdf` - установка и настройка сервера и модуля;
- `assets/docs/content-creation-guide.pdf` - создание карточек и локализаций.

## Состав опубликованной сборки

После публикации рядом с приложением находятся:

- `KriptaCardsWebServer.dll` - точка входа сервера для запуска через установленный .NET Runtime;
- `KriptaCardsWebServer.exe` - запуск сервера на Windows, если сборка опубликована с host executable;
- `appsettings.json` - настройки сервера;
- `nlog.config` - настройки логирования;
- `README.md` - этот файл, доступный также через `/readme`;
- `Content/CardsReg.json` - тестовый реестр карточек;
- `Content/Cards/` - изображения тестовых карточек;
- `Content/artifacts/docs/KriptaCardsWebServer.xml` - XML-документация для Swagger, если она была создана;
- `Content/SQLite/players.db` - база игроков и карточек, создаётся автоматически при первом запуске.

## Настройка

Основной файл настроек - `appsettings.json`.

В блоке `UserAuth` указываются технические пользователи:

```json
{
  "UserAuth": {
    "Users": [
      {
        "Id": "kripta-writer",
        "Key": "change-me-writer-key",
        "Role": "Writer"
      },
      {
        "Id": "kripta-reader",
        "Key": "change-me-reader-key",
        "Role": "Reader"
      }
    ]
  }
}
```

Роль `Reader` используется для чтения каталога, изображений и данных игроков. Роль `Writer` используется для изменения данных: выдачи карточек, списания карточек, создания и редактирования игроков.

В блоке `Cors:AllowedOrigins` указываются адреса Foundry VTT, которым разрешено обращаться к серверу из браузера.

В блоке `Kestrel:Endpoints` задаётся адрес, на котором сервер принимает HTTP-запросы.

## Контент карточек

Сервер читает контент из папки `Content`:

```text
Content/
  CardsReg.json
  Cards/
    0/
      1.png
    Common/
      shared-image.webp
```

`CardsReg.json` содержит массивы:

- `Levels` - категории или уровни карточек;
- `Cards` - карточки.

Карточка содержит:

- `Level` - ID категории;
- `Number` - номер карточки внутри категории;
- `Name` - название карточки;
- `Description` - описание карточки;
- `ImagePath` - необязательное имя общего изображения.

Если `ImagePath` не заполнен, сервер ищет изображение в папке уровня по номеру карточки: `Content/Cards/{Level}/{Number}.*`.

Если `ImagePath` заполнен, сервер ищет общее изображение в `Content/Cards/Common/{ImagePath}.*`.

После чтения реестра сервер записывает в объект карточки путь к найденному изображению. Модуль Foundry VTT запрашивает изображение через:

```text
/api/Cards/getCardImage/{imagePath}
```

Рекомендуемые форматы изображений для пользовательских комплектов: WebP, PNG и JPG.

## Запуск

Перед запуском проверьте:

- `appsettings.json` содержит актуальные ключи `Reader` и `Writer`;
- `Cors:AllowedOrigins` содержит адрес вашего Foundry VTT;
- `Content/CardsReg.json` существует;
- для каждой карточки есть ровно одно подходящее изображение;
- у сервера есть права на запись в `Content/SQLite`.

Запуск из консоли:

```powershell
dotnet KriptaCardsWebServer.dll
```

После запуска доступны:

- `/swagger` - Swagger UI;
- `/readme` - эта справка в HTML;
- `/api/Health/check` - проверка состояния сервера;
- `/api/Health/check-me` - проверка текущего авторизованного пользователя.

## API и безопасность

API защищено Basic Authentication. В Foundry VTT нужно указать те же ID и ключи технических пользователей, которые заданы в `appsettings.json`.

Сервер не локализует контент карточек. Названия категорий, названия карточек и описания карточек возвращаются такими, как они записаны в `CardsReg.json`.

## Лицензия

Сервер распространяется под лицензией Apache License 2.0.

Оригинальный проект: https://github.com/dkubrow-dev/kripta-cards

# English

**Server version: 1.1.2.**

**Kripta Cards Web API Server** is the content server for the **Kripta Cards** Foundry VTT module.

The server stores the card catalog, card images, players, and issued player cards. The Foundry VTT module connects to it through REST API and uses it as persistent game storage.

## Documentation

User documentation is bundled with the Foundry VTT module:

- `assets/docs/setup-guide.pdf` - server and module setup;
- `assets/docs/content-creation-guide.pdf` - creating cards and localizations.

## Published Build Contents

The published server folder contains:

- `KriptaCardsWebServer.dll` - server entry point for the installed .NET Runtime;
- `KriptaCardsWebServer.exe` - Windows launcher when the project is published with a host executable;
- `appsettings.json` - server settings;
- `nlog.config` - logging settings;
- `README.md` - this file, also available at `/readme`;
- `Content/CardsReg.json` - test card registry;
- `Content/Cards/` - test card images;
- `Content/artifacts/docs/KriptaCardsWebServer.xml` - Swagger XML documentation, if generated;
- `Content/SQLite/players.db` - player and card database, created automatically on first startup.

## Setup

The main configuration file is `appsettings.json`.

Technical users are configured in `UserAuth`:

```json
{
  "UserAuth": {
    "Users": [
      {
        "Id": "kripta-writer",
        "Key": "change-me-writer-key",
        "Role": "Writer"
      },
      {
        "Id": "kripta-reader",
        "Key": "change-me-reader-key",
        "Role": "Reader"
      }
    ]
  }
}
```

`Reader` is used to read the catalog, images, and player data. `Writer` is used for changing data: giving and taking cards, and creating or editing players.

`Cors:AllowedOrigins` lists the Foundry VTT addresses that may call the server from a browser.

`Kestrel:Endpoints` defines the address on which the server listens for HTTP requests.

## Card Content

The server reads content from the `Content` folder:

```text
Content/
  CardsReg.json
  Cards/
    0/
      1.png
    Common/
      shared-image.webp
```

`CardsReg.json` contains:

- `Levels` - card categories or levels;
- `Cards` - cards.

A card contains:

- `Level` - category ID;
- `Number` - card number inside the category;
- `Name` - card name;
- `Description` - card description;
- `ImagePath` - optional shared image name.

If `ImagePath` is empty, the server looks for an image by card number in `Content/Cards/{Level}/{Number}.*`.

If `ImagePath` is set, the server looks for a shared image in `Content/Cards/Common/{ImagePath}.*`.

After reading the registry, the server writes the resolved image path into the card object. The Foundry VTT module requests the image through:

```text
/api/Cards/getCardImage/{imagePath}
```

Recommended image formats for user packages are WebP, PNG, and JPG.

## Running

Before starting, check that:

- `appsettings.json` contains current `Reader` and `Writer` keys;
- `Cors:AllowedOrigins` contains your Foundry VTT address;
- `Content/CardsReg.json` exists;
- each card has exactly one matching image;
- the server can write to `Content/SQLite`.

Console startup:

```powershell
dotnet KriptaCardsWebServer.dll
```

After startup:

- `/swagger` - Swagger UI;
- `/readme` - this help file rendered as HTML;
- `/api/Health/check` - server health check;
- `/api/Health/check-me` - current authorized user check.

## API and Security

The API is protected with Basic Authentication. Foundry VTT must use the same technical user IDs and keys that are configured in `appsettings.json`.

The server does not localize card content. Category names, card names, and descriptions are returned exactly as written in `CardsReg.json`.

## License

Licensed under the Apache License 2.0.

Original project: https://github.com/dkubrow-dev/kripta-cards
