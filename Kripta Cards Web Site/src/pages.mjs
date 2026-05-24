import { catalogs, config } from "./site-data.mjs";

export const navigation = {
  en: [
    { href: "/en/", label: "Home" },
    { href: "/en/downloads/", label: "Downloads" },
    { href: "/en/docs/", label: "Docs" },
    { href: "/en/ai-policy/", label: "AI policy" },
    { href: "/en/author-license/", label: "Author" }
  ],
  ru: [
    { href: "/ru/", label: "Главная" },
    { href: "/ru/downloads/", label: "Загрузки" },
    { href: "/ru/docs/", label: "Документация" },
    { href: "/ru/ai-policy/", label: "ИИ-политика" },
    { href: "/ru/author-license/", label: "Автор" }
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
    serverRecommendationTitle: "Server for your module version",
    serverRecommendationText: "You opened this page from Foundry module version {version}. The matching content-server build is listed below.",
    contact: "Contact",
    license: "License",
    donation: "Donation",
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
    serverRecommendationTitle: "Сервер для вашей версии модуля",
    serverRecommendationText: "Вы открыли страницу из модуля Foundry версии {version}. Подходящая сборка сервера контента указана ниже.",
    contact: "Контакты",
    license: "Лицензия",
    donation: "Донат",
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
    slug: "author-license",
    title: {
      en: "Author and License",
      ru: "Автор и лицензия"
    },
    description: {
      en: "Author, license, contact points, and donation link for Kripta Cards.",
      ru: "Автор, лицензия, контакты и ссылка для доната проекта Карточки Крипты."
    },
    render: renderAuthorLicense
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
      ru: "Установка локализаций"
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
      ru: "Установка паков контента"
    },
    description: {
      en: "Install optional content packs on the content server.",
      ru: "Установите необязательные контентные паки на сервер контента."
    },
    render: renderContentPackDocs
  }
];

function getBasicPackageData() {
  const module = maxByVersion(catalogs.moduleReleases);
  if (!module) {
    return null;
  }

  const compatibleServers = catalogs.serverReleases.filter((server) => supportsVersion(server.moduleCompatibility, module.version));
  const server = maxByVersion(compatibleServers);
  if (!server) {
    return null;
  }

  const moduleFile = module.files?.[0];
  const serverFile = server.files?.[0];
  const downloads = [moduleFile, serverFile]
    .filter(Boolean)
    .map((file) => ({ href: file.href, label: file.label }));

  return { module, server, downloads };
}

function maxByVersion(items) {
  return [...items].sort((a, b) => compareVersions(b.version, a.version))[0] ?? null;
}

function compareVersions(left, right) {
  const leftParts = parseVersion(left);
  const rightParts = parseVersion(right);
  const length = Math.max(leftParts.length, rightParts.length);

  for (let index = 0; index < length; index += 1) {
    const leftPart = leftParts[index] ?? 0;
    const rightPart = rightParts[index] ?? 0;
    if (leftPart !== rightPart) {
      return leftPart - rightPart;
    }
  }

  return 0;
}

function parseVersion(version) {
  return String(version)
    .split(/[^\d]+/)
    .filter(Boolean)
    .map((part) => Number(part));
}

function supportsVersion(compatibility, version) {
  return String(compatibility ?? "")
    .split(/[\s,;]+/)
    .map((item) => item.trim())
    .filter(Boolean)
    .includes(version);
}

function formatPackageVersions(packageData) {
  if (packageData.module.version === packageData.server.version) {
    return packageData.module.version;
  }

  return `${packageData.module.version} / ${packageData.server.version}`;
}

