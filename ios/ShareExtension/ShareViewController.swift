import UIKit
import Social

final class ShareViewController: SLComposeServiceViewController {
    override func isContentValid() -> Bool {
        true
    }

    override func didSelectPost() {
        // Production flow:
        // 1. Read shared text.
        // 2. Send it to the Heimdall app group container or backend.
        // 3. Open the main app to show the safety result.
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        []
    }
}
