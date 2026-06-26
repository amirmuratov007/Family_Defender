# Heimdall Family Protection

Heimdall-Group Family Protection is a parent-controlled anti-scam product for children and elderly relatives.

The product focuses on risky moments:

- a stranger moves from a game chat to a private messenger;
- someone asks for secrecy from parents;
- someone requests SMS codes, passwords, money, cards, address, photos, documents, or remote access;
- a messenger conversation is followed by banking or remote-access behavior.

## Current Repository Contents

- `ios/` - native iOS app with parent/child role selection, local alerts, local notifications and Family Controls starter code.
- `index.html`, `ru.html`, `en.html` - public product site and web demo, not the main child-safety product.
- `style.css`, `network.js` - visual system and animated background.
- `api/analyze.js` - serverless API endpoint for risk analysis.
- `api/health.js` - serverless health endpoint.
- `lib/risk-engine.js` - shared scam-pattern risk engine.
- `APPLE_FAMILY_CONTROLS_REQUEST.md` - Apple entitlement request text.
- `APPLE_DEVELOPER_CHECKLIST_RU.md` - step-by-step Apple setup checklist.
- `APP_STORE_REVIEW_NOTES.md` - App Store Review notes.
- `RELEASE_NOTES_20_IMPROVEMENTS_RU.md` - latest package of 20 native-app improvements.
- `PRIVACY_POLICY.md` - draft privacy policy.
- `SECURITY_MODEL.md` - production security model.

## Local Run

```bash
npm test
npm start
```

Open:

```text
http://127.0.0.1:8788
```

Risk API:

```bash
curl -X POST http://127.0.0.1:8788/api/analyze \
  -H "content-type: application/json" \
  -d "{\"text\":\"Перейдем в телеграм. Родителям не говори. Срочно открой банк и пришли код.\"}"
```

## Vercel

The static site and `/api/*` serverless functions can be deployed on Vercel from this repository.

## iOS App Reality

The main product is the native iOS app in `ios/`.

An ordinary website cannot silently read Telegram, WhatsApp, Discord, or other private messenger content on iPhone.

The real iPhone product requires:

- native iOS app;
- Apple Developer Program enrollment;
- Family Controls Distribution entitlement approval;
- Device Activity / Managed Settings implementation;
- parent account and push notification backend.

The current iOS MVP already has a first-screen parent/child role choice, parent dashboard, child safety screen, local risk alerts and local iOS notifications. Real cross-device parent notifications require APNs and a backend.

## Apple Next Step

After joining the Apple Developer Program, follow:

`APPLE_DEVELOPER_CHECKLIST_RU.md`

Then submit:

`APPLE_FAMILY_CONTROLS_REQUEST.md`

## iOS Build Prep

On a Mac with Xcode installed:

```bash
ios/scripts/setup_macos.sh
```

This installs XcodeGen if needed, generates `HeimdallFamilyProtection.xcodeproj`, and opens it in Xcode.
