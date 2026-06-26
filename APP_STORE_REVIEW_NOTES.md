# App Store Review Notes

Heimdall Family Protection is a parent-controlled family safety application.

The app helps families protect children and elderly relatives from scam attempts, coercion, remote-access fraud, and risky device behavior. It is not a hidden surveillance product.

Core behavior:

- A parent or guardian authorizes protection.
- The app uses Screen Time APIs with Family Controls, Device Activity, and Managed Settings.
- The app can shield selected apps or categories during risky situations.
- The app can analyze text fragments that the user explicitly shares to Heimdall through the Share Sheet.
- Parents receive risk reasons and safety alerts, not full private conversations.

Privacy model:

- Heimdall does not silently read Telegram, WhatsApp, Discord, or private messenger content.
- Heimdall does not collect full chat histories.
- Heimdall uses data minimization and only processes content explicitly shared with the app or device-activity signals available through Apple APIs.
- Family members are informed about the protection flow.

Demo account:

If a demo account is required, provide one in App Store Connect before review.

Reviewer testing:

1. Launch the app.
2. Open the parent setup screen.
3. Review the family protection explanation.
4. Use the sample risk text in the analysis screen.
5. Confirm that the app returns a risk score and a clear safety action.
6. If Family Controls entitlement is available in the review build, test authorization and app shielding.
