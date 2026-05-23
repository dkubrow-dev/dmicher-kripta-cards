import { catalogs, config } from "./site-data.mjs";

export const navigation = {
  en: [
    { href: "/en/", label: "Home" },
    { href: "/en/downloads/", label: "Downloads" },
    { href: "/en/docs/", label: "Docs" },
    { href: "/en/ai-policy/", label: "AI policy" }
  ],
  ru: [
    { href: "/ru/", label: "Главная" },
    { href: "/ru/downloads/", label: "Загрузки" },
    { href: "/ru/docs/", label: "Документация" },
    { href: "/ru/ai-policy/", label: "ИИ-политика" }
  ]
};

export const ui = {
  en: {
    skip: "Skip to content",
    language: "Language",
    mainNavigation: "Main navigation",
    theme: "Theme",
    dark: "Dark",
    light: "Light",
    switchTheme: "Switch theme",
    download: "Download",
    planned: "Planned",
    published: "Published",
    unavailable: "Not published yet",
    repositoryLinks: "Repository links",
    allDownloads: "All downloads",
    status: "Status",
    version: "Version",
    compatibility: "Compatibility",
    date: "Date",
    file: "File",
    size: "Size",
    sha256: "SHA-256",
    aiStatus: "AI status",
    notes: "Notes",
    bat: "Windows patch",
    sh: "Unix patch",
    moduleVersionHintTitle: "Recommendation for your module version",
    moduleVersionHintText: "You opened this page from Foundry module version {version}. Review the server, language patches, and optional content packs that match your version before downloading.",
    pageNotFoundTitle: "Page not found",
    pageNotFoundText: "This page does not exist in the selected language. Go back to the home page or downloads."
  },
  ru: {
    skip: "Перейти к содержимому",
    language: "Язык",
    mainNavigation: "Основная навигация",
    theme: "Тема",
    dark: "Темная",
    light: "Светлая",
    switchTheme: "Переключить тему",
    download: "Скачать",
    planned: "Планируется",
    published: "Опубликовано",
    unavailable: "Еще не опубликовано",
    repositoryLinks: "Ссылки на репозитории",
    allDownloads: "Все загрузки",
    status: "Статус",
    version: "Версия",
    compatibility: "Совместимость",
    date: "Дата",
    file: "Файл",
    size: "Размер",
    sha256: "SHA-256",
    aiStatus: "ИИ-статус",
    notes: "Примечания",
    bat: "Патч Windows",
    sh: "Патч Unix",
    moduleVersionHintTitle: "Рекомендация для вашей версии модуля",
    moduleVersionHintText: "Вы открыли сайт из модуля Foundry версии {version}. Перед загрузкой проверьте сервер, патчи локализаций и дополнительные контентные паки, подходящие к вашей версии.",
    pageNotFoundTitle: "Страница не найдена",
    pageNotFoundText: "Этой страницы нет на выбранном языке. Вернитесь на главную или к загрузкам."
  }
};

