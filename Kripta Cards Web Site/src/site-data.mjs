export const config = {
  origin: "https://kripta-cards.dmicher.su",
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
    manifestUrl: "https://kripta-cards.dmicher.su/files/module/module.json"
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
          "version": "1.1.1",
          "status": "published",
          "recommended": true,
          "date": "2026-05-23",
          "moduleCompatibility": "1.1.1",
          "foundryCompatibility": "13-14",
          "aiStatus": "not-applicable",
          "files": [
              {
                  "label": "Windows x64 ZIP",
                  "href": "/files/server/kripta-cards-content-server-1.1.1-win-x64.zip",
                  "storage": "local",
                  "size": "4.5 MB",
                  "sha256": "2b9cc1ff9888de5872af4a5a1f222a438d4c118a3e483960d54275cc83b01068"
              }
          ],
          "notes": {
              "en": "The first server build approved by Foundry support for publishing the module on the platform. Corresponds to version 1.1.1 of the module.",
              "ru": "Первая сборка сервера, одобренная поддержкой Foundry для публикации модуля на платформе. Соответствует версии 1.1.1 модуля."
          }
      }
  ],
  moduleReleases: [
      {
          "version": "1.1.1",
          "status": "published",
          "recommended": true,
          "date": "2026-05-23",
          "manifestUrl": "https://kripta-cards.dmicher.su/files/module/module.json",
          "foundryUrl": "https://foundryvtt.com/packages/dmicher-kripta-cards",
          "aiStatus": "ai-assisted",
          "files": [
              {
                  "label": "Foundry module ZIP",
                  "href": "/files/module/dmicher-kripta-cards-1.1.1.zip",
                  "storage": "local",
                  "size": "214 KB",
                  "sha256": "a9f4dee962758f414804a7a5e989ce9d04d3921e3f7ba056bfad0a22d877dbf9"
              }
          ],
          "notes": {
              "en": "The first module build approved by Foundry support for publication on the platform. Corresponds to server version 1.1.1.",
              "ru": "Первая сборка модуля, одобренная поддержкой Foundry для публикации модуля на платформе. Соответствует версии 1.1.1 сервера."
          }
      }
  ],
  languagePatches: [
      {
          "locale": "am",
          "languageName": "አማርኛ",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-am-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-am-1.1.1.sh",
          "sha256": "bat 18b96c6ee3a601a5207820f33369a8fb60f6da4eadf4393b73d7c471b21f4d13; sh e8377e99675d2115ed1e453b4e71b22b986a08a0c87ff6a76c437731ecb80ab6"
      },
      {
          "locale": "ar",
          "languageName": "العربية",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-ar-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-ar-1.1.1.sh",
          "sha256": "bat 1023a19c9a6498709fba0a4be37b9b7a8023348c659902a2cd2acbd790353394; sh 4aac11d19bb0b6443d48262af35f1aa6a23040dc2f7a941ed723ecefecee6023"
      },
      {
          "locale": "av",
          "languageName": "МагӀарул мацӀ",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-av-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-av-1.1.1.sh",
          "sha256": "bat e0cf7cd772b5bf56675d682a3d61aa1f76122466ef30b3728b5304d4ca0e8fd7; sh c19a65eb42b15bfc8da7d5e1d0ff1afa9d6ec30d2bd011861b3e082ac5de047c"
      },
      {
          "locale": "az",
          "languageName": "Azərbaycanca",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-az-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-az-1.1.1.sh",
          "sha256": "bat 74ea12c371f7ea56c9e4f75bd770a00bf68cdb5eb67c50333eb9d8b1e759c8c3; sh 4c5a7f259818e74546d19abd34a49061cc763ead5d25a68c8ad5da56d2df56aa"
      },
      {
          "locale": "ba",
          "languageName": "Башҡортса",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-ba-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-ba-1.1.1.sh",
          "sha256": "bat 1b6d553c7a09782f0287d27415aa77c9ca2cc162208a87b05aa42df0c834d061; sh 68f0923d96bb26e0927d1de5464f713c5fc1200d7adc79ac981bcf98ffaecc5b"
      },
      {
          "locale": "be",
          "languageName": "Беларуская",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-be-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-be-1.1.1.sh",
          "sha256": "bat aff10fc9db4fb3c4bd4a93d25b779153455df5449e03f6534d65263c6760efd2; sh 324c3c520a3af96abc67773128020b50387d9daaf5b908ca8202a03e6d00b2f1"
      },
      {
          "locale": "bn",
          "languageName": "বাংলা",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-bn-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-bn-1.1.1.sh",
          "sha256": "bat ffaee82fda5de03af4fabab38f5ecead10480069ef9bfc637ad2742b056df272; sh 50fcf346060b4712dff5a7f09f30aafe6e1c06ab7d0d7648fe6d6cecc336faa7"
      },
      {
          "locale": "ca",
          "languageName": "Català",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-ca-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-ca-1.1.1.sh",
          "sha256": "bat bbf7ec8128db79fa9103fef04ab99cab0e9030ac34bea2036d3bdfb750068500; sh d4b329857a96357cf0ae5a9ee1ebf8a09dc3c9332dd4715c487299785fdd704d"
      },
      {
          "locale": "ce",
          "languageName": "Нохчийн",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-ce-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-ce-1.1.1.sh",
          "sha256": "bat 6e754c5391a95c7a698e61a5b5ec37e0fb185da20c167e636c1561e3c4f6c396; sh fcbc5c82a6bb7c2f1b6364caf048a1fa613edce066666510556860e06c0310ff"
      },
      {
          "locale": "cs",
          "languageName": "Čeština",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-cs-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-cs-1.1.1.sh",
          "sha256": "bat b35fa97b065dc510136761a6f4daf7790952a37cbf15b38872d75189eec62b30; sh f4acb8b70965fd3d00789fdd348df839c61d862a006ee18d3bb871db652fe216"
      },
      {
          "locale": "de",
          "languageName": "Deutsch",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-de-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-de-1.1.1.sh",
          "sha256": "bat 22c92b2046e116a1faacfedfc091d72593760aee904ee15cfd19ab62a71800f4; sh 11a377b0f91155cae4f5f696d72a76df4698e27afedcb0cd1454e1b0bbd430a1"
      },
      {
          "locale": "es",
          "languageName": "Español",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-es-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-es-1.1.1.sh",
          "sha256": "bat 63632b4c05d6c80452bdcbcc8d72a3e492d1caa6928cfeafa5c72fdd3da9370a; sh 33a606affed8a1b8052de2b79f17bf4ac14cc368c4fa02f3dde1648e6a205f7d"
      },
      {
          "locale": "fr",
          "languageName": "Français",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-fr-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-fr-1.1.1.sh",
          "sha256": "bat a89568d5d7c3569302922b500bb98be39735cd912222d0b3eddba71e685e9fb3; sh 3799cda7cb299c05533148cc8b53a2c370329e217408dd65f4aae8779eb783b5"
      },
      {
          "locale": "ha",
          "languageName": "Hausa",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-ha-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-ha-1.1.1.sh",
          "sha256": "bat ae721454d778dbc94f527ccca206b4915ecebf076c3c346443eda2279022b453; sh c9e22e5a0c0ccd519418864278e13092ffe71eb50e4a1870f72ae8976e27411a"
      },
      {
          "locale": "hi",
          "languageName": "हिन्दी",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-hi-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-hi-1.1.1.sh",
          "sha256": "bat 765c7d575dc11c833ae4482a6d905d6e7390844b5f8905a06823df7d1ab8681d; sh f1473fa78a86d102736d5098509afecd5076240591a36a8769810d810852f2ec"
      },
      {
          "locale": "hu",
          "languageName": "Magyar",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-hu-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-hu-1.1.1.sh",
          "sha256": "bat 43c2fd8cd8f781a890e63bf848ac075878d9401a76a492af62f59b771e68dc73; sh fc00ad506d03a33eb47bb465b9fd4a940e699a72d6b657b40efc4eaddfe2e690"
      },
      {
          "locale": "hy",
          "languageName": "Հայերեն",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-hy-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-hy-1.1.1.sh",
          "sha256": "bat 2bb287838df6991738f9d37b3a9f42129505cf13c0b480c60b63cda433150abb; sh 69b1583e0b324e2a16475dc4213b45694f340ff2dfc12a913798dd97c268fd4e"
      },
      {
          "locale": "id",
          "languageName": "Bahasa Indonesia",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-id-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-id-1.1.1.sh",
          "sha256": "bat 1f9c13a90ceb95e68f002170c5765cdfe46a17e4e7a0d2fe103f05d979faa23e; sh e6ad0a06cc2723173efb52fcb306a0c1c9de4e80b0adea00f9a7e1dc4b00229f"
      },
      {
          "locale": "ig",
          "languageName": "Igbo",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-ig-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-ig-1.1.1.sh",
          "sha256": "bat 085665ab4cc1423d941ae6aeaf37017e10c1e88573dc5f75d020ed814adec5eb; sh 45824ecd6e68ee16946b09e781747c3b680c227e1029648cb7ab8579afe0b4d5"
      },
      {
          "locale": "ja",
          "languageName": "日本語",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-ja-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-ja-1.1.1.sh",
          "sha256": "bat 7f05fe0640a0d04f941b9e411ad2dbe92b941a30a3961a841c0c1ef2479cb565; sh 6f641109bf351785d6f7ef205dc6a9510875b136468cc82f49116a6a8a1f192a"
      },
      {
          "locale": "ka",
          "languageName": "ქართული",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-ka-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-ka-1.1.1.sh",
          "sha256": "bat 3158b5752fc351a46fd8a7ab76839421fe9c46ac177da669b4fa3e1c93833a1a; sh 04d93d50d700aa748560b8c57366cec633624a348d09ccb90a618486e36634c3"
      },
      {
          "locale": "kbd",
          "languageName": "Адыгэбзэ",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-kbd-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-kbd-1.1.1.sh",
          "sha256": "bat fc5b5e577b0a2c20f3fcfc5aac589c5d532a9987fd1858cd2acd8fa5683b4764; sh 83c41732e50569372a64e7e7f9fae81b05125391a5b7390dedeae57c6e9e3dfa"
      },
      {
          "locale": "kk",
          "languageName": "Қазақша",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-kk-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-kk-1.1.1.sh",
          "sha256": "bat c6b14fba419cc6c838d84a42b4db09a75cc2251bdd39c8fa43b8440fecfd49b2; sh e9029a31c8ea0e923c9f1be3096ebdf3bfa2b161582a0bba3bd82f40277a231e"
      },
      {
          "locale": "ko",
          "languageName": "한국어",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-ko-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-ko-1.1.1.sh",
          "sha256": "bat 45a387146d15688df77994070c55b6a777014853def31db0c472d0179c1b8ae9; sh 2f30cc1d5ab3fef00ca7f92627d7a6f700fd67d4b3a9dcf293bb1bcb74bb68f8"
      },
      {
          "locale": "ky",
          "languageName": "Кыргызча",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-ky-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-ky-1.1.1.sh",
          "sha256": "bat 37680564abf2d311eb60a969e60fdfe0ede0f319a82dc08bf14aef67c4653492; sh 84c5c45201e50b28e95a26a3b9f3886e76246e33b4234426e0ba826bc74b0a3e"
      },
      {
          "locale": "om",
          "languageName": "Afaan Oromoo",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-om-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-om-1.1.1.sh",
          "sha256": "bat 3170ff54e1d949a2d82f8001f7009a80f7b5aba8968d8a239598c1f2b9e76266; sh bce6e651f76c950bfa7c632a9c882f2ace29132c975a19061321c2a939b6797d"
      },
      {
          "locale": "pl",
          "languageName": "Polski",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-pl-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-pl-1.1.1.sh",
          "sha256": "bat d96b91f8980411e9c1dff09d39424abebc4e7f2289b9a81772f1a7da4455f0b2; sh 7130681cef390e52804c4ed2b5196161dcb21dab98ad8e0303595f99605c424e"
      },
      {
          "locale": "pt",
          "languageName": "Português",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-pt-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-pt-1.1.1.sh",
          "sha256": "bat 01eb5728fd05773353468d86f1ef1d461da040a58dba47dd3838a1c7229915bb; sh 9a33170ab019d6706296d5ea90b6621c2c585e225a3c217d0a05f6ff28fc788f"
      },
      {
          "locale": "ro-MD",
          "languageName": "Română (Moldova)",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-ro-MD-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-ro-MD-1.1.1.sh",
          "sha256": "bat 31f6ab27f50b7476758107d66baf9c32560517c0d2b2de58b33a1684f4c9f0b7; sh 7701e1fc0a74be18a42e75338f1951cd33a15bd646f6a1b5af56bbe57e2e7b9a"
      },
      {
          "locale": "sv",
          "languageName": "Svenska",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-sv-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-sv-1.1.1.sh",
          "sha256": "bat b84af905a91ac5583213a49e2e47140df78979abf85ee1d1c9b7e5af7f518a45; sh 441eff1bdc1fd89b2a756d4ef845e9aa05f9fe40524dde36539910a9fe2079f0"
      },
      {
          "locale": "sw",
          "languageName": "Kiswahili",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-sw-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-sw-1.1.1.sh",
          "sha256": "bat c3095da0d18f8a3bbb66d7df600042b2a9bf66cfe4a40593243009109840cdb1; sh 5febd320e62cdfed493bc0ee274d48d693a1c760f87b9d5a9d129217496e80e2"
      },
      {
          "locale": "tg",
          "languageName": "Тоҷикӣ",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-tg-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-tg-1.1.1.sh",
          "sha256": "bat 4f2353296751680721661ccd0ee73bc719fb7a33da52b61731bc59b60142bfc9; sh 12d4534e399249a29331d5fcaa92c8aeb2c5759bf6b2aa34ca236cafda2cac19"
      },
      {
          "locale": "th",
          "languageName": "ไทย",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-th-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-th-1.1.1.sh",
          "sha256": "bat e4adedb88649eb121ec7d723ea46fcc11f24ed28204890fed8b8e008659acf82; sh ebdf86d1ecdccb0e019e156199c681c06f76152e10efc27e7f8c6c27e30ab100"
      },
      {
          "locale": "tt",
          "languageName": "Татарча",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-tt-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-tt-1.1.1.sh",
          "sha256": "bat c84ae918c8d76f40ee81f246b0cfcd7407d04e0de9be78c2b2fae5501dc464aa; sh ea743951476a1fb30526f48c601d62980e18a079aaff3b2fcf90a8a5c585a167"
      },
      {
          "locale": "uk",
          "languageName": "Українська",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-uk-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-uk-1.1.1.sh",
          "sha256": "bat 4baa7a0341df672cc79f50a3e24102fd55588daedd75a3c0e6946d2b84c49dbc; sh 6a3fb91a6d88e2f21d47b863a0959d89fe9c20036c0a2035a9d0fd0837e50598"
      },
      {
          "locale": "ur",
          "languageName": "اردو",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-ur-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-ur-1.1.1.sh",
          "sha256": "bat f218a613e5c50d5be5b5d75034e7c376a99bf3fd2d6f95eb3f42067d0d7060e3; sh 932e51ab3384cc6fcb8625e4b441111dbfd240f3a091d69085c894ef923e3cfa"
      },
      {
          "locale": "uz",
          "languageName": "Oʻzbekcha",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-uz-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-uz-1.1.1.sh",
          "sha256": "bat 3fd1b21433e07c492fdd4d6c6be49919741dfc7d345dd62cbe7fc661a3d29e78; sh c604211a13fd8f5d0b2905427e99459441dcc572eb02d030af51514b60fc7171"
      },
      {
          "locale": "yo",
          "languageName": "Yorùbá",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-yo-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-yo-1.1.1.sh",
          "sha256": "bat 1c9fd5f9f35219058dd3c98a156a4d39a0fda4ed662ac940cc9e95c91862401a; sh f587189f19c4bc05c361459dcbaf36d391b7167811839f0bd87a15049a6a5fc7"
      },
      {
          "locale": "zh-CN",
          "languageName": "简体中文",
          "status": "published",
          "aiStatus": "machine-translated",
          "moduleCompatibility": "1.1.1",
          "batHref": "/files/language-patches/add-locale-zh-CN-1.1.1.bat",
          "shHref": "/files/language-patches/add-locale-zh-CN-1.1.1.sh",
          "sha256": "bat ed1e9160deda4998fcaa853a263f397700e210ca06514672b785f608663a1d21; sh a8355bd546b76b17495974eba110e4ea1844a0f5e46168eef4d00a35e976b90a"
      }
  ],
  contentPacks: [
      {
          "id": "dmicher-kards",
          "title": "dmicher-kards",
          "status": "planned",
          "aiStatus": "ai-assisted",
          "serverCompatibility": "1.1.1",
          "href": "/files/content-packs/dmicher-kards-1.1.1.zip",
          "size": "TBD",
          "sha256": "TBD",
          "notes": {
              "en": "Dmicher Cards. A content pack of 850 cards across 11 categories, balanced for D&D 5e2014.",
              "ru": "Карточки Дмичера. Контентный пак на 850 карточек и 11 категорий, сбалансированные под D&D 5e2014."
          }
      },
      {
          "id": "kripta-cards",
          "title": "kripta-cards",
          "status": "published",
          "aiStatus": "ai-assisted",
          "serverCompatibility": "1.1.1",
          "href": "/files/content-packs/kripta-cards-1.1.1.zip",
          "size": "437.0 MB",
          "sha256": "a93f6f682a096a1d05b692add62d5dd383aa57c28b7562c4d034a4d63851590b",
          "notes": {
              "en": "Kripta Cards. An old content pack of cards used on the Crypt server with updated images, created by the community for D&D 5e2014.",
              "ru": "Карточки крипты. Старый контентный пак карточек, используемых на сервере Крипта с обновлёнными изображениями, созданный сообществом для D&D 5e2014."
          }
      }
  ]
};
