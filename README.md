### 🚀 Learn how to build and use this package: https://www.swiftful-thinking.com/offers/REyNLwwH


# SwiftfulRouting 🤙

Programmatic navigation for SwiftUI applications.

✅ Segues
✅ Alerts
✅ Modals
✅ Transitions
✅ Modules

How to use this package:

1️⃣ Read the docs below
2️⃣ Watch [YouTube Tutorial](https://www.youtube.com/watch?v=zKfhv-Yds4g&list=PLwvDm4VfkdphPRGbtiY-X3IZsUXFi6595&index=6)
3️⃣ Practice with [Sample Project](https://github.com/SwiftfulThinking/SwiftfulRoutingExample)
4️⃣ Test the [Starter Project](https://github.com/SwiftfulThinking/SwiftfulStarterProject)


Versioning:

➡️ iOS 17+ use version 6.0 or above
➡️ iOS 14+ use version 5.3.6
➡️ iOS 13+ use version 2.0.2

## Quick Start (TLDR)

<details>
<summary> Details (Click to expand) </summary>
<br>

Use a `RouterView` to replace `NavigationStack` in your SwiftUI code.

```swift
// Before SwiftfulRouting
NavigationStack {
  MyView()
    .navigationDestination()
    .sheet()
    .fullScreenCover()
    .alert()
}

// With SwiftfulRouting
RouterView { _ in
  MyView()
}
```

Use a `router` to perform actions.

```swift
struct MyView: View {
    
    @Environment(\.router) var router
    
    var body: some View {
        Text("Hello, world!")
            .onTapGesture {
                router.showScreen { _ in 
                    AnotherView()
                }
            }
    }
}
```

All available methods in `router` are in `AnyRouter.swift`. Examples:

```swift
router.showScreen...
router.showAlert...
router.showModal...
router.showTransition...
router.showModule...
router.dismissScreen...
router.dismissAlert...
router.dismissModal...
router.dismissTransition...
router.dismissModule...
```

</details>


## How It Works

<details>
<summary> Details (Click to expand) </summary>
<br>

As you segue to a new screen, the framework adds a set view modifiers to the root of the destination View that will support all potential navigation routes. This allows declarative code to behave as programmatic code, since the view modifiers are connected in advance. Screen destinations are erased to generic types, allowing the developer to determine the destination at the time of execution. 


Version 6.0 adds many new features to the framework by implementing an internal `RouterViewModel` across the screen heirarchy that allows and screen's `router` to perform actions that affect the entire heirarchy. The technical solution was to introduce `[AnyDestinationStack]` which is a single array that holds bindings for all active segues in the heirarchy. 

```
// Example of what an [AnyDestinationStack] might look like:

 [
    [.fullScreenCover]
    [.push, .push, .push, .push]
    [.sheet]
    []
 ]
```

In addition to adding a `router` to the Environment, every segue immedaitely returns a `router` in the View's closure. This allows the developer to have access to the screen's routing methods before the screen is created. Leave fully decouples routing logic from the View layer and is perfect for more complex app architectures, such as MVVM or VIPER.

```swift
RouterView { router in
  MyView(router: router)
}
```

</details>

## Setup

<details>
<summary> Details (Click to expand) </summary>
<br>
Add the package to your Xcode project.

```
https://github.com/SwiftfulThinking/SwiftfulRouting.git
```

Import the package.

```swift
import SwiftfulRouting
```

Add a `RouterView` at the top of your view heirarchy. A `RouterView` will embed your view into a NavigationStack and add modifiers to support all potential segues. This would **replace** an existing `NavigationStack` in your code.

Use a `RouterView` to replace `NavigationStack` in your SwiftUI code.

```swift
// Before SwiftfulRouting
NavigationStack {
  MyView()
    .navigationDestination()
    .sheet()
    .fullScreenCover()
    .alert()
}

// With SwiftfulRouting
RouterView { _ in
  MyView()
}
```

All child views have access to a `Router` in the `Environment`.

```swift
@Environment(\.router) var router
    
var body: some View {
     Text("Hello, world!")
          .onTapGesture {
               router.showScreen(.push) { _ in
                    Text("Another screen!")
               }
          }
     }
}
```

Instead of relying on the `Environment`, you can also pass the `router` directly into the child views.

```swift
RouterView { router in
    MyView(router: router)
}
```

You can also use the returned `router` directly. A new `router` is created and added to the view heirarchy after each segue and are therefore unique to each screen. In the below example, the tap gesture on "View3" could call `dismissScreen()` from `router2` or `router3`, which would have different behaviors. This is done on purpose and is further explained in the docs below!

```swift
RouterView { router1 in
    Text("View 1")
        .onTapGesture {
            router1.showScreen(.push) { router2 in
                Text("View 2")
                    .onTapGesture {
                        router2.showScreen(.push) { router3 in
                            Text("View3")
                                .onTapGesture {
                                    router3.dismissScreen() // Dismiss View3
                                    router2.dismissScreen() // Dismiss View2 and View 3
                                }
                        }
                    }
               }
          }
}
```

Refer to [AnyRouter.swift](https://github.com/SwiftfulThinking/SwiftfulRouting/blob/main/Sources/SwiftfulRouting/Core/AnyRouter.swift) to see all accessible methods.

</details>

## Setup (existing projects) 

<details>
<summary> Details (Click to expand) </summary>
<br>
    
In order to enter the framework's view heirarchy, you must wrap your content in a `RouterView`, which will add a `NavigationStack` by default.

Most apps should replace their existing `NavigationStack` with a `RouterView`, however, if you cannot remove it, you can add a `RouterView` but initialize it without a `NavigationStack`.

The framework uses the native SwiftUI navigation bar, so all related modifiers will still work.

```swift
RouterView(addNavigationView: false) { router in
   MyView()
        .navigationBarHidden(true)
        .toolbar {
        }
}
```

</details>

## Show Screens

<details>
<summary> Details (Click to expand) </summary>
<br>

Router supports all native SwiftUI segues.

```swift
// Navigation destination
router.showScreen(.push) { _ in
     Text("View2")
}

// Sheet
router.showScreen(.sheet) { _ in
     Text("View2")
}

// FullScreenCover
router.showScreen(.fullScreenCover) { _ in
     Text("View2")
}
```

Segue methods also accept `AnyDestination` as a convenience.

```swift
let screen = AnyDestination(segue: .push, destination: { router in
    Text("Hello, world!")
})
                                    
router.showScreen(screen)
```

Segue to multiple screens at once. This will immediately trigger each screen in order, ending with the last screen displayed.

```swift
let screen1 = AnyDestination(segue: .push, destination: { router in
    Text("Hello, world!")
})
let screen2 = AnyDestination(segue: .sheet, destination: { router in
    Text("Another screen!")
})
let screen3 = AnyDestination(segue: .push, destination: { router in
    Text("Third screen!")
})
                                    
router.showScreens(destinations: [screen1, screen2, screen3])
```

Use `.sheetConfig()` or `.fullScreenCoverConfig()` to for resizable sheets and backgrounds in new Environments.

```swift
let config = ResizableSheetConfig(
    detents: [.medium, .large],
    dragIndicator: .visible
)

router.showScreen(.sheetConfig(config: config)) { _ in
    Text("Screen2")
}
```

```swift
let config = FullScreenCoverConfig(
    background: .clear
)
            
router.showScreen(.fullScreenCoverConfig(config: config)) { _ in
    Text("Screen2")
}
```

All segues have an `onDismiss` method.

```swift
router.showScreen(.push, onDismiss: {
     // dismiss action
}, destination: { _ in
     Text("Hello, world!")
})
```

Fully customize each segue!

```swift
let screen = AnyDestination(
    id: "profile_screen", // id of screen (used for analytics)
    segue: .fullScreenCover, // segue option
    location: .insert, // where to add screen within the view heirarchy
    animates: true, // animate the segue
    transitionBehavior: .keepPrevious, // transition behavior (only relevant for showTransition methods)
    onDismiss: {
        // Do something when screen dismisses
    },
    destination: { _ in
        Text("ProfileView")
    }
)
```

Additional convenience methods:

```swift
router.showSafari {
     URL(string: "https://www.apple.com")
}
```


## Dismiss Screens

<details>
<summary> Details (Click to expand) </summary>
<br>

Dismiss one screen.

```swift
router.dismissScreen()
```

You can also use the native SwiftUI method. 

```swift
@Environment(\.dismiss) var dismiss
```

Dismiss screen at id.

```swift
router.dismissScreen(id: "x")
```

Dismiss screens back to, but not including, id.

```swift
router.dismissScreen(upToScreenId: "x")
```

Dismiss a specific number of screens.

```swift
router.dismissScreens(count: 2)
```

Dismiss all .push segues on the NavigationStack of the current screen.

```swift
router.dismissPushStack()
```

Dismiss screen environment (ie. the closest .sheet or .fullScreenCover to this screen).

```swift
router.dismissEnvironment()
```

Dismiss the last screen in the screen heirarchy.

```swift
router.dismissLastScreen()
```

Dismiss the last push stack in the screen heirarchy.

```swift
router.dismissLastPushStack()
```

Dismiss the last environment in the screen heirarchy.

```swift
router.dismissLastEnvironment()
```

Dismiss all screens in the screen heirarchy.

```swift
router.dismissLastEnvironment()
```

## Screen Queue

<details>
<summary> Details (Click to expand) </summary>
<br>

Add screens to a queue to navigate to them later!

```swift
router.addScreenToQueue(destination: screen1)
router.addScreensToQueue(destinations: [screen1, screen2, screen3])
```

Trigger segue to the first screen in queue, if available.

```swift
// Show next screen if available
router.showNextScreen()

// show next screen, otherwise, throw error
do {
    try router.tryShowNextScreen()
} catch {
    // Do something else
}
```

Remove screens from the queue.

```swift
router.removeScreenFromQueue(id: "x")
router.removeScreensFromQueue(ids: ["x", "y"])
router.removeAllScreensFromQueue()
```

For example, an onboarding flow might have a variable number of screens depending on the user's responses. As the user progresses, add screens to the queue and then the logic within each screen is "try to go to next screen (if available) otherwise dismiss onboarding"

Additional convenience methods:

```swift
// Segue to a the next screen in the queue (if available) otherwise dismiss the screen.
router.showNextScreenOrDismissScreen()

// Segue to a the next screen in the queue (if available) otherwise dismiss environment.
router.showNextScreenOrDismissEnvironment()

// Segue to a the next screen in the queue (if available) otherwise dismiss push stack.
router.showNextScreenOrDismissPushStack()
```

</details>


## Show Alerts

<details>
<summary> Details (Click to expand) </summary>
<br>

Router supports all native SwiftUI alerts.

```swift
// Alert
router.showAlert(.alert, title: "Title goes here", subtitle: "Subtitle goes here!") {
     Button("OK") {

     }
     Button("Cancel") {
                        
     }
}

// Confirmation Dialog
router.showAlert(.confirmationDialog, title: "Title goes here", subtitle: "Subtitle goes here!") {
     Button("A") {
                        
     }
     Button("B") {
                        
     }
     Button("C") {
                        
     }
}
```

Alert methods also accept `AnyAlert` as a convenience.

```swift
let alert = AnyAlert(
    style: .alert,
    location: .currentScreen,
    title: "Title",
    subtitle: nil
)
router.showAlert(alert: alert)
```

Dismiss the alert.

```swift
router.dismissAlert()
router.dismissAllAlerts()
```

Additional convenience methods.

```swift
router.showBasicAlert(text: "Error")
```

</details>

## Show Modals

<details>
<summary> Details (Click to expand) </summary>
<br>

Modals appear on top of the current screen. Router supports an **infinite** number of **simultaneous** modals.

```swift
router.showModal {
    MyModal()
        .frame(width: 300, height: 300)
}
```

Fully customize modal's display.

```swift
router.showModal(
    id: "modal_1", // Id for modal
    transition: .move(edge: .bottom), // AnyTransition
    animation: .smooth, // transition animation
    alignment: .center, // Alignment within screen
    backgroundColor: Color.black.opacity(0.1), // Color behind modal
    backgroundEffect: BackgroundEffect(effect: UIBlurEffect(style: .systemMaterialDark), intensity: 0.1), // Blur effect behind modal
    dismissOnBackgroundTap: true, // Add dismiss tap gesture on background layer
    ignoreSafeArea: true, // Modal will safe area
    onDismiss: {
        // Do something when modal is dismissed
    },
    destination: {
        MyModal()
    }
)
```

Modal methods also accept `AnyModal` as a convenience.

```
let modal = AnyModal {
    MyModal()
}

router.showModal(modal: modal)
```

Trigger multiple modals at the same time.

```swift
router.showModals(modals: [modal1, modal2])
```

Dismiss the last modal displayed.

```swift
router.dismissModal()
```

Dismiss modal by id.

```swift
router.dismissModal(id: "modal_1")
```

Dismiss modals above, but not including, id.

```swift
router.dismissModals(upToModalId: "modal_1")
```

Dismiss specific number of modals.

```swift
router.dismissModals(count: 2)
```

Dismiss all modals.

```swift
router.dismissAllModals()
```

Additional convenience methods:

```swift
router.showBasicModal {
     Rectangle()
        .frame(width: 200, height: 200)
}
```

```swift
router.showBottomModal {
     Rectangle()
        .frame(width: 200, height: 200)
}
```

</details>

## Show Transitions

<details>
<summary> Details (Click to expand) </summary>
<br>

Transitions change the current screen WITHOUT performing a full segue.

Transitions are NOT segues!

Transitions are similar to using an "if-else" statement to switch between views.

```swift
router.showTransition { router in
    MyView()
}
```

**Important:** When showing a new screen via `showScreen` there is a parameter `transitionBehavior`. This will determine the UI behavior of any `showTransition` on the resulting screen.

Set `transitionBehavior` to `.keepPrevious` to keep previous screens in memory. This will transition new screens ON TOP of each other.

Set `transitionBehavior` to `.removePrevious` to remove previous screens from memory. This will transition a new screen on, while transitioning the old screen off.

```swift
router.showScreen(transitionBehavior: .removePrevious) { _ in
    MyView()
}
```

Transition methods also accept `AnyTransitionDestination` as a convenience.

```swift
let screen = AnyTransitionDestination { _ in
    MyView()
}

router.showTransition(transition: screen)
```

Add multiple transitions on the screen and display the last one on top.

```swift
router.showTransitions(transitions: [screen1, screen2, screen3])
```

Fully customize transition's display.

```swift
let transition = AnyTransitionDestination(
    id: "transition_1", // Id for the screen
    transition: .trailing, // Transition edge
    allowsSwipeBack: true, // Add a swipe back gesture to the screen's edge
    onDismiss: {
        // Do something when transition dismisses
    },
    destination: { router in
        MyView()
    }
)
```

Dismiss the last transition displayed.

```swift
router.dismissTransition()
```

Dismiss transition by id.

```swift
router.dismissTransition(id: "transition_1")
```

Dismiss transitions above, but not including, id.

```swift
router.dismissTransitions(upToId: "transition_1")
```

Dismiss specific number of transitions.

```swift
router.dismissTransitions(count: 2)
```

Dismiss all transitions.

```swift
router.dismissAllTransitions()
```

Additional convenience methods:

```swift
// Dismiss transition (if there is one) otherwise dismiss screen.
router.dismissTransitionOrDismissScreen()
```

</details>

## Transition Queue

<details>
<summary> Details (Click to expand) </summary>
<br>

Add transitions to a queue to trigger them later!

```swift
router.addTransitionToQueue(transition: screen1)
router.addTransitionsToQueue(transitions: [screen1, screen2, screen3])
```

Trigger transition to the first in queue, if available.

```swift
// Show next transition if available
router.showNextTransition()

// show next transition, otherwise, throw error
do {
    try router.tryShowNextTransition()
} catch {
    // Do something else
}
```

Remove transitinos from the queue.

```swift
router.removeTransitionFromQueue(id: "x")
router.removeTransitionsFromQueue(ids: ["x", "y"])
router.removeAllTransitionsFromQueue()
```

For example, an onboarding flow might have a variable number of screens depending on the user's responses. As the user progresses, add screens to the queue and then the logic within each screen is "try to go to next screen (if available) otherwise dismiss onboarding"

Additional convenience methods:

```swift
// Trigger next transition or trigger next screen or dismiss screen.
router.showNextTransitionOrNextScreenOrDismissScreen()
```

</details>

## Show Modules

<details>
<summary> Details (Click to expand) </summary>
<br>

Modules swap the ENTIRE view heirarchy and replace the existing `RouterView` with a new one.

```swift
router.showModule { router in
    MyView()
}
```

**Important:** Module support is NOT automatically included within `RouterView`. You must enable it by setting `addModuleSupport` to `true`. This is done on purpose, in case there are multiple `RouterView` in the same heirarchy.

```swift
router.showScreen(addModuleSupport: true) { _ in
    MyView()
}
```

Module methods also accept `AnyTransitionDestination` as a convenience.

```swift
let screen = AnyTransitionDestination { _ in
    MyView()
}

router.showModule(module: screen)
```

The user's last module is saved in UserDefaults and can be used to restore the app's state across sessions.

```swift
@State private var lastModuleId = UserDefaults.lastModuleId

var body: some Scene {
    WindowGroup {
        if lastModuleId == "onboarding" {
            RouterView(id: "onboarding", addModuleSupport: true) { router in
                OnboardingView()
            }
        } else {
            RouterView(id: "home", addModuleSupport: true) { router in
                HomeView()
            }
        }
    }
}
```

Add multiple modules to the heirarchy and display the last one.

```swift
router.showModules(modules: [module1, module2, module3])
```

Fully customize module's display.

```swift
let module = AnyTransitionDestination(
    id: "module_1", // Id for the screen
    transition: .trailing, // Transition edge
    allowsSwipeBack: true, // Add a swipe back gesture to the screen's edge
    onDismiss: {
        // Do something when transition dismisses
    },
    destination: { router in
        MyView()
    }
)
```

**Note:** You can dismiss modules, although it is easier to use `showModule` to display the previous module again. 

Dismiss the last module displayed.

```swift
router.dismissModule()
```

Dismiss module by id.

```swift
router.dismissModule(id: "module_1")
```

Dismiss modules above, but not including, id.

```swift
router.dismissModules(upToId: "module_1")
```

Dismiss specific number of modules.

```swift
router.dismissModules(count: 2)
```

Dismiss all modules.

```swift
router.dismissAllModules()
```

</details>

## Logging, analytics & debugging

<details>
<summary> Details (Click to expand) </summary>
<br>

Built-in logging that can be used for debugging and analytics.

```swift
// Set log level using internal logger:

SwiftfulRoutingLogger.enableLogging(level: .analytic, printParameters: true)
```

Add your own implementation to handle unique events in your app.
```swift
struct MyLogger: RoutingLogger {
    
    func trackEvent(event: any RoutingLogEvent) {
        let name = event.eventName
        let params = event.parameters
        
        switch event.type {
        case .info:
            break
        case .analytic:
            break
        case .warning:
            break
        case .severe:
            break
        }
    }
}

SwiftfulRoutingLogger.enableLogging(logger: MyLogger())
```        

Or use [SwiftfulLogging](https://github.com/SwiftfulThinking/SwiftfulLogging) directly.

```swift
let logManager = LogManager(services: [
    ConsoleService(printParameters: true),
    FirebaseCrashlyticsService(),
    MixpanelService()
])

SwiftfulRoutingLogger.enableLogging(logger: logManager)
```

Additional values to look into the underlying view heirarchy. 

```swift

// Active screen stacks in the heirarchy
router.activeScreens

// Active screen queue
router.activeScreenQueue

// Has at least 1 screen in queue
router.hasScreenInQueue

// Active alert
router.activeAlert

// Has alert displayed
router.hasActiveAlert

// Active modals on screen
router.activeModals

// Has at least 1 modal displayed
router.hasActiveModal

// Active transitions on screen
router.activeTransitions

// Has at least 1 active transtion
router.hasActiveTransition

// Active transition queue
router.activeTransitionQueue

// Has at least 1 transition in queue
router.hasTransitionInQueue

// Active modules
router.activeModules
```

</details>

## Contribute 🤓

<details>
<summary> Details (Click to expand) </summary>
<br>

Community contributions are encouraged! Please ensure that your code adheres to the project's existing coding style and structure. Most new features are likely to be derivatives of existing features, so many of the existing ViewModifiers and Bindings should be reused.

- [Open an issue](https://github.com/SwiftfulThinking/SwiftfulRouting/issues) for issues with the existing codebase.
- [Open a discussion](https://github.com/SwiftfulThinking/SwiftfulRouting/discussions) for new feature requests.
- [Submit a pull request](https://github.com/SwiftfulThinking/SwiftfulRouting/pulls) when the feature is ready.

Upcoming features:

- [x] Support multiple Modals per screen
- [ ] Add `showModule` support, for navigating between parent-level RouterView's
- [ ] Support VisionOS

</details>
