> ### Languages
> Этот README написан на русском языке. Translations into some other languages ​​are below: english, 简体中文, español, 日本語.

# Карточки Крипты

**Карточки Крипты** - модульная система для Foundry VTT, в которой игровые карточки хранятся на отдельном Web API сервере, а интерфейс Foundry VTT позволяет мастеру и игрокам выдавать, запрашивать, просматривать и использовать эти карточки в игре.

Актуальная версия публикации: **1.1.0**.

## Состав проекта

Проект состоит из двух частей, которые работают вместе:

- **Kripta Cards Web API Server** - серверная часть в `Web API server/KriptaCardsWebServer`.
- **dmicher Kripta Cards** - модуль Foundry VTT в `Foundry module/dmicher-kripta-cards`.

Сервер хранит каталог карточек, изображения карточек, игроков и выданные игрокам карточки. Модуль Foundry VTT является пользовательским интерфейсом: открывает каталог, карточки игрока, управление игроками, диалоги выдачи/получения/использования карточек и публикует игровые сообщения в чат.

## Что нового в 1.1.0

- Сервер обновлен до версии `1.1.0`.
- Модуль Foundry VTT обновлен до версии `1.1.0`.
- Каталог карточек теперь возвращает путь к изображению в объекте карточки.
- Изображения карточек запрашиваются как статические ресурсы через путь вида `/api/Cards/getCardImage/{imagePath}` и получают HTTP-заголовки кэширования.
- Добавлена поддержка переиспользования изображений карточек через общие изображения в каталоге карточек.
- В модуле Foundry VTT переработаны окна каталога карточек и карточек игрока: плитки и таблицы используют единый вывод описания.
- Для названий и описаний карточек добавлена HTML-санитаризация: можно использовать безопасную разметку, но нельзя внедрять исполняемый код.
- Сообщения в чат приведены к единому виду: заголовок, подзаголовок, изображение, описание, футер и кнопки подтверждения/отмены запроса.
- Название карточки в чат-сообщениях сопровождается названием категории в скобках.
- В диалогах выдачи и запроса карточек списки карточек сортируются по алфавиту на стороне модуля Foundry.
- В окне управления игроками улучшен внешний вид и добавлена работа с привязкой игрока Foundry к игроку сервера.
- В реестре игроков двойной клик по строке выполняет действие редактирования.
- Пользовательский интерфейс модуля локализован через файлы Foundry VTT в `lang`.
- Добавлены локализации интерфейса на множество языков, включая русский, английский, китайский, испанский, японский и другие.
- Технические ответы сервера больше не выводятся напрямую пользователю в интерфейсе Foundry; пользователь видит локализованные сообщения модуля.
- Удалены случайно попавшие в модуль C-файлы.

## Сервер

Сервер - ASP.NET Core приложение. Он запускается отдельно от Foundry VTT и обслуживает REST API для модуля.

Основные файлы после публикации:

- `KriptaCardsWebServer.dll` - точка входа сервера для запуска через установленный .NET Runtime.
- `appsettings.json` - настройки пользователей, CORS и адреса прослушивания.
- `README.md` - справка сервера, доступная также по `/readme`.
- `Content/CardsReg.json` - реестр карточек.
- `Content/Cards/` - изображения карточек.
- `Content/SQLite/players.db` - база игроков и выданных карточек, создается при запуске.

Сервер использует Basic Authentication. В `appsettings.json` должны быть настроены технические пользователи с ролями:

- `Reader` - чтение каталога, карточек, изображений и данных игроков.
- `Writer` - операции выдачи, списания, изменения игроков и подтверждения запросов.

Изображение карточки определяется сервером при чтении реестра. Если в карточке нет `ImagePath`, используется изображение из папки уровня по номеру карточки. Если `ImagePath` заполнен, используется общее изображение из `Content/Cards/Common`. В API-ответе карточки поле `ImagePath` содержит путь, по которому модуль Foundry запрашивает картинку.

## Модуль Foundry VTT

Модуль устанавливается как обычный модуль Foundry VTT. Для установки через манифест релиза используйте:

```text
https://github.com/dkubrow-dev/kripta-cards/releases/latest/download/module.json
```

После установки откройте настройки модуля в Foundry VTT и заполните:

- адрес сервера;
- ID и ключ технического пользователя `Reader`;
- ID и ключ технического пользователя `Writer`;
- язык интерфейса берется из настроек Foundry VTT.

Модуль добавляет меню **Карточки Крипты** и окна:

- **Каталог карточек** - просмотр всех карточек, вывод карточки в чат, выдача карточки мастером.
- **Получить карточку** - запрос случайной или выбранной карточки.
- **Карточки игрока** - просмотр и использование карточек текущего игрока.
- **Управление игроками** - привязка пользователей Foundry к игрокам сервера.
- **Реестр игроков** - создание, изменение и удаление игроков сервера.
- **Настройки** - подключение к серверу, проверка технических пользователей и выбор языка.

## Локализация

Foundry VTT автоматически подгружает файлы из раздела `languages` в `module.json`. Модуль использует собственные ключи локализации `KRIPTA.*`.

Контент карточек - названия категорий, названия карточек и описания карточек - не переводится программно. Это ответственность контентного набора карточек.

## Лицензия

Проект распространяется под лицензией Apache License 2.0.

- Автор оригинального проекта: dmicher abathur kubrow.
- Оригинальный проект: https://github.com/dkubrow-dev/kripta-cards

# English

**Kripta Cards** is a modular Foundry VTT system where game cards are stored by a separate Web API server, while the Foundry VTT module lets the Game Master and players issue, request, view, and use those cards during play.

Current release version: **1.1.0**.

## Project Parts

The project has two parts that work together:

- **Kripta Cards Web API Server** in `Web API server/KriptaCardsWebServer`.
- **dmicher Kripta Cards** Foundry VTT module in `Foundry module/dmicher-kripta-cards`.

The server stores the card catalog, card images, players, and issued cards. The Foundry module is the user interface for the catalog, player cards, player management, card request/give/use dialogs, and chat messages.

## New In 1.1.0

- Server and Foundry module versions are updated to `1.1.0`.
- Card metadata now contains the resolved image path.
- Card images are requested as cacheable static-like resources through `/api/Cards/getCardImage/{imagePath}`.
- Shared card images are supported.
- Catalog and player-card views now use a unified description preview in tiles and tables.
- Card names and descriptions are sanitized so safe HTML markup is allowed, but executable code is blocked.
- Chat messages use a unified layout and always show the card category next to the card name.
- Card selects in request and give dialogs are sorted alphabetically by the Foundry module.
- Player management and player registry UX was improved.
- The Foundry module UI is localized through Foundry language files.
- Many interface localizations were added.
- Raw technical server responses are no longer shown directly to users in the Foundry UI.
- Accidental C files were removed from the module.

## Server

The server is an ASP.NET Core application that runs separately from Foundry VTT and provides the REST API used by the module.

Published server files include:

- `KriptaCardsWebServer.dll` - server entry point for the installed .NET Runtime.
- `appsettings.json` - users, CORS, and listening URL settings.
- `README.md` - server help, also available at `/readme`.
- `Content/CardsReg.json` - card registry.
- `Content/Cards/` - card images.
- `Content/SQLite/players.db` - player database, created at startup.

The server uses Basic Authentication. Configure `Reader` and `Writer` technical users in `appsettings.json`.

## Foundry VTT Module

Install the module with this release manifest URL:

```text
https://github.com/dkubrow-dev/kripta-cards/releases/latest/download/module.json
```

After installation, configure the server URL, Reader credentials, and Writer credentials in the Foundry module settings. The interface language is taken from Foundry VTT.

Foundry VTT automatically loads the localization files listed in `module.json`. Card content itself - category names, card names, and card descriptions - is not translated by the module and belongs to the card content set.

## License

Licensed under the Apache License 2.0.

- Original author: dmicher abathur kubrow.
- Original project: https://github.com/dkubrow-dev/kripta-cards

# 简体中文

**Kripta Cards** 是一个用于 Foundry VTT 的模块化系统。游戏卡牌数据保存在独立的 Web API 服务器中，Foundry VTT 模块负责让主持人和玩家在游戏中发放、请求、查看和使用卡牌。

当前发布版本：**1.1.0**。

## 项目组成

项目由两个协同工作的部分组成：

- **Kripta Cards Web API Server**：位于 `Web API server/KriptaCardsWebServer`。
- **dmicher Kripta Cards** Foundry VTT 模块：位于 `Foundry module/dmicher-kripta-cards`。

服务器保存卡牌目录、卡牌图片、玩家以及已发放的卡牌。Foundry 模块提供用户界面，包括卡牌目录、玩家卡牌、玩家管理、请求/发放/使用卡牌的对话框，以及聊天消息。

## 1.1.0 新内容

