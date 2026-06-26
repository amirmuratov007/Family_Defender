# Heimdall iOS

Главный продукт Heimdall для iPhone - нативное приложение, а не сайт.

В текущем MVP это один iOS app target с выбором роли при первом запуске:

- `Я родитель`
- `Я ребёнок`

Позже этот app shell можно оставить одним приложением или разделить на два продукта:

- Heimdall Parent
- Heimdall Child

## Что уже есть в приложении

- Первый экран выбора роли.
- Родительская панель:
  - список подключённых детей;
  - статус безопасности;
  - лента тревог;
  - включение локальных уведомлений;
  - тестовая тревога;
  - запрос Family Controls.
- Детский режим:
  - подключение к родителю;
  - кнопка `Я в безопасности`;
  - проверка подозрительного сообщения;
  - создание тревоги при высоком риске.
- Локальное хранение семейного теста через `UserDefaults`.
- Локальные iOS-уведомления через `UserNotifications`.
- Share Extension для текста, который пользователь явно отправляет в Heimdall через Share Sheet.
- Device Activity Monitor Extension как основа Screen Time событий.
- Shield Configuration Extension как экран защитной паузы.
- `project.yml` для генерации Xcode-проекта через XcodeGen.

## Важное про уведомления

Сейчас MVP умеет показывать локальные уведомления на том же iPhone. Это нужно, чтобы протестировать UX родителя и ребёнка без backend.

Чтобы родитель получал push-уведомление на свой iPhone, когда риск возник на iPhone ребёнка, нужны:

- Apple Developer Program;
- Push Notifications capability;
- APNs key/certificate;
- backend для регистрации устройств и отправки тревог;
- согласованный семейный аккаунт или pairing flow.

## Как открыть на Mac

1. Установить Xcode.
2. Установить XcodeGen:

   ```sh
   brew install xcodegen
   ```

3. Сгенерировать проект:

   ```sh
   cd ios
   xcodegen generate
   open HeimdallFamilyProtection.xcodeproj
   ```

4. В Xcode выбрать свою Apple Developer Team для всех targets.

Можно сделать то же одной командой из корня репозитория:

```sh
ios/scripts/setup_macos.sh
```

## Targets

1. Main app
   Bundle ID: `com.heimdallgroup.familyprotection`

2. Share Extension
   Bundle ID: `com.heimdallgroup.familyprotection.share`

3. Device Activity Monitor Extension
   Bundle ID: `com.heimdallgroup.familyprotection.monitor`

4. Shield Configuration Extension
   Bundle ID: `com.heimdallgroup.familyprotection.shield`

Device Activity Report Extension можно добавить следующим target, когда понадобится экран статистики.

## Required Apple Capabilities

- App Groups: `group.com.heimdallgroup.familyprotection`
- Family Controls для main app, Device Activity Monitor и Shield Configuration
- Push Notifications для реальных тревог родителю на другой iPhone

## Free vs Paid Apple Account

Встроенный Apple Screen Time и Family Sharing на личных iPhone можно использовать без оплаты Apple Developer Program.

Для Heimdall как распространяемого приложения:

- бесплатный Apple Account подходит для входа на developer.apple.com, Xcode, документации и простых тестов на своих устройствах;
- TestFlight, App Store, push notifications и нормальная раздача другим людям требуют Apple Developer Program;
- Family Controls для TestFlight/App Store требует отдельного разрешения Apple на Family Controls Distribution entitlement.

## После оплаты Apple Developer Program

1. Создать App IDs:
   - `com.heimdallgroup.familyprotection`
   - `com.heimdallgroup.familyprotection.share`
   - `com.heimdallgroup.familyprotection.monitor`
   - `com.heimdallgroup.familyprotection.shield`

2. Создать App Group:
   - `group.com.heimdallgroup.familyprotection`

3. Включить Push Notifications для main app.

4. Запросить Family Controls Distribution entitlement:
   - использовать текст из `../APPLE_FAMILY_CONTROLS_REQUEST.md`

5. После одобрения Apple включить Family Controls в Additional Capabilities.

6. Сгенерировать provisioning profiles и собрать архив в Xcode.