export const pages = [
  {
    slug: "",
    navKey: "home",
    title: {
      en: "Kripta Cards",
      ru: "Карточки Крипты"
    },
    description: {
      en: "Downloads and documentation for the Kripta Cards Foundry VTT module and content server.",
      ru: "Загрузки и документация для модуля Foundry VTT и сервера контента Карточек Крипты."
    },
    render: renderHome
  },
  {
    slug: "downloads",
    navKey: "downloads",
    title: {
      en: "Downloads",
      ru: "Загрузки"
    },
    description: {
      en: "Choose the server, Foundry module manifest, optional language patches, and content packs.",
      ru: "Выберите сервер, манифест модуля Foundry, необязательные патчи локализаций и контентные паки."
    },
    render: renderDownloads
  },
  {
    slug: "downloads/server",
    title: {
      en: "Content Server Downloads",
      ru: "Загрузки сервера контента"
    },
    description: {
      en: "Server releases for hosting card catalogs outside Foundry VTT.",
      ru: "Сборки сервера для хранения каталогов карточек вне Foundry VTT."
    },
    render: renderServerDownloads
  },
  {
    slug: "downloads/module",
    title: {
      en: "Foundry Module",
      ru: "Модуль Foundry"
    },
    description: {
      en: "Foundry package information, manifest link, and release notes.",
      ru: "Информация о пакете Foundry, ссылка на манифест и заметки о релизах."
    },
    render: renderModuleDownloads
  },
  {
    slug: "downloads/language-patches",
    title: {
      en: "Language Patches",
      ru: "Патчи локализаций"
    },
    description: {
      en: "Optional post-install patches that add extra interface localizations to the module.",
      ru: "Необязательные пост-установочные патчи, добавляющие дополнительные локализации интерфейса в модуль."
    },
    render: renderLanguagePatches
  },
  {
    slug: "downloads/content-packs",
    title: {
      en: "Content Packs",
      ru: "Контентные паки"
    },
    description: {
      en: "Optional card datasets and translations distributed outside the main content-server build.",
      ru: "Необязательные наборы карточек и переводы, распространяемые вне основной сборки сервера контента."
    },
    render: renderContentPacks
  },
  {
    slug: "ai-policy",
    title: {
      en: "AI Policy",
      ru: "ИИ-политика"
    },
    description: {
      en: "How Kripta Cards separates Foundry-publishable material from optional generated or AI-assisted content.",
      ru: "Как Карточки Крипты отделяют материалы для публикации Foundry от необязательного сгенерированного контента."
    },
    render: renderAiPolicy
  },
  {
    slug: "docs",
    title: {
      en: "Documentation",
      ru: "Документация"
    },
    description: {
      en: "Installation and usage guides for the module, server, patches, and content packs.",
      ru: "Инструкции по установке и использованию модуля, сервера, патчей и контентных паков."
    },
    render: renderDocs
  },
  {
    slug: "docs/module",
    title: {
      en: "Module Setup",
      ru: "Настройка модуля"
    },
    description: {
      en: "Install the Foundry module and connect it to a content server.",
      ru: "Установите модуль Foundry и подключите его к серверу контента."
    },
    render: renderModuleDocs
  },
  {
    slug: "docs/server",
    title: {
      en: "Server Setup",
      ru: "Настройка сервера"
    },
    description: {
      en: "Install, configure, and run the Kripta Cards content server.",
      ru: "Установите, настройте и запустите сервер контента Карточек Крипты."
    },
    render: renderServerDocs
  },
  {
    slug: "docs/language-patches",
    title: {
      en: "Language Patch Guide",
      ru: "Инструкция по патчам локализаций"
    },
    description: {
      en: "Apply optional language patches after installing the module.",
      ru: "Примените необязательные патчи локализаций после установки модуля."
    },
    render: renderPatchDocs
  },
  {
    slug: "docs/content-packs",
    title: {
      en: "Content Pack Guide",
      ru: "Инструкция по контентным пакам"
    },
    description: {
      en: "Install optional content packs on the content server.",
      ru: "Установите необязательные контентные паки на сервер контента."
    },
    render: renderContentPackDocs
  },
  {
    slug: "docs/troubleshooting",
    title: {
      en: "Troubleshooting",
      ru: "Решение проблем"
    },
    description: {
      en: "Common installation and connection checks.",
      ru: "Типовые проверки установки и подключения."
    },
    render: renderTroubleshooting
  }
];

