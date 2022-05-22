# SwiftfulRouting  🕊

Native, declarative routing for SwiftUI applications

**Setup time:** 1 minute

**Sample project:** https://github.com/SwiftfulThinking/SwiftfulRoutingExample

## Overview 🤓

SwiftUI is a declarative framework, and therefore, a SwiftUI router should be declarative by nature. Routers based on programatic code do not declare the view heirarchy in advance, but rather at the time of execution. The solution is to declare all modifiers to support the routing in advance by adding a new set of modifiers at the root of each segue's destination where the destination is an optional, type-erased view. This maintains a declarative view heirarchy while allowing the developer to still determine the destination at the time of execution.

## Setup ☕️

Add the package to your xcode project

```
https://github.com/SwiftfulThinking/SwiftfulRouting.git
```

Import the package

```swift
import SwiftfulRouting
```

Add a `RouterView` at the top of your view heirarchy. A `RouterView` will embed your view into a NavigationView and add modifiers to support all potential segues. If you're already inside a NavigationView, use `SubRouterView` instead.

```swift
struct ContentView: View {
    var body: some View {
        RouterView {
            MyView()
        }
    }
}
```

The `Router` will be available as an `EnvironmentObject` of all child views of `RouterView`. Each `Router` object can simultaneously support one active segue, one active alert, and one active modal. A new Router is created and added to the Environment after each segue.


```swift
struct MyView: View {

    @EnvironmentObject private var router: Router
    
    var body: some View {
        VStack {
            Text("Segue")
                .onTapGesture {
                    router.showScreen(.push) {
                        ThirdView()
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

## Segues ⏩

Router supports native SwiftUI segues, including .push (NavigationLink), .sheet, and .fullScreenCover.

```swift
router.showScreen(.push, destination: () -> View)
router.showScreen(.sheet, destination: () -> View)
router.showScreen(.fullScreenCover, destination: () -> View)
router.dismissScreen()
```

## Alerts 🚨

Router supports native SwiftUI alerts, including .alert and .confirmationDialog.

```swift
router.showAlert(.alert, title: String, alert: () -> View)
router.showAlert(.confirmationDialog, title: String, alert: () -> View)
router.dismissAlert()
```

## Modals 🪧

Router also supports any modal transition, which displays above the current content.

```swift
router.showModal(destination: () -> View)
router.showModal(
  transition: AnyTransition, 
  animation: Animation, 
  alignment: Alignment, 
  backgroundColor: Color?, 
  useDeviceBounds: Bool, 
  destination: () -> View)
router.dismissModal()
```