- 服务器和 Foundry 模块版本更新为 `1.1.0`。
- 卡牌元数据现在包含服务器解析后的图片路径。
- 卡牌图片通过 `/api/Cards/getCardImage/{imagePath}` 以类似静态文件的方式请求，并支持浏览器缓存。
- 支持多个卡牌复用同一张图片。
- 卡牌目录和玩家卡牌窗口在网格模式和表格模式中使用统一的描述预览。
- 卡牌名称和描述会经过 HTML 安全清理：可以使用安全标记，但不能注入可执行代码。
- 聊天消息使用统一外观，并始终在卡牌名称后显示类别名称。
- 请求和发放卡牌对话框中的卡牌列表由 Foundry 模块按字母顺序排序。
- 改进了玩家管理和玩家注册表界面。
- Foundry 模块界面通过 Foundry 的语言文件本地化。
- 添加了多种界面语言。
- 服务器的技术性错误响应不再直接显示给 Foundry 用户。
- 从模块中移除了误加入的 C 文件。

## 服务器

服务器是一个 ASP.NET Core 应用程序，独立于 Foundry VTT 运行，并向模块提供 REST API。

发布后的服务器文件包括：

- `KriptaCardsWebServer.dll`：通过已安装 .NET Runtime 启动的服务器入口点。
- `appsettings.json`：用户、CORS 和监听地址设置。
- `README.md`：服务器说明，也可通过 `/readme` 查看。
- `Content/CardsReg.json`：卡牌注册表。
- `Content/Cards/`：卡牌图片。
- `Content/SQLite/players.db`：玩家数据库，启动时自动创建。

服务器使用 Basic Authentication。需要在 `appsettings.json` 中配置 `Reader` 和 `Writer` 技术用户。

## Foundry VTT 模块

使用以下发布清单 URL 安装模块：

```text
https://github.com/dkubrow-dev/kripta-cards/releases/latest/download/module.json
```

安装后，在 Foundry 模块设置中配置服务器地址、Reader 凭据和 Writer 凭据。界面语言来自 Foundry VTT。

Foundry VTT 会自动加载 `module.json` 中列出的本地化文件。卡牌内容本身 - 类别名称、卡牌名称和卡牌描述 - 不由模块翻译，而属于卡牌内容包。

## 许可证

本项目使用 Apache License 2.0。

- 原作者：dmicher abathur kubrow。
- 原项目：https://github.com/dkubrow-dev/kripta-cards

# Español

**Kripta Cards** es un sistema modular para Foundry VTT en el que las cartas de juego se guardan en un servidor Web API independiente, mientras que el módulo de Foundry VTT permite al director de juego y a los jugadores entregar, solicitar, ver y usar esas cartas durante la partida.

Versión actual de publicación: **1.1.0**.

## Partes Del Proyecto

El proyecto tiene dos partes que funcionan juntas:

- **Kripta Cards Web API Server** en `Web API server/KriptaCardsWebServer`.
- **dmicher Kripta Cards** para Foundry VTT en `Foundry module/dmicher-kripta-cards`.

El servidor guarda el catálogo de cartas, las imágenes, los jugadores y las cartas entregadas. El módulo de Foundry es la interfaz para el catálogo, las cartas del jugador, la gestión de jugadores, los diálogos de solicitar/entregar/usar cartas y los mensajes del chat.

## Novedades En 1.1.0

- El servidor y el módulo de Foundry se actualizaron a `1.1.0`.
- Los metadatos de cada carta ahora contienen la ruta resuelta de la imagen.
- Las imágenes se solicitan como recursos cacheables mediante `/api/Cards/getCardImage/{imagePath}`.
- Se admiten imágenes compartidas entre varias cartas.
- El catálogo y la vista de cartas del jugador usan una vista previa de descripción uniforme en mosaicos y tablas.
- Los nombres y descripciones de cartas se limpian con un sanitizador HTML: se permite marcado seguro, pero se bloquea código ejecutable.
- Los mensajes del chat tienen una presentación unificada y siempre muestran la categoría junto al nombre de la carta.
- Las listas de cartas en los diálogos de solicitud y entrega se ordenan alfabéticamente en el módulo Foundry.
- Se mejoró la experiencia de gestión y registro de jugadores.
- La interfaz del módulo está localizada mediante archivos de idioma de Foundry.
- Se añadieron muchas localizaciones de interfaz.
- Las respuestas técnicas del servidor ya no se muestran directamente al usuario en Foundry.
- Se eliminaron archivos C que habían entrado por error en el módulo.

## Servidor

El servidor es una aplicación ASP.NET Core que se ejecuta por separado de Foundry VTT y proporciona la REST API usada por el módulo.

Los archivos publicados del servidor incluyen:

- `KriptaCardsWebServer.dll` - punto de entrada del servidor para ejecutarlo con .NET Runtime instalado.
- `appsettings.json` - configuración de usuarios, CORS y URL de escucha.
- `README.md` - ayuda del servidor, también disponible en `/readme`.
- `Content/CardsReg.json` - registro de cartas.
- `Content/Cards/` - imágenes de cartas.
- `Content/SQLite/players.db` - base de datos de jugadores, creada al iniciar.