function renderHome(locale, h) {
  const isRu = locale === "ru";
  return `
    <section class="hero">
      <div class="hero-copy">
        <p class="eyebrow">dmicher abathur kubrow</p>
        <h1>${isRu ? "Карточки Крипты" : "Kripta Cards"}</h1>
        <p class="lead">${isRu
          ? "Модуль для Foundry VTT: награждайте игроков за лучший отыгрыш их персонажей карточками с игровыми бонусами и следите за их использованием. Сохраняйте карточки между приключами, мирами и игровыми системами."
          : "A module for Foundry VTT: reward players for their best character performance with cards containing in-game bonuses and track their use. Save cards between adventures, worlds, and game systems."}</p>
        <div class="hero-actions">
          ${h.linkButton(`/${locale}/downloads/`, isRu ? "Перейти к загрузкам" : "View downloads")}
          ${h.linkButton(`/${locale}/ai-policy/`, isRu ? "ИИ-политика" : "AI policy", "secondary")}
        </div>
      </div>
      <aside class="release-panel" aria-label="${isRu ? "Базовый набор" : "Basic package"}">
        <div class="panel-kicker">${isRu ? "Базовый набор" : "Basic package"}</div>
        <div class="release-number">1.1.1</div>
        <p>${isRu
          ? "В состав базового набора входит тестовый контент, минимально достаточный для старта. Дополнительные компоненты можете скачать отдельно или составить сами, пользуясь документацией."
          : "The basic set includes test content, which is the bare minimum to get started. You can download additional components separately or create your own using the documentation."}</p>
        <dl class="compact-list">
          <div><dt>${isRu ? "Модуль" : "Module"}</dt><dd>${isRu ? "Полная версия" : "Full version"}</dd></div>
          <div><dt>${isRu ? "Сервер" : "Server"}</dt><dd>${isRu ? "Полная версия" : "Full version"}</dd></div>
          <div><dt>${isRu ? "Набор карточек" : "Cards pack"}</dt><dd>${isRu ? "Тестовый набор карточек" : "Test set of cards"}</dd></div>
          <div><dt>${isRu ? "Языки" : "Languages"}</dt><dd>${isRu ? "Русский, английский" : "Russian, English"}</dd></div>
        </dl>
      </aside>
    </section>
    <section class="module-context" data-module-context hidden>
      <h2>${h.ui.moduleVersionHintTitle}</h2>
      <p data-module-version-text>${h.ui.moduleVersionHintText}</p>
      <div class="inline-links">
        <a href="/${locale}/downloads/server/">${isRu ? "Сервер" : "Server"}</a>
        <a href="/${locale}/downloads/language-patches/">${isRu ? "Патчи локализаций" : "Language patches"}</a>
        <a href="/${locale}/downloads/content-packs/">${isRu ? "Контентные паки" : "Content packs"}</a>
      </div>
    </section>
    <section>
      <div class="section-head">
        <h2>${isRu ? "Быстрые переходы" : "Quick links"}</h2>
      </div>
      ${h.cardGrid([
        { href: `/${locale}/downloads/server/`, title: isRu ? "Сервер контента" : "Content server", text: isRu ? "Сборки сервера, совместимость, контрольные суммы." : "Server builds, compatibility, and checksums." },
        { href: `/${locale}/downloads/module/`, title: isRu ? "Модуль Foundry VTT" : "Foundry VTT module", text: isRu ? "Сам модуль Foundry VTT для использования внутри игровых миров." : "The Foundry VTT module itself for use within game worlds." },
        { href: `/${locale}/downloads/content-packs/`, title: isRu ? "Контентные паки" : "Content packs", text: isRu ? "Полноценные наборы карточек для замены тестовых данных и применения в играх." : "Complete sets of cards for replacing test data and using in games." },
        { href: `/${locale}/downloads/language-patches/`, title: isRu ? "Патчи локализаций" : "Language patches", text: isRu ? "Дополнительные локали, устанавливаемые после модуля." : "Extra locales installed after the module." }
      ])}
    </section>
    <section>
      <div class="section-head">
        <h2>${h.ui.repositoryLinks}</h2>
      </div>
      ${h.linkList(config.repositories.map((repo) => ({ href: repo.href, label: repo.label[locale] })))}
    </section>
  `;
}

