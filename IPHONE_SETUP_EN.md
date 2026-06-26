# Heimdall Family Protection: iPhone setup

This guide is for the parent. The child does not configure anything.

## 1. Prepare Apple Family Sharing

1. On the parent's phone, open `Settings`.
2. Tap the Apple ID name.
3. Open `Family`.
4. Add the child to the family group.
5. Make sure the child uses a child Apple ID.

## 2. Enable Screen Time

1. On the child's iPhone, open `Settings` -> `Screen Time`.
2. Enable `Screen Time`.
3. Choose `This is My Child's iPhone`.
4. Set a Screen Time passcode. Only the parent should know it.
5. Enable `Content & Privacy Restrictions`.

## 3. Block risky installs

In `Screen Time` -> `Content & Privacy`:

- `iTunes & App Store Purchases`: installs only with approval.
- `Account Changes`: do not allow.
- `Passcode Changes`: do not allow.
- `Cellular Data Changes`: do not allow.

## 4. Limit risky apps

In `App Limits`, set rules for:

- Telegram
- Discord
- WhatsApp, if time control is needed
- games and game chats
- browsers
- banking apps, if this is a child's phone

## 5. Block remote access

Block installation or remove:

- AnyDesk
- RustDesk
- TeamViewer
- AirDroid
- similar remote access tools

## 6. Add Heimdall to the Home Screen

1. Open the Heimdall site in Safari on the child's iPhone.
2. Tap `Share`.
3. Tap `Add to Home Screen`.
4. Name it `Heimdall`.
5. Tap `Add`.

## Important

A normal website or ordinary iOS app cannot secretly read Telegram on iPhone. A full production version needs a native Heimdall iOS module with Apple's Family Controls entitlement, a policy server and push notifications to the parent.
