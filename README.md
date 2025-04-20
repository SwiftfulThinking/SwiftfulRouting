### 🚀 Learn how to build and use this package: https://www.swiftful-thinking.com/offers/REyNLwwH


# SwiftfulRouting 🤙

Programmatic navigation for SwiftUI applications.

✅ Segues
✅ Alerts
✅ Modals
✅ Transitions
✅ Modules

- Sample project: https://github.com/SwiftfulThinking/SwiftfulRoutingExample
- YouTube Tutorial: https://www.youtube.com/watch?v=zKfhv-Yds4g&list=PLwvDm4VfkdphPRGbtiY-X3IZsUXFi6595&index=6

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


## Alerts

<details>
<summary> Details (Click to expand) </summary>
<br>

Router supports native SwiftUI alerts.

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

Dismiss an alert.

```swift
router.dismissAlert()
```

Additional convenience methods:

```swift
router.showBasicAlert(text: "Error")
```

</details>

## Modals

<details>
<summary> Details (Click to expand) </summary>
<br>

Router also supports any modal transition, which displays above the current content. Customize transition, animation, background color/blur, etc. See sample project for example implementations.

```swift
router.showModal(transition: .move(edge: .top), animation: .easeInOut, alignment: .top, backgroundColor: nil, useDeviceBounds: true) {
     Text("Sample")
          .onTapGesture {
               router.dismissModal()
          }
}
```

You can display multiple modals simultaneously. Modals have an optional ID field, which can later be used to dismiss the modal.  

```swift
router.showModal(id: "top1") {
     Text("Sample")
}

// Dismiss top-most modal
router.dismissModal()

// Dismiss modal by ID
router.dismissModal(id: "top1")

// Dismiss all modals
router.dismissAllModals()

```


Additional convenience methods:

```swift
router.showBasicModal {
     Text("Sample")
          .onTapGesture {
               router.dismissModal()
          }
}
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


Additional convenience methods:
```swift
router.showSafari {
     URL(string: "https://www.apple.com")
}
```
