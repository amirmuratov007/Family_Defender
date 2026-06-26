# Чеклист Apple Developer

## 1. Бесплатная регистрация

Ссылка:

https://developer.apple.com/register/

Бесплатная регистрация даёт вход в Apple Developer, Xcode downloads, форумы и тесты простых сборок на своих устройствах.

## 2. Платная программа

Ссылка:

https://developer.apple.com/programs/enroll/

Для TestFlight, App Store, push notifications, production provisioning profiles и нормальной раздачи приложения другим людям нужна Apple Developer Program.

Стоимость Apple указывает как 99 USD в год или местный эквивалент.

## 3. Identifiers

После подключения Apple Developer Program открыть:

https://developer.apple.com/account/resources/identifiers/list

Создать App IDs:

- `com.heimdallgroup.familyprotection`
- `com.heimdallgroup.familyprotection.share`
- `com.heimdallgroup.familyprotection.monitor`
- `com.heimdallgroup.familyprotection.shield`

Создать App Group:

- `group.com.heimdallgroup.familyprotection`

Включить capabilities, когда они доступны:

- App Groups
- Push Notifications
- Family Controls после одобрения Apple

## 4. App Store Connect

Открыть:

https://appstoreconnect.apple.com/apps

Создать приложение:

- Name: Heimdall Family Protection
- Primary language: English или Russian
- Bundle ID: `com.heimdallgroup.familyprotection`
- SKU: `heimdall-family-protection-ios`
- User access: Full Access for the account owner

## 5. Family Controls

Открыть:

https://developer.apple.com/contact/request/family-controls-distribution

Отправить текст из `APPLE_FAMILY_CONTROLS_REQUEST.md`.

Важно: запрос может отправить только Account Holder платной Apple Developer Program.

## 6. Xcode

На Mac:

```sh
cd ios
brew install xcodegen
xcodegen generate
open HeimdallFamilyProtection.xcodeproj
```

В Xcode выбрать Developer Team для всех target, затем собрать приложение.

## 7. После одобрения Family Controls

1. Открыть каждый App ID.
2. Включить Family Controls в Additional Capabilities.
3. Пересоздать provisioning profiles.
4. Собрать архив в Xcode.
5. Отправить первый build в TestFlight.

Для App Store Review использовать `APP_STORE_REVIEW_NOTES.md`.
