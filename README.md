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
// NavigationLink
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

Segue methods also accept `AnyRoute` as a convenience, which make it easy to pass the `Route` around your code.

```swift
let route = AnyRoute(.push, destination: { router in
     Text("Hello, world!")
})
                        
router.showScreen(route)
```

All segues have an onDismiss method.

```swift

router.showScreen(.push, onDismiss: {
     // dismiss action
}, destination: { _ in
     Text("Hello, world!")
})
                
let route = AnyRoute(.push, onDismiss: {
     // dismiss action
}, destination: { _ in
     Text("Hello, world!")
})
                
router.showScreen(route)
```

iOS 16+ uses NavigationStack, which supports pushing multiple screens at once.

```swift
let route1 = PushRoute(destination: { router in
     Text("View1")
})
let route2 = PushRoute(destination: { router in
     Text("View2")
})
let route3 = PushRoute(destination: { router in
     Text("View3")
})
                        
router.pushScreenStack(destinations: [route1, route2, route3])
```

iOS 16+ also supports resizable sheets.

```swift
router.showResizableSheet(sheetDetents: [.medium, .large], selection: nil, showDragIndicator: true) { _ in
     Text("Hello, world!)
}
```

Additional convenience methods:
```swift
router.showSafari {
     URL(string: "https://www.apple.com")
}
```

</details>

## Enter Screen Flows

<details>
<summary> Details (Click to expand) </summary>
<br>

Screen "flows" are new way to support dynamic routing in your application. When you enter a "screen flow", you add an array of `Routes` to the heirarchy. The application will immediately segue to the first screen, and then set the remaining screens into a queue.

```swift
router.enterScreenFlow([
     AnyRoute(.fullScreenCover, destination: screen1),
     AnyRoute(.push, destination: screen2),
     AnyRoute(.push, destination: screen3),
     AnyRoute(.push, destination: screen4),
])
```

This allows the developer to set multiple future segues at once, without requiring screen-specific code in each child view. Each child view's routing logic is simple as "try to go to next screen".

```swift
do {
     try router.showNextScreen()
} catch {
     // There is no next screen set in the flow
     // Dismiss the flow (see below dismiss methods) or do something else
}
```

Benefits of using a "flow":

- **Simiplified Logic:** In most applications, the routing logic is tightly coupled to the View (ie. when you create a screen, you declare in code exactly what the next screen must be). Now, you can build a screen without having to worry about routing at all. Simply support "go to next screen" or "dismiss flow" (see dismissal code below).

- **AB Tests:** Each user can see a unique flow of screens in your app, and you don't have to write 'if-else' logic within every child view.

- **High-Level Control**: You can control the entire flow from one method, which will be closer to the business logic of your app, rather than within the View itself.

- **Flows on Flows**: Flows are fully dynamic, meaning you can enter flows from within flows and can dismiss screens within flows (back-forward-back) without corrupting the flow.

</details>

## Dismiss Screens

<details>
<summary> Details (Click to expand) </summary>
<br>

Dismiss one screen. You can also dismiss a screen using native SwiftUI code, including swipe-back gestures or `presentationMode`. 

```swift
router.dismissScreen()
```

Dismiss all screens pushed onto the stack. This dismisses every "push" (NavigationLink) on the screen's Navigation Stack. This does not dismiss `sheet` or `fullScreenCover`.

```swift
router.dismissScreenStack()
```

Dismiss screen environment. This dismisses the screen's root environment (if there is one to dismiss), which is the closest 'sheet' or `fullScreenCover` below the call-site.

```swift
router.dismissEnvironment()
```

For example, if you entered the following screen flow and you called `dismissEnvironment` from any of the child views, it would dismiss the `fullScreenCover`, which in-turn dismisses every view displayed on that Environment. 

```swift
router.enterScreenFlow([
     AnyRoute(.fullScreenCover, destination: screen1),
     AnyRoute(.push, destination: screen2),
     AnyRoute(.push, destination: screen3),
     AnyRoute(.push, destination: screen4),
])
```

Logic for dismissing a "Flow" can generally look like:

```swift
do {
     try router.showNextScreen()
} catch {
     router.dismissEnvironment()
}
```

Or convenience method:

```swift
router.showNextScreenOrDismissEnvironment()
```

Copy and paste this code into your project to enable swipe back gestures. This is not included in the SwiftUI framework by default and therefore is not automatically included herein. 


```swift
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
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
