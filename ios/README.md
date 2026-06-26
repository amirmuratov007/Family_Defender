# Heimdall iOS Starter

This folder is a production-oriented starter for the native iOS app.

It is not a complete Xcode project yet. After Apple Developer Program enrollment, create an Xcode iOS app and copy these files into the matching targets.

## Product Roles

The starter app now has two modes:

- Parent mode: family setup, trusted adults, alert feed, Screen Time / Family Controls authorization, and rule management.
- Child mode: suspicious-message check, anti-scam pause, and a call-to-trusted-adult action.

This can ship as one app with role selection for the MVP, or later split into two apps:

- Heimdall Parent
- Heimdall Child

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

## Free vs Paid Apple Account

Apple's built-in Screen Time and Family Sharing controls can be used by families without paying Apple.

For Heimdall as a distributed app:

- A free Apple Account is enough to start learning, open Xcode, and test simple builds on your own devices.
- TestFlight, App Store distribution, push notifications, and production Family Controls distribution require the paid Apple Developer Program.
- Family Controls also requires Apple approval before production distribution.