El servidor usa Basic Authentication. Configure usuarios técnicos `Reader` y `Writer` en `appsettings.json`.

## Módulo Foundry VTT

Instale el módulo con esta URL de manifiesto del lanzamiento:

```text
https://github.com/dkubrow-dev/kripta-cards/releases/latest/download/module.json
```

Después de instalarlo, configure la URL del servidor, las credenciales Reader y las credenciales Writer en los ajustes de Foundry. El idioma de la interfaz se toma de Foundry VTT.

Foundry VTT carga automáticamente los archivos de localización listados en `module.json`. El contenido de las cartas - nombres de categorías, nombres de cartas y descripciones - no se traduce mediante el módulo y pertenece al conjunto de contenido de cartas.

## Licencia

Licenciado bajo Apache License 2.0.

- Autor original: dmicher abathur kubrow.
- Proyecto original: https://github.com/dkubrow-dev/kripta-cards

# 日本語

**Kripta Cards** は Foundry VTT 向けのモジュール型システムです。ゲーム用カードは独立した Web API サーバーに保存され、Foundry VTT モジュールはゲームマスターとプレイヤーがカードを配布、要求、閲覧、使用するための画面を提供します。

現在のリリースバージョン: **1.1.0**。

## プロジェクト構成

このプロジェクトは、連携して動作する 2 つの部分で構成されています。

- **Kripta Cards Web API Server**: `Web API server/KriptaCardsWebServer`
- **dmicher Kripta Cards** Foundry VTT モジュール: `Foundry module/dmicher-kripta-cards`

サーバーはカードカタログ、カード画像、プレイヤー、配布済みカードを保存します。Foundry モジュールは、カタログ、プレイヤーのカード、プレイヤー管理、カードの要求/配布/使用ダイアログ、チャットメッセージのユーザーインターフェイスです。

## 1.1.0 の変更点

- サーバーと Foundry モジュールを `1.1.0` に更新しました。
- カードのメタデータに、サーバーが解決した画像パスが含まれるようになりました。
- カード画像は `/api/Cards/getCardImage/{imagePath}` から、キャッシュ可能な静的リソースに近い形式で取得されます。
- 複数のカードで共通画像を再利用できます。
- カタログ画面とプレイヤーカード画面で、タイル表示と表表示の説明プレビューを統一しました。
- カード名と説明は HTML サニタイザーを通ります。安全なマークアップは使用できますが、実行可能なコードはブロックされます。
- チャットメッセージの外観を統一し、カード名には常にカテゴリ名が併記されます。
- カード要求/配布ダイアログのカード一覧は Foundry モジュール側でアルファベット順に並び替えられます。
- プレイヤー管理とプレイヤー登録画面の操作性を改善しました。
- Foundry の言語ファイルによるインターフェイスのローカライズに対応しました。
- 多数のインターフェイス言語を追加しました。
- サーバーの技術的な応答は Foundry のユーザー画面に直接表示されなくなりました。
- 誤って含まれていた C ファイルをモジュールから削除しました。

## サーバー

サーバーは ASP.NET Core アプリケーションで、Foundry VTT とは別に実行され、モジュールが使用する REST API を提供します。

公開版のサーバーファイルには次のものが含まれます。

- `KriptaCardsWebServer.dll` - インストール済みの .NET Runtime で起動するサーバーのエントリーポイント。
- `appsettings.json` - ユーザー、CORS、待受 URL の設定。
- `README.md` - サーバーのヘルプ。`/readme` からも表示できます。
- `Content/CardsReg.json` - カード登録ファイル。
- `Content/Cards/` - カード画像。
- `Content/SQLite/players.db` - 起動時に作成されるプレイヤーデータベース。

サーバーは Basic Authentication を使用します。`appsettings.json` で `Reader` と `Writer` の技術ユーザーを設定してください。

## Foundry VTT モジュール

次のリリースマニフェスト URL でモジュールをインストールします。

```text
https://github.com/dkubrow-dev/kripta-cards/releases/latest/download/module.json
```

インストール後、Foundry のモジュール設定でサーバー URL、Reader 認証情報、Writer 認証情報を設定します。インターフェイス言語は Foundry VTT から取得されます。

Foundry VTT は `module.json` に列挙されたローカライズファイルを自動的に読み込みます。カードの内容そのもの、つまりカテゴリ名、カード名、説明文はモジュールでは翻訳されず、カードコンテンツセットの責任範囲です。

## ライセンス

Apache License 2.0 の下でライセンスされています。

- 原作者: dmicher abathur kubrow。
- 元プロジェクト: https://github.com/dkubrow-dev/kripta-cards
