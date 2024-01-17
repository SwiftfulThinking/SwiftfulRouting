<p align="left">
    <img src="https://github.com/SwiftfulThinking/SwiftfulRouting/assets/44950578/a66e097f-5501-4480-ae9e-48d2809efae7" alt="SwiftfulRouting Swifts" width="70%" />
</p>


# SwiftfulRouting  🤙

SwiftfulRouting is a native, declarative framework that enables programmatic navigation in SwiftUI applications. 

Sample project: https://github.com/SwiftfulThinking/SwiftfulRoutingExample

## How It Works

<details>
<summary> Details (Click to expand) </summary>
<br>
    
SwiftUI is a declarative framework, and therefore, a SwiftUI router must be declarative by nature. Routers based on programatic code do not declare the view heirarchy in advance, but rather at the time of execution. The solution herein is to declare modifiers to support all possible routing in advance. The result is a Router struct that is fully decoupled from the View and added into the Environment on each screen.

As you segue to a new screen, the framework adds a set ViewModifers to the root of the destination View that will support all potential navigation routes. Currently, the framework can simultaneously support 1 active Segue, 1 active Alert, and 1 active Modal on each View in the heirarchy. The ViewModifiers are based on generic and/or type-erased destinations, which maintains a declarative view heirarchy while allowing the developer to still determine the destination at the time of execution. 

- The ViewModifiers are in `RouterView.swift -> body`.
- Accessible routing methods are in `AnyRouter.swift`. 
- Refer to the sample project for example implementations, UI Tests and sample MVC, MVVM and VIPER design patterns.

Sample project: https://github.com/SwiftfulThinking/SwiftfulRoutingExample

</details>

## Setup

<details>
<summary> Details (Click to expand) </summary>
<br>
Add the package to your Xcode project.

```
https://github.com/SwiftfulThinking/SwiftfulRouting.git
```

Import the package

```swift
import SwiftfulRouting
```

Add a `RouterView` at the top of your view heirarchy. A `RouterView` will embed your view into a Navigation heirarchy and add modifiers to support all potential segues.

```swift
struct ContentView: View {
    var body: some View {
        RouterView { _ in
            MyView()
        }
    }
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

Instead of relying on the `Environment`, you may also pass the `Router` directly into the child views. This allows the `Router` to be fully decoupled from the View (for more complex app architectures).

```swift
RouterView { router in
     ContentView(router: router)
          .onTapGesture {
               router.showScreen(.push) { router2 in
                    Text("View2")
                         .onTapGesture {
                              router2.showScreen(.push) { router3 in
                                   Text("View3")
                              }
                         }
               }
          }
}
```

Each `Router` object can simultaneously support 1 active Segue, 1 active Alert, and 1 active Modal. A new Router is created and added to the view heirarchy after each Segue. Refer to `AnyRouter.swift` to see all accessible methods.


```swift
struct MyView: View {

    let router: AnyRouter
    
    var body: some View {
        VStack {
            Text("Segue")
                .onTapGesture {
                    router.showScreen(.push) { router in
                        ThirdView(router: router)
                    }
                }
            
            Text("Alert")
                .onTapGesture {
                    router.showAlert(.alert, title: "Title") {
                        Button("OK") {
                            
                        }
                        Button("Cancel") {
                            
                        }
                    }
                }
            
            Text("Modal")
                .onTapGesture {
                    router.showModal {
                        ChildView()
                    }
                }
        }
    }
}
```

</details>

## Setup (existing projects) 

<details>
<summary> Details (Click to expand) </summary>
<br>
    
In order to enter the framework's view heirarchy, you must wrap your content in a RouterView. By default, your view will be wrapped in with navigation stack (iOS 16+ uses a NavigationStack, iOS 15 and below uses NavigationView). 
- If your view is already within a navigation heirarchy, set `addNavigationView` to `FALSE`. 
- If your view is already within a NavigationStack, use `screens` to bind to the existing stack path.
- The framework uses the native SwiftUI navigation bar, so all related modifiers will still work.

```swift
RouterView(addNavigationView: false, screens: $existingStack) { router in
   MyView(router: router)
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
router.showAlert(.alert, title: "Title goes here", subtitle: "Subtitle goes here!") {
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

- [ ] Support multiple Modals per screen
- [ ] Add `showModule` support, for navigating between parent-level RouterView's
- [ ] Support VisionOS

</details>
