# SwiftfulRouting  🤙

A native, declarative framework for programmatic navigation (routing) in SwiftUI applications, fully decoupled from the View.

**Setup time:** 1 minute

**Sample project:** https://github.com/SwiftfulThinking/SwiftfulRoutingExample

## Overview

SwiftUI is a declarative framework, and therefore, a SwiftUI router should be declarative by nature. Routers based on programatic code do not declare the view heirarchy in advance, but rather at the time of execution. The solution is to declare all modifiers to support the routing in advance. 

## Under the hood

As you segue to a new screen, the framework adds a set ViewModifers to the root of the destination View that will support all potential navigation routes. The framework can support 1 active Segue, 1 active Alert, and 1 active Modal on each View in the heirarchy. The ViewModifiers are based on generic and/or type-erased destinations, which maintains a declarative view heirarchy while allowing the developer to still determine the destination at the time of execution. Version 3.0 returns the ViewModifiers back to the segue's call-site as AnyRouter, which further enables the developer to inject the routing logic into the View.

## Setup ☕️

Add the package to your xcode project

```
https://github.com/SwiftfulThinking/SwiftfulRouting.git
```

Import the package

```swift
import SwiftfulRouting
```

Add a `RouterView` at the top of your view heirarchy. A `RouterView` will embed your view into a Navigation heirarchy and add modifiers to support all potential segues. Use the returned `router` to perform navigation.

```swift
struct ContentView: View {
    var body: some View {
        RouterView { router in
            MyView(router: router)
        }
    }
}
```

Each `Router` object can simultaneously support 1 active Segue, 1 active Alert, and 1 active Modal. A new Router is created and added to the view heirarchy after each Segue.


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

## Usage 🦾

The returned router is a type-erased `Router`, named `AnyRouter`. Refer to `AnyRouter.swift` to see all accessible methods.

## RouterView 🏠

Use RouterView to enter the framework's view heirarchy and use the returned `router: AnyRouter` to perform navigation.

```swift
RouterView { router in
   MyView(router: router)
}
```

Be default, your view will be wrapped in with navigation heirarchy (iOS 16+ uses a NavigationStack, iOS15 and below uses NavigationView). 
- If your view is already within a navigation heirarchy, set `addNavigationView` to `FALSE`. 
- If your view is within a NavigationStack, use `screens` to bind to the existing stack path.
- The framework uses the native SwiftUI navigation bar, so all related modifiers will still work.

```swift
RouterView(addNavigationView: false, screens: $existingStack) { router in
   MyView(router: router)
        .navigationBarHidden(true)
        .toolbar {
        }
}
```

## Segues ⏩

Router supports native SwiftUI segues, including .push (NavigationLink), .sheet, and .fullScreenCover. 
- You may use `router.dismissScreen()`, `@Environment(\.presentationMode) var presentationMode` or `@Environment(\.dismiss) var dismiss` to dismiss the screen.

```swift
router.showScreen(.push, destination: (AnyRouter) -> View)
router.showScreen(.sheet, destination: (AnyRouter) -> View)
router.showScreen(.fullScreenCover, destination: (AnyRouter) -> View)
router.dismissScreen()
```
iOS 16 also supports NavigationStack and resizable Sheets. Note that `popToRoot` purposely dismisses all views pushed onto the NavigationStack, but does not dismiss `.sheet` or `.fullScreenCover`.

```swift
router.pushScreens(destinations: [(AnyRouter) -> any View]
router.popToRoot()
router.showResizableSheeet(sheetDetents: Detent, selection: Binding<Detent>, showDragIndicator: Bool, destination: (AnyRouter) -> View)
```

## Alerts 🚨

Router supports native SwiftUI alerts, including `.alert` and `.confirmationDialog`.

```swift
router.showAlert(.alert, title: String, alert: () -> View)
router.showAlert(.confirmationDialog, title: String, alert: () -> View)
router.dismissAlert()
```

Additional convenience methods:

```swift
router.showBasicAlert(text: String, action: (() -> Void)?)
```

## Modals 🪧

Router also supports any modal transition, which displays above the current content. Customize transition, animation, background color/blur, etc.

```swift
router.showModal(destination: () -> View)
router.showModal(
  transition: AnyTransition, 
  animation: Animation, 
  alignment: Alignment, 
  backgroundColor: Color?,
  backgroundEffect: BackgroundEffect?,
  useDeviceBounds: Bool, 
  destination: () -> View)
router.dismissModal()
```

Additional convenience methods:

```swift
router.showBasicModal(destination: () -> View)
```
