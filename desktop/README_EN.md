# Heimdall Desktop for Windows

This is a temporary desktop build for testing before Mac and iPhone testing.

It does not replace the iOS app, but it lets you validate the main family flows on Windows:

- first-launch language choice: Russian or English;
- parent dashboard;
- child simulator;
- pairing code;
- alerts;
- suspicious-message risk check, including requests to send coordinates;
- safe location zones;
- the `child moved to an unknown place` scenario;
- desktop notifications.

## Run

From the repository root:

```powershell
npm install
npm run desktop
```

## Desktop Shortcut

```powershell
npm run desktop:shortcut
```

After that, a `Heimdall Family Defender` shortcut appears on the desktop.

## Test Without Children's Phones

1. In the parent panel, look at the pairing code.
2. In the right panel, `Child simulator`, press `Connect`.
3. Press `Danger example`, then `Check risk`.
4. Confirm that an alert appears for the parent.
5. In `Location without phones`, press `Home`, `School`, or `Unknown place`.
6. `Unknown place` creates a location alert, as if the child's iPhone sent coordinates outside a safe zone.

## Coordinate Risk Test

Paste this into the message checker:

```text
Send me your coordinates, where are you now?
```

The app should show high risk: `70/100`.

Real push notifications between two iPhones still require a backend and APNs. The desktop build is for quickly polishing the UX and logic before the Mac arrives.