function renderDownloads(locale, h) {
  const isRu = locale === "ru";
  return `
    ${h.pageIntro(
      isRu ? "Загрузки" : "Downloads",
      isRu
        ? "Загрузки разделены по назначению. Скачайте модуль Foundry VTT, чтобы установить его вручную, если ещё не установили его через Foundry VTT. Затем, скачайте и установите сервер контента. Чтобы заменить тестовые данные сервера контента скачайте контентные паки и загрузите на сервер. Чтобы воспользоваться дополнительными языками локализации, скачайте патчи и установите после загрузки модуля."
        : "Downloads are divided by purpose. Download the Foundry VTT module to install it manually if you haven't already installed it via Foundry VTT. Then, download and install the content server. To replace the content server's test data, download the content packs and upload them to the server. To use additional localization languages, download patches and install them after downloading the module."
    )}
    ${h.cardGrid([
        { href: `/${locale}/downloads/server/`, title: isRu ? "Сервер контента" : "Content server", text: isRu ? "Сборки сервера, совместимость, контрольные суммы." : "Server builds, compatibility, and checksums." },
        { href: `/${locale}/downloads/module/`, title: isRu ? "Модуль Foundry VTT" : "Foundry VTT module", text: isRu ? "Сам модуль Foundry VTT для использования внутри игровых миров." : "The Foundry VTT module itself for use within game worlds." },
        { href: `/${locale}/downloads/content-packs/`, title: isRu ? "Контентные паки" : "Content packs", text: isRu ? "Полноценные наборы карточек для замены тестовых данных и применения в играх." : "Complete sets of cards for replacing test data and using in games." },
        { href: `/${locale}/downloads/language-patches/`, title: isRu ? "Патчи локализаций" : "Language patches", text: isRu ? "Дополнительные локали, устанавливаемые после модуля." : "Extra locales installed after the module." }
      ])}
  `;
}

function renderServerDownloads(locale, h) {
  const isRu = locale === "ru";
  return `
    ${h.pageIntro(
      isRu ? "Сервер контента" : "Content server",
      isRu
        ? "Сервер запускается отдельно от Foundry VTT, хранит в себе тестовый каталог карточек (названия, изображения, описания), данные игроков и выданные им карточки. Основная сборка для публикации не включает необязательные контентные паки - скачивайте и устанавливайте их отдельно."
        : "The server runs separately from Foundry VTT and stores a test card catalog (names, images, descriptions), player data, and issued cards. The main build for publication does not include optional content packs; download and install them separately."
    )}
    ${h.serverReleaseTable(catalogs.serverReleases)}
  `;
}

function renderModuleDownloads(locale, h) {
  const isRu = locale === "ru";
  return `
    ${h.pageIntro(
      isRu ? "Модуль Foundry VTT" : "Foundry VTT module",
      isRu
        ? "Модуль устанавливается через манифест, через клиент Foundry или вручную. В публичной сборке на платформе Founrdy присутствуют английская и русская локализации интерфейса. Дополнительные патчи локализаций скачивайте отдельно."
        : "The module can be installed via the manifest, the Foundry client, or manually. The public build on the Foundry platform includes English and Russian localizations of the interface. Additional localization patches are available for download separately."
    )}
    <div class="callout">
      <strong>${isRu ? "Манифест:" : "Manifest:"}</strong>
      <a href="${config.foundry.manifestUrl}">${config.foundry.manifestUrl}</a>
    </div>
    <div class="callout">
      <strong>${isRu ? "Страница Foundry:" : "Foundry listing:"}</strong>
      <a href="${config.foundry.listingUrl}">${config.foundry.listingUrl}</a>
    </div>
    ${h.moduleReleaseTable(catalogs.moduleReleases)}
  `;
}

function renderLanguagePatches(locale, h) {
  const isRu = locale === "ru";
  return `
    ${h.pageIntro(
      isRu ? "Патчи локализаций" : "Language patches",
      isRu
        ? "Дополнительные локализации не входят в основной пакет модуля Foundry VTT. Патч создает файл локали и обновляет манифест модуля после его установки."
        : "Additional localizations are not included in the core Foundry VTT module package. The patch creates a locale file and updates the module manifest after installation."
    )}
    <div class="notice">${isRu
      ? "Перед запуском патча закройте Foundry VTT и сделайте резервную копию папки модуля."
      : "Before running a patch, close Foundry VTT and back up the module folder."}</div>
    ${h.languagePatchTable(catalogs.languagePatches)}
  `;
}

