# Heimdall iOS production layer

The web app is the parent console. Real iPhone protection requires a native iOS app because websites cannot control apps, read app activity or receive Screen Time events.

## Required Apple capabilities

- Family Controls entitlement
- Managed Settings
- Device Activity
- UserNotifications
- App Groups, if extensions share policy state

## Production modules

- `HeimdallApp.swift`: app entry point
- `FamilyShieldManager.swift`: requests family authorization and applies app shields
- Device Activity extension: receives monitored schedule events
- Backend policy API: stores family rules and sends parent push alerts

## Important

Apple must approve the Family Controls entitlement for the developer account before a build can monitor or shield apps on a child's iPhone.
