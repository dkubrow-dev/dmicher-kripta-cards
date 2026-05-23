export const config = {
  origin: "https://example.com",
  defaultLocale: "en",
  defaultTheme: "dark",
  settingsCookieName: "settings",
  locales: [
    { code: "en", label: "English", shortLabel: "EN" },
    { code: "ru", label: "Русский", shortLabel: "RU" }
  ],
  siteName: {
    en: "Kripta Cards",
    ru: "Карточки Крипты"
  },
  siteDescription: {
    en: "Downloads, documentation, and publication notes for the Kripta Cards Foundry VTT module and content server.",
    ru: "Загрузки, документация и сведения о публикации модуля Foundry VTT и сервера контента Карточек Крипты."
  },
  storage: {
    currentProvider: "local",
    localBasePath: "/files",
    futureProviders: ["s3-compatible", "backblaze-b2", "github-releases"]
  },
  repositories: [
    {
      label: {
        en: "Project repository",
        ru: "Репозиторий проекта"
      },
      href: "https://github.com/dkubrow-dev/dmicher-kripta-cards"
    },
    {
      label: {
        en: "Foundry VTT module page",
        ru: "Страница модуля на Foundry VTT"
      },
      href: "https://foundryvtt.com/packages/dmicher-kripta-cards"
    }
  ],
  author: {
    name: "dmicher abathur kubrow",
    license: {
      name: "Apache License 2.0",
      href: "https://github.com/dkubrow-dev/dmicher-kripta-cards/blob/main/LICENSE"
    },
    contacts: [
      {
        id: "github-issues",
        label: {
          en: "GitHub issues",
          ru: "GitHub Issues"
        },
        href: "https://github.com/dkubrow-dev/dmicher-kripta-cards/issues",
        note: {
          en: "For bug reports, reproducible problems, and public feature requests.",
          ru: "Для сообщений об ошибках, воспроизводимых проблем и публичных предложений."
        }
      },
      {
        id: "boosty",
        label: {
          en: "Boosty",
          ru: "Boosty"
        },
        href: "https://boosty.to/dmicher",
        note: {
          en: "For optional donations and project updates.",
          ru: "Для добровольных донатов и обновлений проекта."
        }
      }
    ]
  },
  foundry: {
    packageId: "dmicher-kripta-cards",
    listingUrl: "https://foundryvtt.com/packages/dmicher-kripta-cards",
    manifestUrl: "https://github.com/dkubrow-dev/dmicher-kripta-cards/releases/latest/download/module.json"
  }
};

export const aiStatuses = {
  "human-authored": {
    en: {
      label: "Human-authored",
      description: "Created by a person without generated prepared content."
    },
    ru: {
      label: "Создано человеком",
      description: "Создано человеком без сгенерированного подготовленного контента."
    }
  },
  "human-reviewed": {
    en: {
      label: "Human-reviewed",
          description: "AI-generated or largely AI-produced material that has been reviewed, edited, and accepted by humans."
    },
    ru: {
      label: "Проверено человеком",
      description: "Полностью или в преобладающей части сгенерированный или подготовленный ИИ материал, проверенный, откорректированный и принятый человеком."
    }
  },
  "ai-assisted": {
    en: {
      label: "AI-assisted",
          description: "Contains material prepared with partial participation of AI, verified, largely transformed and accepted by humans."
    },
    ru: {
      label: "С участием ИИ",
        description: "Содержит материал, подготовленный с частичным участием ИИ, проверенный, в значительной части преобразованный и принятый человеком."
    }
  },
  "machine-translated": {
    en: {
      label: "Machine-translated",
          description: "Translation created by software without human control."
    },
    ru: {
      label: "Машинный перевод",
      description: "Перевод, созданный программно без контроля человека."
    }
  },
  "unreviewed-ai": {
    en: {
      label: "Unreviewed AI",
      description: "Generated material that has not been checked by a person."
    },
    ru: {
      label: "ИИ без проверки",
      description: "Сгенерированный материал, который не был проверен человеком."
    }
  },
  "not-applicable": {
    en: {
      label: "Not applicable",
      description: "Technical file or metadata where the AI content status is not relevant."
    },
    ru: {
      label: "Не применимо",
      description: "Технический файл или метаданные, для которых статус ИИ-контента не применим."
    }
  }
};