function renderContentPacks(locale, h) {
  const isRu = locale === "ru";
  return `
    ${h.pageIntro(
      isRu ? "Контентные паки" : "Content packs",
      isRu
        ? "Контентные паки содержат наборы карт (название, описание и изображения). Они публикуются отдельно от основной сборки сервера. Остановите сервер и замените пак согласно документации, затем, запустите сервер вновь, чтобы установить набор карточек."
        : "Content packs contain map sets (name, description, and images). They are published separately from the main server build. Stop the server and replace the pack according to the documentation, then restart the server to install the map set."
    )}
    ${h.contentPackTable(catalogs.contentPacks)}
  `;
}

function renderAiPolicy(locale, h) {
  const isRu = locale === "ru";
  return `
    ${h.pageIntro(
      isRu ? "ИИ-политика" : "AI use policy",
      isRu
        ? "Модуль, публикуемый на Foundry VTT соответствует политике платформы в области использования ИИ. Необязательный для работы контент, созданный с участием ИИ, включая изображения карточек и машинные переводы интерфейса, отделён от этой публикации, чтобы мастер игры мог взвешенно принять собственное решение об использовании такого контента в игре, принимая риски на себя. Пожалуйста, не нарушайте правила Foundry VTT в области ИИ: вы можете использовать собственные наборы контента и локализаций."
        : "The module published on Foundry VTT complies with the platform's AI policy. Non-essential content generated partially with AI, including card images and machine translations of the interface, is separated from this publication so that the game master can make an informed decision about using such content in the game, assuming the risk. Please adhere to Foundry VTT's AI guidelines: you are welcome to use your own content sets and localizations."
    )}
    <section class="text-flow">
      <h2>${isRu ? "Базовый набор" : "Basic package"}</h2>
      <p>${isRu
        ? "Базовый набор содержит интерфейс, сервер, тестовый набор карточек, созданные полностью человеком, а также переводы, созданные человеком при частичной помощи ИИ с последующим компетентным контролем со стороны человека. Данные, не соответствующие политике Foundry VTT в области ИИ, не содержатся в базовом наборе."
        : "The basic package contains the interface, server, and test set of cards, all created entirely by humans, as well as translations created by humans with partial AI assistance and subsequent competent human review. Data that does not comply with Foundry VTT's AI policy is not included in the core set."}</p>
      <h2>${isRu ? "Дополнения" : "Add-ons"}</h2>
      <p>${isRu
        ? "Дополнительные материалы - это файлы локализаций интерфейса, выполненные машинным переводом, а также наборы карточек, часть содержимого которого было сгенерировано машиной. Дополнения публикуются с публичным ИИ-статусом."
        : "Additional materials include machine-translated interface localization files, as well as card sets with some machine-generated content. These additions are published with public AI status."}</p>
      <h2>${isRu ? "Статусы" : "Statuses"}</h2>
      ${h.aiStatusList()}
    </section>
  `;
}

function renderDocs(locale, h) {
  const isRu = locale === "ru";
  return `
    ${h.pageIntro(
      isRu ? "Документация" : "Documentation",
      isRu
        ? "Разделы будут наполняться по мере подготовки релиза 1.1.1. Каркас уже разделяет установку модуля, сервера, патчей и паков."
        : "These sections will be filled as the 1.1.1 release is prepared. The structure already separates module, server, patch, and pack setup."
    )}
    ${h.cardGrid([
      { href: `/${locale}/docs/module/`, title: isRu ? "Модуль" : "Module", text: isRu ? "Установка модуля и подключение к серверу." : "Install the module and connect it to the server." },
      { href: `/${locale}/docs/server/`, title: isRu ? "Сервер" : "Server", text: isRu ? "Развертывание и настройка сервера контента." : "Deploy and configure the content server." },
      { href: `/${locale}/docs/language-patches/`, title: isRu ? "Патчи локализаций" : "Language patches", text: isRu ? "Как применять bat/sh-патчи." : "How to apply bat/sh patches." },
      { href: `/${locale}/docs/content-packs/`, title: isRu ? "Контентные паки" : "Content packs", text: isRu ? "Как добавлять наборы карточек на сервер." : "How to add card sets to the server." },
      { href: `/${locale}/docs/troubleshooting/`, title: isRu ? "Проблемы" : "Troubleshooting", text: isRu ? "Проверки подключения и частые ошибки." : "Connection checks and common errors." }
    ])}
  `;
}

