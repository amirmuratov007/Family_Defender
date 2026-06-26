# Apple Family Controls entitlement request package

Use this content when requesting the Family Controls entitlement from Apple Developer.

## Product name

Heimdall Family Protection

## Primary bundle ID

Replace with the final Apple Developer Bundle ID:

`group.heimdall.familyprotection`

## Extension bundle IDs

If the production app includes Device Activity extensions, request entitlement for each target that uses Screen Time APIs:

- `group.heimdall.familyprotection.monitor`
- `group.heimdall.familyprotection.report`
- `group.heimdall.familyprotection.shield`

## Short description

Heimdall Family Protection is a transparent parental safety app that helps parents protect children and elderly family members from online fraud, coercion, remote-access scams and risky app behavior.

## Entitlement justification

Heimdall needs Apple Family Controls, Managed Settings and Device Activity APIs to let parents configure family safety rules on a child's iPhone. The app is designed to help parents restrict or shield risky apps, block remote-access tools, limit messenger usage, monitor app-category events and receive safety alerts when risky behavior patterns occur, such as game chat to private messenger transitions, remote-access installation attempts, or banking-app activity immediately after messenger usage.

Heimdall does not secretly read private message content and does not attempt to bypass end-to-end encryption. The app uses Apple-approved parental-control mechanisms and requires parent authorization through Apple's Screen Time / Family Controls flow.

## User benefit

Children and elderly relatives are frequently targeted by scammers who pressure them through messengers, gaming chats and remote-access tools. Heimdall gives parents a legitimate safety layer to stop dangerous actions before financial loss, account compromise or coerced behavior occurs.

## Privacy position

Heimdall is designed around data minimization. Parents receive safety signals, rule status and risk reasons. The app does not collect full private conversations, does not run covert surveillance and does not expose private message content to parents.

## App Store review positioning

Category: parental controls / family safety.

The app should be positioned as transparent family protection, not spyware, monitoring, covert tracking or private-message interception.

## Apple form notes

- Submit the request from the Apple Developer Account Holder account.
- Use the production App ID / Bundle ID.
- If DeviceActivityMonitor, DeviceActivityReport or Shield extensions are included, request entitlement for those bundle IDs too.
- After approval, regenerate provisioning profiles and enable the capability in Xcode.

## Follow-up after approval

1. Enable Family Controls capability for the approved App IDs.
2. Regenerate development and distribution provisioning profiles.
3. Add entitlements to the main app and extensions.
4. Archive in Xcode.
5. Validate and upload to TestFlight.
