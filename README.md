# EmilGram

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS-blue?style=flat-square&logo=apple" />
  <img src="https://img.shields.io/badge/Swift-5-orange?style=flat-square&logo=swift" />
  <img src="https://img.shields.io/badge/UIKit-Storyboard-purple?style=flat-square" />
  <img src="https://img.shields.io/badge/Architecture-MVP-green?style=flat-square" />
</p>

<p align="center">
  iOS-клиент для просмотра фотографий из <b>Unsplash</b>.<br/>
  Авторизация через OAuth 2.0, лента изображений с бесконечным скроллом, профиль пользователя.
</p>

---

## Возможности

| Экран | Описание |
|-------|----------|
| **Splash** | Стартовый экран с проверкой токена авторизации |
| **Auth** | Авторизация через Unsplash OAuth 2.0 (WebView) |
| **Image Feed** | Бесконечная лента фотографий с лайками |
| **Single Image** | Полноэкранный просмотр с зумом и шерингом |
| **Profile** | Профиль пользователя с аватаром и возможностью выйти |

## Стек технологий

- **Язык:** Swift 5
- **UI:** UIKit + Storyboard
- **Архитектура:** MVP (Model-View-Presenter)
- **Сеть:** URLSession
- **Авторизация:** OAuth 2.0 (Unsplash API)
- **Хранение токена:** Keychain / UserDefaults
- **Загрузка изображений:** Kingfisher / кастомный сервис
- **Shimmer-эффект:** кастомная реализация для плейсхолдеров
- **Тесты:** XCTest (Unit + UI)

## Архитектура

```
EmilGram/
├── Models/              # Модели данных (Profile, Photo, OAuth)
├── Services/            # Сетевые сервисы, хранение токена, логаут
├── Helpers/             # Расширения UIView, URLSession, HUD
├── View's/
│   ├── Auth/            # Авторизация (WebView + Presenter)
│   ├── ImageList/       # Лента фотографий (Presenter + VC)
│   ├── ProfileView/     # Профиль пользователя
│   ├── Splash/          # Splash-экран
│   └── TabBarController
└── Storyboards/         # Storyboard-файлы
```

## Требования

- iOS 13.0+
- Xcode 14+

## Запуск

1. Клонируйте репозиторий:
   ```bash
   git clone https://github.com/EmilAxme/EmilGram.git
   ```
2. Откройте `EmilGram.xcodeproj` в Xcode
3. Укажите свои ключи Unsplash API в `AuthConfiguration.swift`
4. Запустите на симуляторе или устройстве (⌘R)

## Автор

**Emil** — [@EmilAxme](https://github.com/EmilAxme)

---

<p align="center">
  <i>Учебный проект, вдохновлённый Instagram</i>
</p>