function renderModuleDocs(locale, h) {
  const isRu = locale === "ru";
  return h.steps([
    isRu ? "Установите модуль Foundry через манифест релиза." : "Install the Foundry module through the release manifest.",
    isRu ? "Включите модуль в мире Foundry VTT." : "Enable the module in your Foundry VTT world.",
    isRu ? "Откройте настройки модуля и укажите адрес сервера контента." : "Open module settings and enter the content server URL.",
    isRu ? "Заполните учетные данные технических пользователей Reader и Writer." : "Fill in Reader and Writer technical credentials.",
    isRu ? "Проверьте соединение в настройках модуля." : "Check the connection in module settings."
  ]);
}

function renderServerDocs(locale, h) {
  const isRu = locale === "ru";
  return h.steps([
    isRu ? "Скачайте подходящий архив сервера." : "Download the appropriate server archive.",
    isRu ? "Распакуйте архив в отдельную папку на сервере Windows." : "Extract the archive into a dedicated folder on the Windows server.",
    isRu ? "Настройте appsettings.json: адрес прослушивания, CORS и технических пользователей." : "Configure appsettings.json: listen address, CORS, and technical users.",
    isRu ? "Запустите сервер и проверьте доступность API через прокси IIS." : "Start the server and verify API access through the IIS proxy.",
    isRu ? "Подключите модуль Foundry к публичному адресу сервера." : "Connect the Foundry module to the public server URL."
  ]);
}

function renderPatchDocs(locale, h) {
  const isRu = locale === "ru";
  return h.steps([
    isRu ? "Скачайте патч для нужной локали и операционной системы." : "Download the patch for the required locale and operating system.",
    isRu ? "Сделайте резервную копию папки установленного модуля." : "Back up the installed module folder.",
    isRu ? "Запустите bat или sh-файл из папки модуля или передайте путь согласно инструкции патча." : "Run the bat or sh file from the module folder or pass the path according to the patch instructions.",
    isRu ? "Перезапустите Foundry и выберите локаль в настройках Foundry." : "Restart Foundry and select the locale in Foundry settings."
  ]);
}

function renderContentPackDocs(locale, h) {
  const isRu = locale === "ru";
  return h.steps([
    isRu ? "Скачайте контентный пак и проверьте его ИИ-статус." : "Download the content pack and review its AI status.",
    isRu ? "Остановите сервер контента." : "Stop the content server.",
    isRu ? "Распакуйте данные в каталог Content согласно инструкции конкретного пака." : "Extract the data into the Content directory according to the pack instructions.",
    isRu ? "Запустите сервер и проверьте каталог карточек через модуль." : "Start the server and check the card catalog through the module."
  ]);
}

function renderTroubleshooting(locale, h) {
  const isRu = locale === "ru";
  return `
    ${h.pageIntro(
      isRu ? "Базовые проверки" : "Basic checks",
      isRu
        ? "Эта страница пока содержит минимальный список. По мере тестирования релиза добавим конкретные ошибки и решения."
        : "This page currently contains a minimal list. Specific errors and fixes will be added during release testing."
    )}
    ${h.checkList([
      isRu ? "Публичный URL сервера открывается с машины Foundry." : "The public server URL opens from the Foundry machine.",
      isRu ? "CORS разрешает адрес Foundry." : "CORS allows the Foundry origin.",
      isRu ? "Reader и Writer имеют разные роли и корректные ключи." : "Reader and Writer have distinct roles and valid keys.",
      isRu ? "Версии сервера, модуля и контентных паков совместимы." : "Server, module, and content-pack versions are compatible."
    ])}
  `;
}