function renderHome(locale, h) {
  const isRu = locale === "ru";
  const basicPackage = getBasicPackageData();
  const packageTitle = basicPackage
    ? `${isRu ? "Базовый набор" : "Basic package"} ${formatPackageVersions(basicPackage)}`
    : isRu ? "Базовый набор" : "Basic package";

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
      <aside class="release-panel" aria-label="${packageTitle}">
        <div class="panel-kicker">${packageTitle}</div>
        ${basicPackage ? h.multiDownloadButton(basicPackage.downloads, h.ui.download, "release-download") : ""}
        <p>${isRu
          ? "В состав базового набора входит тестовый контент, минимально достаточный для старта. Дополнительные компоненты можете скачать отдельно или составить сами, пользуясь документацией."
          : "The basic set includes test content, which is the bare minimum to get started. You can download additional components separately or create your own using the documentation."}</p>
        <dl class="compact-list">
          <div><dt>${isRu ? "Модуль" : "Module"}</dt><dd>${isRu ? "Полная версия" : "Full version"}${basicPackage ? ` ${basicPackage.module.version}` : ""}</dd></div>
          <div><dt>${isRu ? "Сервер" : "Server"}</dt><dd>${isRu ? "Полная версия" : "Full version"}${basicPackage ? ` ${basicPackage.server.version}` : ""}</dd></div>
          <div><dt>${isRu ? "Набор карточек" : "Cards pack"}</dt><dd>${isRu ? "Тестовый набор карточек" : "Test set of cards"}</dd></div>
          <div><dt>${isRu ? "Языки" : "Languages"}</dt><dd>${isRu ? "Русский, английский" : "Russian, English"}</dd></div>
        </dl>
      </aside>
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
    ${h.serverRecommendationPanel(catalogs.serverReleases)}
    ${h.serverReleaseTable(catalogs.serverReleases)}
  `;
}

function renderModuleDownloads(locale, h) {
  const isRu = locale === "ru";
  return `
    ${h.pageIntro(
      isRu ? "Модуль Foundry VTT" : "Foundry VTT module",
      isRu
        ? "Модуль устанавливается через манифест, через клиент Foundry или вручную. В публичной сборке на платформе Foundry присутствуют английская и русская локализации интерфейса. Дополнительные патчи локализаций скачивайте отдельно."
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
        : "Content packs contain card sets (name, description, and images). They are published separately from the main server build. Stop the server and replace the pack according to the documentation, then restart the server to install the card set."
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

function renderAuthorLicense(locale, h) {
  const isRu = locale === "ru";
  const author = config.author;
  const contactCards = author.contacts.map((contact) => ({
    href: contact.href,
    title: contact.label[locale],
    text: contact.note[locale]
  }));

  return `
    ${h.pageIntro(
      isRu ? "Автор и лицензия" : "Author and license",
      isRu
        ? "Сведения об авторе проекта, лицензии, публичных контактах и способе поддержать разработку."
        : "Project author, license, public contact points, and a way to support development."
    )}
    <section class="text-flow">
      <h2>${isRu ? "Автор" : "Author"}</h2>
      <p><strong>${author.name}</strong></p>
      <h2>${h.ui.license}</h2>
      <p>${isRu
        ? "Проект распространяется под лицензией"
        : "The project is distributed under the"} <a href="${author.license.href}">${author.license.name}</a>.</p>
      <h2>${h.ui.contact}</h2>
      <p>${isRu
        ? "Для публичных сообщений об ошибках и предложений используйте GitHub Issues."
        : "Use GitHub Issues for public bug reports and feature requests."}</p>
    </section>
    ${h.cardGrid(contactCards)}
  `;
}

function renderDocs(locale, h) {
  const isRu = locale === "ru";
  return `
    ${h.pageIntro(
      isRu ? "Документация" : "Documentation",
      isRu
        ? "Инструкции разделены по частям проекта: модуль Foundry, сервер контента, патчи локализаций, контентные паки и типовые проверки."
        : "Guides are split by project part: Foundry module, content server, language patches, content packs, and common checks."
    )}
    ${h.cardGrid([
      { href: `/${locale}/docs/module/`, title: isRu ? "Модуль" : "Module", text: isRu ? "Установка модуля и подключение к серверу." : "Install the module and connect it to the server." },
      { href: `/${locale}/docs/server/`, title: isRu ? "Сервер" : "Server", text: isRu ? "Развертывание и настройка сервера контента." : "Deploy and configure the content server." },
      { href: `/${locale}/docs/language-patches/`, title: isRu ? "Патчи локализаций" : "Language patches", text: isRu ? "Как применять bat/sh-патчи." : "How to apply bat/sh patches." },
      { href: `/${locale}/docs/content-packs/`, title: isRu ? "Контентные паки" : "Content packs", text: isRu ? "Как добавлять наборы карточек на сервер." : "How to add card sets to the server." }
    ])}
  `;
}

function renderModuleDocs(locale, h) {
  const isRu = locale === "ru";
  return `
    ${h.pageIntro(
      isRu ? "Настройка модуля" : "Module setup",
      isRu
        ? "Модуль Foundry VTT является интерфейсом для сервера контента. Сначала настройте и запустите сервер, затем подключите к нему модуль в каждом игровом мире."
        : "The Foundry VTT module is the interface for the content server. Configure and start the server first, then connect the module to it in each game world."
    )}
    <section class="text-flow">
      <h2>${isRu ? "Установка" : "Installation"}</h2>
      <p>${isRu
        ? "Через Foundry используйте установку модуля по ссылке на манифест релиза. Для ручной установки положите папку модуля в каталог пользовательских данных Foundry: Data/modules/dmicher-kripta-cards."
        : "In Foundry, install the module with the release manifest URL. For manual installation, put the module folder into the Foundry user data directory: Data/modules/dmicher-kripta-cards."}</p>
      ${h.codeBlock(config.foundry.manifestUrl)}
      <p>${isRu
        ? "После установки откройте нужный мир Foundry VTT, включите модуль в списке модулей мира и перезагрузите мир, если Foundry попросит это сделать."
        : "After installation, open the required Foundry VTT world, enable the module in the world's module list, and reload the world if Foundry asks you to."}</p>

      <h2>${isRu ? "Подключение к серверу" : "Connecting to the server"}</h2>
      <ol>
        <li>${isRu ? "Войдите в мир под пользователем мастера." : "Enter the world as a Game Master."}</li>
        <li>${isRu ? "Откройте настройки игры и раздел Карточки Крипты." : "Open Game Settings and the Kripta Cards section."}</li>
        <li>${isRu ? "В поле адреса сервера укажите публичный URL сервера контента, например https://cards.example.com. Не добавляйте /swagger или /api, если сервер опубликован в корне адреса." : "In the server URL field, enter the public content-server URL, for example https://cards.example.com. Do not add /swagger or /api if the server is published at the URL root."}</li>
        <li>${isRu ? "Нажмите проверку сервера. Модуль должен получить ответ health-check от запущенного сервера." : "Run the server check. The module should receive a health-check response from the running server."}</li>
        <li>${isRu ? "Заполните Id и Key для Writer и Reader теми же значениями, которые указаны в appsettings.json на сервере." : "Fill in Writer and Reader Id and Key with the same values that are configured in the server appsettings.json."}</li>
        <li>${isRu ? "Нажмите проверку технических пользователей. Модуль проверит, что Reader может читать данные, а Writer выполнять операции записи." : "Run the technical-user check. The module verifies that Reader can read data and Writer can perform write operations."}</li>
        <li>${isRu ? "Сохраните изменения." : "Save changes."}</li>
      </ol>

      <h2>${isRu ? "Технические пользователи" : "Technical users"}</h2>
      <p>${isRu
        ? "Reader и Writer не являются игроками сервера и не являются пользователями Foundry. Это технические учетные записи Basic Authentication, которые модуль использует при запросах к серверу."
        : "Reader and Writer are not server players and are not Foundry users. They are Basic Authentication technical accounts used by the module when it sends requests to the server."}</p>
      <ul>
        <li>${isRu ? "Reader читает каталог, изображения карточек и данные игроков." : "Reader reads the catalog, card images, and player data."}</li>
        <li>${isRu ? "Writer выдает и списывает карточки, создает и изменяет игроков, подтверждает игровые запросы." : "Writer gives and spends cards, creates and edits players, and confirms game requests."}</li>
      </ul>
      <div class="notice">${isRu
        ? "Id и Key технических пользователей хранятся в настройках мира Foundry. Игроки не видят поля настройки, но их браузеры используют эти значения для работы модуля. Не публикуйте эти ключи в открытом доступе."
        : "Technical user Id and Key values are stored in the Foundry world settings. Players do not see the settings fields, but their browsers use these values while the module works. Do not publish these keys."}</div>

      <h2>${isRu ? "Привязка игроков" : "Player binding"}</h2>
      <p>${isRu
        ? "После успешного подключения откройте окно управления игроками в меню Карточек Крипты. Для каждого участника Foundry привяжите игрока сервера. Если игрока сервера еще нет, создайте его в реестре игроков и вернитесь к привязке."
        : "After a successful connection, open player management from the Kripta Cards menu. Bind each Foundry user to a server player. If the server player does not exist yet, create it in the player registry and return to binding."}</p>
    </section>
  `;
}

function renderServerDocs(locale, h) {
  const isRu = locale === "ru";
  const appsettingsExample = `{
  "UserAuth": {
    "Users": [
      {
        "Id": "kripta-writer",
        "Key": "replace-with-long-random-secret",
        "Role": "Writer"
      },
      {
        "Id": "kripta-reader",
        "Key": "replace-with-another-long-random-secret",
        "Role": "Reader"
      }
    ]
  },
  "Cors": {
    "AllowedOrigins": [
      "https://your-foundry.example.com",
      "http://localhost:30000"
    ]
  },
  "Kestrel": {
    "Endpoints": {
      "Http": {
        "Url": "http://0.0.0.0:61532"
      }
    }
  },
  "AllowedHosts": "*"
}`;

  return `
    ${h.pageIntro(
      isRu ? "Настройка сервера" : "Server setup",
      isRu
        ? "Сервер контента запускается отдельно от Foundry VTT и предоставляет REST API для модуля. Основная настройка выполняется в appsettings.json."
        : "The content server runs separately from Foundry VTT and provides the REST API for the module. Most setup is done in appsettings.json."
    )}
    <section class="text-flow">
      <h2>${isRu ? "Рабочая папка" : "Working folder"}</h2>
      <p>${isRu
        ? "Распакуйте архив сервера в отдельную папку. Рядом с исполняемым файлом должны лежать appsettings.json, README.md, nlog.config и каталог Content."
        : "Extract the server archive into a dedicated folder. appsettings.json, README.md, nlog.config, and the Content directory should be next to the executable."}</p>
      <p>${isRu
        ? "Каталог Content содержит CardsReg.json, изображения карточек и папку SQLite. База Content/SQLite/players.db создается автоматически при первом запуске, поэтому у процесса сервера должны быть права на запись в Content/SQLite."
        : "The Content directory contains CardsReg.json, card images, and the SQLite folder. Content/SQLite/players.db is created automatically on first start, so the server process must be able to write to Content/SQLite."}</p>

      <h2>appsettings.json</h2>
      <p>${isRu
        ? "Минимально важные блоки настроек выглядят так:"
        : "The most important settings blocks look like this:"}</p>
      ${h.codeBlock(appsettingsExample, "json")}

      <h3>UserAuth</h3>
      <p>${isRu
        ? "В UserAuth задаются технические пользователи. Оставьте роли Writer и Reader, но замените Id и Key на свои значения. Используйте разные длинные ключи для Reader и Writer."
        : "UserAuth defines technical users. Keep the Writer and Reader roles, but replace Id and Key with your own values. Use different long keys for Reader and Writer."}</p>
      <ul>
        <li>${isRu ? "Reader нужен для чтения каталога, изображений, игроков и выданных карточек." : "Reader is used to read the catalog, images, players, and issued cards."}</li>
        <li>${isRu ? "Writer нужен для операций изменения: выдачи, списания, создания игроков и подтверждения запросов." : "Writer is used for write operations: giving cards, spending cards, creating players, and confirming requests."}</li>
      </ul>

      <h3>CORS</h3>
      <p>${isRu
        ? "В Cors:AllowedOrigins укажите все адреса, по которым браузеры мастера и игроков открывают Foundry VTT. Указывается origin целиком: протокол, домен или IP и порт. Путь после домена не добавляется."
        : "In Cors:AllowedOrigins, list every address used by the Game Master and players to open Foundry VTT. Use the full origin: protocol, domain or IP, and port. Do not include a path after the domain."}</p>
      <p>${isRu
        ? "Если Foundry доступна как https://foundry.example.com/game, в CORS пишите https://foundry.example.com. Если игроки заходят локально через http://localhost:30000, добавьте и этот origin."
        : "If Foundry is available as https://foundry.example.com/game, put https://foundry.example.com into CORS. If players connect locally through http://localhost:30000, add that origin too."}</p>

      <h3>Kestrel</h3>
      <p>${isRu
        ? "Kestrel:Endpoints:Http:Url задает адрес, на котором слушает сам сервер. Значение http://0.0.0.0:61532 означает, что сервер слушает порт 61532 на всех сетевых интерфейсах. За IIS-прокси обычно можно оставить внутренний HTTP-адрес, а наружу публиковать HTTPS на IIS."
        : "Kestrel:Endpoints:Http:Url controls where the server listens. http://0.0.0.0:61532 means the server listens on port 61532 on all network interfaces. Behind an IIS proxy, it is usually fine to keep this internal HTTP address and publish HTTPS through IIS."}</p>

      <h2>${isRu ? "Проверочный запуск" : "Test run"}</h2>
      <p>${isRu
        ? "Запустите сервер из его рабочей папки:"
        : "Start the server from its working folder:"}</p>
      ${h.codeBlock(`dotnet KriptaCardsWebServer.dll`, "powershell")}
      <p>${isRu
        ? "После запуска проверьте в браузере:"
        : "After startup, check these URLs in a browser:"}</p>
      <ul>
        <li><code>/api/Health/check</code> - ${isRu ? "сервер запущен" : "server is running"}</li>
        <li><code>/swagger</code> - ${isRu ? "страница API" : "API page"}</li>
        <li><code>/readme</code> - ${isRu ? "README сервера" : "server README"}</li>
        <li><code>/api/Health/check-me</code> - ${isRu ? "проверка текущего Basic Authentication пользователя" : "current Basic Authentication user check"}</li>
      </ul>

      <h2>IIS</h2>
      <p>${isRu
        ? "Если сервер опубликован через IIS reverse proxy, модуль Foundry должен указывать публичный HTTPS-адрес IIS. В appsettings.json CORS все равно должен содержать origin Foundry VTT, а не адрес этого сайта загрузок."
        : "If the server is published through an IIS reverse proxy, the Foundry module should use the public IIS HTTPS address. appsettings.json CORS should still contain the Foundry VTT origin, not this downloads-site address."}</p>
      <div class="notice">${isRu
        ? "Перед установкой сервера как службы сначала добейтесь успешного ручного запуска и успешной проверки из модуля Foundry."
        : "Before installing the server as a service, first make sure manual startup works and the Foundry module check succeeds."}</div>
    </section>
  `;
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
