# Heimdall iOS Starter

This folder is a production-oriented starter for the native iOS app.

It is not a complete Xcode project yet. After Apple Developer Program enrollment, create an Xcode iOS app and copy these files into the matching targets.

## Targets to Create

1. Main app
   Bundle ID: `com.heimdallgroup.familyprotection`

2. Share Extension
   Bundle ID: `com.heimdallgroup.familyprotection.share`

3. Device Activity Monitor Extension
   Bundle ID: `com.heimdallgroup.familyprotection.monitor`

4. Shield Configuration Extension
   Bundle ID: `com.heimdallgroup.familyprotection.shield`

5. Device Activity Report Extension
   Bundle ID: `com.heimdallgroup.familyprotection.report`

## Required Apple Capabilities

- Family Controls
- App Groups
- Push Notifications

Suggested app group:

`group.com.heimdallgroup.familyprotection`

## Screen Time Frameworks

The code references:

- FamilyControls
- ManagedSettings
- DeviceActivity

These APIs require Apple approval for distribution.