export const catalogs = {
  serverReleases: [
    {
      version: "1.1.1",
      status: "planned",
      recommended: true,
      date: null,
      moduleCompatibility: "1.1.1",
      foundryCompatibility: "13-14",
      aiStatus: "not-applicable",
      files: [
        {
          label: "Windows x64 ZIP",
          href: "/files/server/kripta-cards-content-server-1.1.1-win-x64.zip",
          storage: "local",
          size: "TBD",
          sha256: "TBD"
        }
      ],
      notes: {
        en: "The first server build approved by Foundry support for publishing the module on the platform. Corresponds to version 1.1.1 of the module.",
        ru: "Первая сборка сервера, одобренная поддержкой Foundry для публикации модуля на платформе. Соответствует версии 1.1.1 модуля."
      }
    }
  ],
  moduleReleases: [
    {
      version: "1.1.1",
      status: "planned",
      recommended: true,
      date: null,
      manifestUrl: "https://github.com/dkubrow-dev/dmicher-kripta-cards/releases/latest/download/module.json",
      foundryUrl: "https://foundryvtt.com/packages/dmicher-kripta-cards",
      aiStatus: "ai-assisted",
      files: [
        {
          label: "Foundry module ZIP",
          href: "/files/module/dmicher-kripta-cards-1.1.1.zip",
          storage: "local",
          size: "TBD",
          sha256: "TBD"
        }
      ],
      notes: {
        en: "The first module build approved by Foundry support for publication on the platform. Corresponds to server version 1.1.1.",
        ru: "Первая сборка модуля, одобренная поддержкой Foundry для публикации модуля на платформе. Соответствует версии 1.1.1 сервера."
      }
    }
  ],
  languagePatches: [
    {
      locale: "de",
      languageName: "Deutsch",
      status: "planned",
      aiStatus: "machine-translated",
      moduleCompatibility: "1.1.1",
      batHref: "/files/language-patches/add-locale-de-1.1.1.bat",
      shHref: "/files/language-patches/add-locale-de-1.1.1.sh",
      sha256: "TBD"
    },
    {
      locale: "es",
      languageName: "Español",
      status: "planned",
      aiStatus: "machine-translated",
      moduleCompatibility: "1.1.1",
      batHref: "/files/language-patches/add-locale-es-1.1.1.bat",
      shHref: "/files/language-patches/add-locale-es-1.1.1.sh",
      sha256: "TBD"
    }
  ],
  contentPacks: [
    {
      id: "dmicher-kards",
      title: "dmicher-kards",
      status: "planned",
      aiStatus: "ai-assisted",
      serverCompatibility: "1.1.1",
      href: "/files/content-packs/dmicher-kards-1.1.1.zip",
      size: "TBD",
      sha256: "TBD",
      notes: {
        en: "Dmicher Cards. A content pack of 850 cards across 11 categories, balanced for D&D 5e2014.",
        ru: "Карточки Дмичера. Контентный пак на 850 карточек и 11 категорий, сбалансированные под D&D 5e2014."
      }
    },
    {
      id: "kripta-cards",
      title: "kripta-cards",
      status: "planned",
      aiStatus: "ai-assisted",
      serverCompatibility: "1.1.1",
      href: "/files/content-packs/kripta-cards-1.1.1.zip",
      size: "TBD",
      sha256: "TBD",
      notes: {
        en: "Kripta Cards. An old content pack of cards used on the Crypt server with updated images, created by the community for D&D 5e2014.",
        ru: "Карточки крипты. Старый контентный пак карточек, используемых на сервере Крипта с обновлёнными изображениями, созданный сообществом для D&D 5e2014."
      }
    }
  ]
};
