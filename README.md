# OneLink
We provide a manager called OneLink to handle for deeplink and push notification navigation on application side.

OneLink provides an easy-navigation for deeplinks which can be triggered by a push notification or a universal link. Both integrations (notifications and universal links) up to your application and backend logic. You can use either Firebase Cloud Messaging (FCM) or APNs (Apple Push Notification Service). In this part, we will explain how push notifications can trigger OneLink framework for deeplink presentation.

First of all, you need to create an `enum` which conforms to  `OneLinkable`. Basically, OneLinkable is a protocol to allow your app to navigate to provided viewController by checking its state variable to navigate either `immediately`, or by `waitingForApproval`. Links waiting for approval are waiting for a confirmation before presentation, while `immediate` links are presented immediately. 
```swift
import OneLink
enum AppLink: OneLinkable {
    case announcements
    
    init?(url: URL) {
        self.init(url: url.absoluteString)
    }
    
    init?(url: String) {
        if url.hasPrefix("https://example.com/announcements") {
            self = .announcements
        } else {
            return nil
        }
    }
    
    var viewController: UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch self {
        case .announcements:
            guard let viewController = storyboard
                .instantiateViewController(withIdentifier: "Announcements") as? AnnouncementsViewController else {
                    fatalError("Announcements view controller could not be instantiated!")
            }
            return viewController
        }
    }
    
    var state: OneLinkableState {
        switch self {
        case .announcements: return .immediate
        }
    }
}
```

After creating your `AppLinks`, you need to subscribe to push notifications in your application. To do so, in your `AppDelegate`’s `didFinishLaunchingWithOptions`, call:
```swift
// Register for push notifications
UNUserNotificationCenter.current().delegate = self
let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: {_, _ in }
)
application.registerForRemoteNotifications()
```

```
If your app uses FCM for iOS, please be sure to integrate it according to ![docs](https://firebase.google.com/docs/cloud-messaging/ios/client).
```

To support `UNUserNotificationCenterDelegate` extend you `AppDelegate`:
```swift
extension AppDelegate: UNUserNotificationCenterDelegate {
    /// Shows push notification, even if its in foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        /// Pass url parameter from the payload to `OneLink` instance.
        if let url = response.notification.request.content.userInfo["gcm.notification.data"] as? String,
            let link = AppLink(url: url) {
            OneLink.shared().present(oneLink: link, ignoreLinkState: User.shared.isLoggedIn)
        }
        completionHandler()
    }
}
```

```
`ignoreLinkState` parameter is intended to present links regarding to their state. By default, it’s `false`, If your application stores User credentials, and some links should be displayed only after user login, you can pass user login status with this variable. 
```

In the above example, while parsing notification content, it’s assumed that push notification payload would be like:
```json
{
  "notification": {
    "data": "https://example.com/"
  }
}
```

Additionally, to support universal links, in your `AppDelegate`’s `didFinishLaunchingWithOptions` function:
```swift
// Handle universal links if application started with one
if let url = launchOptions?[.url] as? URL {
    _ = self.application(application, open: url)
}
```

And lastly,
```swift
/// Handle universal links
func application(_ app: UIApplication, open url: URL,
                 options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    if let link = AppLink(url: url) {
        OneLink.shared().present(oneLink: link, ignoreLinkState: User.shared.isLoggedIn)
        return true
    }
    // Continue for your app's normal flow.
    return false
}
```

If your app has links with state `waitingForApproval`, do not forget to call `presentPendingLinks` function when the criteria for pending links is met (eg. user is logged in).
```swift
OneLink.shared().presentPendingLinks()
```

```
If while waiting for this call, user taps multiple notifications with `waitingForApproval` state, they will be presented one by one after calling `presentPendingLinks`. You may get notified about the result of pending links with `OneLinkDelegate`.
```
