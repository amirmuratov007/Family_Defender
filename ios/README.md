# Heimdall iOS

Это стартовая iOS-версия Heimdall Family Defender: один app shell с режимом родителя и режимом ребёнка.

## Что уже есть

- Родительская панель: подключение Family Controls, базовые правила, доверенные взрослые и будущая лента тревог.
- Детский режим: проверка подозрительного сообщения, антискам-пауза и связь с доверенным взрослым.
- Share Extension: точка входа для текста, который пользователь явно отправляет в Heimdall через Share Sheet.
- Device Activity Monitor Extension: основа для риск-событий Screen Time.
- Shield Configuration Extension: русский экран защитной паузы.
- `project.yml` для генерации Xcode-проекта через XcodeGen.

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

4. В Xcode выбрать свою Apple Developer Team для всех target.

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
- Push Notifications, когда появится backend родительских тревог

## Free vs Paid Apple Account

Встроенный Apple Screen Time и Family Sharing на личных iPhone можно использовать без оплаты Apple Developer Program.

Для Heimdall как приложения:

- Бесплатный Apple Account подходит для входа на developer.apple.com, Xcode, документации и простых тестов на своих устройствах.
- TestFlight, App Store, push notifications и нормальная раздача другим людям требуют Apple Developer Program.
- Family Controls для TestFlight/App Store требует отдельного разрешения Apple на Family Controls Distribution entitlement.

## После оплаты Apple Developer Program

1. Создать App IDs в Apple Developer:
   - `com.heimdallgroup.familyprotection`
   - `com.heimdallgroup.familyprotection.share`
   - `com.heimdallgroup.familyprotection.monitor`
   - `com.heimdallgroup.familyprotection.shield`

2. Создать App Group:
   - `group.com.heimdallgroup.familyprotection`

3. Запросить Family Controls Distribution entitlement:
   - использовать текст из `../APPLE_FAMILY_CONTROLS_REQUEST.md`

4. После одобрения Apple включить Family Controls в Additional Capabilities для нужных App IDs.

5. Сгенерировать provisioning profiles и собрать архив в Xcode.
