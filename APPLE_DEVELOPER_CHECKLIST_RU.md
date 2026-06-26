# Apple Developer Checklist

## 1. Enroll

1. Open https://developer.apple.com/enroll/
2. Join the Apple Developer Program.
3. Choose Individual for a personal account or Organization for Heimdall-Group as a company.
4. Complete payment and identity verification.

## 2. Create Identifiers

Open:

https://developer.apple.com/account/resources/identifiers/list

Create these App IDs:

- com.heimdallgroup.familyprotection
- com.heimdallgroup.familyprotection.monitor
- com.heimdallgroup.familyprotection.shield
- com.heimdallgroup.familyprotection.report
- com.heimdallgroup.familyprotection.share

Enable capabilities when available:

- App Groups
- Push Notifications
- Sign in with Apple, if user accounts are added
- Family Controls, after Apple approves it

Suggested App Group:

group.com.heimdallgroup.familyprotection

## 3. App Store Connect

Open:

https://appstoreconnect.apple.com/apps

Create app:

- Name: Heimdall Family Protection
- Primary language: English
- Bundle ID: com.heimdallgroup.familyprotection
- SKU: heimdall-family-protection-ios
- User access: Full Access for the account owner

## 4. Request Family Controls

Open:

https://developer.apple.com/contact/request/family-controls-distribution

Use the text from `APPLE_FAMILY_CONTROLS_REQUEST.md`.

## 5. After Approval

For each approved identifier:

1. Open Identifiers.
2. Select the App ID.
3. Open Additional Capabilities.
4. Enable Family Controls for App Store distribution.
5. Regenerate provisioning profiles.
6. Rebuild in Xcode.

## 6. App Store Review Notes

Use `APP_STORE_REVIEW_NOTES.md` when submitting the first build.
