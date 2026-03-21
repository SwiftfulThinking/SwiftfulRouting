# SwiftfulRouting

Programmatic navigation library for SwiftUI. Replaces NavigationStack, sheets, fullScreenCovers, alerts, and confirmationDialogs with a unified router API. iOS 16+, macOS 12+, tvOS 14+.

## Setup

IMPORTANT: `RouterView` automatically provides a `NavigationStack`. Screens rendered inside a `RouterView` must NEVER add their own `NavigationStack { }` wrapper — doing so creates a nested navigation hierarchy that breaks swipe-back, toolbar rendering, and title display. Apply `.navigationTitle`, `.toolbar`, and `.navigationBarTitleDisplayMode` directly to your root view; they bubble up to the nearest `NavigationStack` automatically.

```swift
import SwiftfulRouting

// Root of the app — wraps content in a NavigationStack
RouterView { router in
    HomeView()
}

// Without NavigationStack (e.g. inside a TabView where each tab has its own RouterView)
RouterView(addNavigationStack: false) { router in
    HomeView()
}

// With module support (for switching between onboarding ↔ main app)
RouterView(id: "tabbar", addNavigationStack: false, addModuleSupport: true) { _ in
    TabBarView()
}
```

### Accessing the router

The router is available via `@Environment(\.router)` or can be passed manually. The app's architecture determines which pattern to use — if the project passes dependencies manually (e.g. MVVM, VIPER), pass the router manually too. If the project uses `@Environment` throughout, use `@Environment(\.router)`. Match what the project already does.

```swift
// Via Environment (typical for MVC / pure SwiftUI)
@Environment(\.router) var router

// Via manual passing (typical for MVVM, VIPER, etc.)
// The AnyRouter is passed through init chains — see Architecture Examples below
```

## Navigation Hierarchy

Use SwiftfulRouting APIs for ALL navigation. Never use native `.navigationDestination`, `.sheet`, `.fullScreenCover`, `.alert`, or `.confirmationDialog` — the router wraps all of these.

When the user doesn't specify a navigation style, follow this priority:

1. **`showScreen`** — the default for any typical screen transition. This is a native segue (push, sheet, or fullScreenCover). Use this unless told otherwise.
2. **`showModal`** — use when the user says "modal", "popup", "overlay", "bottom sheet (custom)", or "toast". Shows on top of the current screen with custom transitions/animations.
3. **`showTransition`** — use only when explicitly asked. Replaces the current screen content (not a segue). Rare.
4. **`showModule`** — replaces the entire screen hierarchy. Only use if the app already has module switching set up at the root (e.g. onboarding ↔ tabbar). Never recommend this unless the module system is already in place.
5. **`showAlert`** — use for all alerts and confirmation dialogs. Always prefer over native `.alert` or `.confirmationDialog`.

## Screens (showScreen)

The primary navigation API. Wraps SwiftUI's NavigationStack push, sheet, and fullScreenCover.

```swift
// Push (default) — standard navigation push
router.showScreen { router in
    DetailView()
}

// Sheet
router.showScreen(.sheet) { router in
    SettingsView()
}

// Full screen cover
router.showScreen(.fullScreenCover) { router in
    OnboardingView()
}
```

### Full signature

```swift
router.showScreen(
    _ segue: SegueOption = .push,        // .push, .sheet, .fullScreenCover
    id: String = UUID().uuidString,
    location: SegueLocation = .insert,   // .insert, .append, .insertAfter(id:)
    animates: Bool = true,
    transitionBehavior: TransitionMemoryBehavior = .keepPrevious,
    onDismiss: (() -> Void)? = nil,
    destination: @escaping (AnyRouter) -> some View
)
```

### SegueOption

- `.push` — NavigationStack push (default)
- `.sheet` — modal sheet with default settings
- `.sheetConfig(config: ResizableSheetConfig())` — modal sheet with custom configuration
- `.fullScreenCover` — full screen cover with default settings
- `.fullScreenCoverConfig(config: FullScreenCoverConfig())` — full screen cover with custom configuration

### ResizableSheetConfig

Controls sheet presentation behavior. All parameters optional with sensible defaults.

```swift
ResizableSheetConfig(
    detents: Set<PresentationDetentTransformable> = [.large],  // .medium, .large, .height(CGFloat), .fraction(CGFloat)
    selection: Binding<PresentationDetentTransformable>? = nil, // programmatic detent control
    dragIndicator: Visibility = .automatic,                     // .automatic, .visible, .hidden
    background: EnvironmentBackgroundOption = .automatic,       // .automatic, .clear, .custom(any ShapeStyle) (iOS 16.4+)
    cornerRadius: CGFloat? = nil,                               // custom corner radius (iOS 16.4+)
    backgroundInteraction: PresentationBackgroundInteractionBackSupport = .automatic,  // .automatic, .disabled, .enabled (iOS 16.4+)
    contentInteraction: PresentationContentInteractionBackSupport = .automatic         // .automatic, .resizes, .scrolls (iOS 16.4+)
)
```

```swift
// Half-sheet with drag indicator
router.showScreen(.sheetConfig(config: ResizableSheetConfig(
    detents: [.medium, .large],
    dragIndicator: .visible
))) { router in
    SettingsView()
}

// Fixed-height sheet
router.showScreen(.sheetConfig(config: ResizableSheetConfig(
    detents: [.height(300)]
))) { router in
    QuickActionView()
}
```

### FullScreenCoverConfig

```swift
FullScreenCoverConfig(
    background: EnvironmentBackgroundOption = .automatic  // .automatic, .clear, .custom(any ShapeStyle) (iOS 16.4+)
)
```

### SegueLocation

Controls where in the navigation hierarchy the new screen is inserted.

- `.insert` — insert at the call-site router's position (default)
- `.append` — append to the end of the active stack
- `.insertAfter(id: String)` — insert after a specific screen's router

### Dismiss screens

```swift
router.dismissScreen()                          // dismiss current screen
router.dismissScreen(id: "screen_id")           // dismiss specific screen
router.dismissScreens(count: 2)                 // dismiss last N screens
router.dismissScreens(upToId: "screen_id")      // dismiss down to specific screen
router.dismissPushStack()                       // dismiss current push stack
router.dismissEnvironment()                     // dismiss current environment (sheet/cover)
router.dismissLastScreen()                      // dismiss last screen in hierarchy
router.dismissLastPushStack()                   // dismiss last push stack in hierarchy
router.dismissLastEnvironment()                 // dismiss last environment in hierarchy
router.dismissAllScreens()                      // dismiss everything back to root
```

## Alerts (showAlert)

ALWAYS use `router.showAlert()` instead of native `.alert()` or `.confirmationDialog()`.

```swift
// Basic alert with OK button
router.showAlert(.alert, title: "Success", subtitle: "Item saved.")

// Alert with custom buttons
router.showAlert(.alert, title: "Delete?", subtitle: "This cannot be undone.") {
    Button("Delete", role: .destructive) {
        delete()
    }
    Button("Cancel", role: .cancel, action: { })
}

// Confirmation dialog (action sheet style)
router.showAlert(.confirmationDialog, title: "Options", subtitle: "Choose an action") {
    Button("Share", action: { share() })
    Button("Delete", role: .destructive, action: { delete() })
    Button("Cancel", role: .cancel, action: { })
}

// Simple notification-style alert
router.showBasicAlert(text: "Copied!")
```

### Alert with TextField

```swift
var textfieldText: String = ""

router.showAlert(.alert, title: "Enter Name", subtitle: "What should we call you?") {
    TextField("Your name", text: Binding(get: {
        textfieldText
    }, set: { newValue in
        textfieldText = newValue
    }))

    Button("Submit") {
        print(textfieldText)
    }
    Button("Cancel", role: .cancel, action: { })
}
```

### AlertStyle

- `.alert` — standard centered alert (default)
- `.confirmationDialog` — action sheet from bottom

### AlertLocation

- `.topScreen` — show on topmost screen in hierarchy (default)
- `.currentScreen` — show on the calling screen

### Dismiss alerts

```swift
router.dismissAlert()
router.dismissAllAlerts()
```

## Modals (showModal)

Custom overlay views with full control over transition, animation, alignment, and background. Use when the user says "modal", "popup", "overlay", or "bottom sheet".

### Common patterns

```swift
// Bottom modal (most common) — flush against bottom edge, full width
router.showModal(
    transition: .move(edge: .bottom),
    animation: .smooth,
    alignment: .bottom,
    backgroundColor: Color.black.opacity(0.4),
    dismissOnBackgroundTap: true,
    ignoreSafeArea: true
) {
    VStack {
        // modal content
    }
    .frame(maxWidth: .infinity)
    .frame(height: 400)
    .background(Color(.systemBackground))
    .cornerRadius(16, corners: [.topLeft, .topRight])
}

// Center modal / popup — padded from edges, fixed size
router.showModal(
    transition: .opacity,
    animation: .smooth(duration: 0.3),
    alignment: .center,
    backgroundColor: Color.black.opacity(0.4),
    dismissOnBackgroundTap: true,
    ignoreSafeArea: true
) {
    VStack {
        // modal content
    }
    .padding()
    .frame(maxWidth: .infinity)
    .padding(.horizontal, 40)
    .background(Color(.systemBackground))
    .cornerRadius(16)
}

// Convenience — basic center modal (no background, opacity transition)
router.showBasicModal {
    ModalContent()
}

// Convenience — bottom modal (move from bottom, dark background)
router.showBottomModal {
    ModalContent()
}
```

### Full signature

```swift
router.showModal(
    id: String = UUID().uuidString,
    location: ModalLocation = .currentRouter,    // .currentRouter (default) or .topRouter
    transition: AnyTransition = .identity,       // .opacity, .move(edge:), .scale, .slide, .identity
    animation: Animation = .smooth,              // .smooth, .easeInOut, .spring(), etc.
    alignment: Alignment = .center,              // .center, .bottom, .top, .leading, .trailing
    backgroundColor: Color? = nil,               // dimming layer behind modal
    backgroundEffect: BackgroundEffect? = nil,   // blur effect behind modal
    dismissOnBackgroundTap: Bool = true,
    ignoreSafeArea: Bool = true,
    onDismiss: (() -> Void)? = nil,
    destination: @escaping () -> some View
)
```

### Modal location

**Default to `.currentRouter`.** Only use `.topRouter` when the user explicitly says the modal is appearing behind the tab bar or behind some other persistent UI layer. The typical symptom is: "the modal shows up but the tab bar is in front of it."

`.topRouter` resolves to the root router of the current `RouterView` hierarchy (the first router in the stack), so the modal renders above everything within that hierarchy.

```swift
// Default — modal appears on the current screen (use this unless told otherwise)
router.showModal {
    MyModal()
}

// Only when user reports the tab bar is covering the modal
router.showModal(location: .topRouter) {
    MyModal()
}

// Match location on dismiss
router.dismissModal(location: .topRouter)
```

### Background blur effect

```swift
router.showModal(
    transition: .move(edge: .bottom),
    animation: .spring(),
    alignment: .center,
    backgroundColor: Color.black.opacity(0.4),
    backgroundEffect: BackgroundEffect(
        effect: UIBlurEffect(style: .systemMaterialDark),
        intensity: 0.1
    ),
    dismissOnBackgroundTap: true,
    ignoreSafeArea: true
) {
    ModalContent()
}
```

### Dismiss modals

All dismiss methods accept an optional `location` parameter (default `.currentRouter`):

```swift
router.dismissModal()                                        // dismiss top modal on current router
router.dismissModal(location: .topRouter)                    // dismiss top modal on root router
router.dismissModal(id: "modal_id")                          // dismiss specific modal on current router
router.dismissModal(id: "modal_id", location: .topRouter)    // dismiss specific modal on root router
router.dismissModals(count: 2)                               // dismiss last N modals on current router
router.dismissModals(count: 2, location: .topRouter)         // dismiss last N modals on root router
router.dismissModals(upToId: "modal_id")                     // dismiss down to specific modal
router.dismissModals(upToId: "modal_id", location: .topRouter)
router.dismissAllModals()                                    // dismiss all modals on current router
router.dismissAllModals(location: .topRouter)                // dismiss all modals on root router
```

## Transitions (showTransition)

Replaces the current screen content with a new view using a SwiftUI transition. This is NOT a segue — it swaps what's displayed. Use only when explicitly asked.

```swift
router.showTransition(.trailing) { router in
    NewContentView()
}

router.showTransition(.trailing, allowsSwipeBack: true) { router in
    NewContentView()
}
```

### TransitionOption

- `.trailing` — slide in from trailing edge (default)
- `.leading` — slide in from leading edge
- `.top` — slide in from top
- `.bottom` — slide in from bottom
- `.opacity` — fade in
- `.scale` — scale in
- `.slide` — slide
- `.identity` — no animation

### Dismiss transitions

```swift
router.dismissTransition()
router.dismissTransition(id: "id")
router.dismissTransitions(count: 2)
router.dismissTransitions(upToId: "id")
router.dismissAllTransitions()
router.dismissTransitionOrDismissScreen()       // dismiss transition, or screen if no transition
```

## Modules (showModule)

Replaces the entire screen hierarchy. Only use when the app has module switching already set up at the root with `addModuleSupport: true`.

Typical use case: switching between onboarding and main app.

```swift
// Setup at root
RouterView(id: "onboarding", addNavigationStack: false, addModuleSupport: true) { _ in
    OnboardingView()
}

// Switch modules
router.showModule(.trailing, id: "tabbar") { _ in
    TabBarView()
}
```

### Dismiss modules

```swift
router.dismissModule()
router.dismissModule(id: "id")
router.dismissModules(count: 2)
router.dismissModules(upToId: "id")
router.dismissAllModules()
```

## Screen Queue

Pre-load a sequence of screens and show them one at a time.

```swift
// Build destinations
let screen1 = AnyDestination(.push) { router in Screen1() }
let screen2 = AnyDestination(.push) { router in Screen2() }
let screen3 = AnyDestination(.push) { router in Screen3() }

// Add to queue
router.addScreensToQueue(destinations: [screen1, screen2, screen3])

// Show next screen from queue
router.showNextScreen()

// Show next or dismiss if queue empty
router.showNextScreenOrDismissScreen()
router.showNextScreenOrDismissEnvironment()
router.showNextScreenOrDismissPushStack()

// Inspect queue
router.activeScreenQueue          // [AnyDestination]
router.hasScreenInQueue           // Bool

// Remove from queue
router.removeScreenFromQueue(id: "id")
router.removeScreensFromQueue(ids: ["id1", "id2"])
router.removeAllScreensFromQueue()
```

## Transition Queue

Pre-load a sequence of transitions and show them one at a time.

```swift
let t1 = AnyTransitionDestination(.trailing) { router in Page1() }
let t2 = AnyTransitionDestination(.trailing) { router in Page2() }

router.addTransitionsToQueue(transitions: [t1, t2])
router.showNextTransition()

// Cascade fallback
router.showNextTransitionOrNextScreenOrDismissScreen()

// Inspect queue
router.activeTransitionQueue      // [AnyTransitionDestination]
router.hasTransitionInQueue       // Bool

// Remove from queue
router.removeTransitionFromQueue(id: "id")
router.removeTransitionsFromQueue(ids: ["id1", "id2"])
router.removeAllTransitionsFromQueue()
```

## Safari

```swift
router.showSafari {
    URL(string: "https://www.example.com")!
}
```

## Native Swipe-Back Gesture

SwiftUI overrides the `UINavigationController` interactive pop gesture recognizer delegate, which disables the native edge-swipe-back gesture. To re-enable it globally, add this extension once in `Extensions/UINavigationController+EXT.swift`:

```swift
import Foundation

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard UINavigationController.allowsSwipeBack else {
            return false
        }

        return viewControllers.count > 1
    }

    static private(set) var allowsSwipeBack: Bool = true

    static func setSwipeBack(enabled: Bool) {
        allowsSwipeBack = enabled
    }
}
```

- Add this file once per project — it enables swipe-back on all push screens globally
- Use `UINavigationController.setSwipeBack(enabled: false/true)` to toggle on screens where swipe-back conflicts with horizontal gestures (e.g. carousels, pagers)
- The file belongs in `Extensions/UINavigationController+EXT.swift` and requires no other wiring

```swift
// Disable on a screen that has a conflicting horizontal gesture
.onAppear { UINavigationController.setSwipeBack(enabled: false) }
.onDisappear { UINavigationController.setSwipeBack(enabled: true) }
```

## Usage Guide

### Always use router APIs over native SwiftUI

IMPORTANT: Any app using SwiftfulRouting MUST use the router for ALL navigation. Never use native SwiftUI navigation APIs directly.

| Instead of... | Use... |
|---|---|
| `NavigationLink` / `.navigationDestination` | `router.showScreen(.push)` |
| `.sheet` | `router.showScreen(.sheet)` |
| `.fullScreenCover` | `router.showScreen(.fullScreenCover)` |
| `.alert` | `router.showAlert(.alert)` |
| `.confirmationDialog` | `router.showAlert(.confirmationDialog)` |
| `NavigationStack { }` (manual wrapper) | Nothing — `RouterView` provides it |

### Default navigation style

When the user doesn't specify how to navigate, default to `showScreen` with `.push`. This is the standard SwiftUI navigation push and covers most use cases.

### When to use showModal vs showScreen(.sheet)

- Use `showScreen(.sheet)` for standard iOS sheet presentations (swipe to dismiss, standard appearance)
- Use `showModal` when the user says "modal", "popup", "overlay", or wants custom positioning, transitions, background dimming, or blur effects
- `showModal` provides full control over appearance; `showScreen(.sheet)` uses the native sheet

### Modal defaults

When the user asks for a modal without specifying details:
- **"bottom modal" / "bottom sheet"** — `transition: .move(edge: .bottom)`, `alignment: .bottom`, `backgroundColor: Color.black.opacity(0.4)`, `dismissOnBackgroundTap: true`, `ignoreSafeArea: true`
- **"popup" / "center modal"** — `transition: .opacity`, `alignment: .center`, `backgroundColor: Color.black.opacity(0.4)`, `dismissOnBackgroundTap: true`, `ignoreSafeArea: true`
- The developer will often specify how the modal should look — follow their instructions

### When to use showTransition

Rarely. Only use `showTransition` when explicitly asked to "replace the current screen" or "swap content" without a navigation segue. This is not a push, sheet, or cover — it replaces the view in place.

### When to use showModule

Only when the app already has module switching set up at the root with `addModuleSupport: true`. This is primarily for switching between onboarding and the main app. Never recommend `showModule` for typical navigation.

### Low-priority features

The following exist but should rarely be suggested:
- **Screen Queue / Transition Queue** — only use when the user explicitly wants queued navigation flows (e.g. onboarding sequences, tutorials)
- **`showSafari`** — basic SFSafariViewController wrapper; use when asked to open a URL in-app

## Architecture Examples

Match the router access pattern to the app's architecture. If the project passes dependencies manually, pass the router manually. If it uses `@Environment`, use `@Environment(\.router)`.

### MVC (pure SwiftUI) — @Environment

```swift
// Root
RouterView { router in
    HomeView()
}

// View uses @Environment to access router directly
struct HomeView: View {
    @Environment(\.router) var router

    var body: some View {
        Text("Settings")
            .asButton(.press) {
                router.showScreen(.sheet) { router in
                    SettingsView()
                }
            }
    }
}
```

### MVVM — pass router to ViewModel

```swift
// Root
RouterView { router in
    HomeView(viewModel: HomeViewModel(router: router))
}

// ViewModel holds the router
@Observable
@MainActor
class HomeViewModel {
    private let router: AnyRouter

    init(router: AnyRouter) {
        self.router = router
    }

    func onSettingsPressed() {
        router.showScreen(.sheet) { router in
            SettingsView(viewModel: SettingsViewModel(router: router))
        }
    }
}

// View calls ViewModel methods
struct HomeView: View {
    @State var viewModel: HomeViewModel

    var body: some View {
        Text("Settings")
            .asButton(.press) {
                viewModel.onSettingsPressed()
            }
    }
}
```

### VIPER — router wrapped in protocol, presenter drives navigation

```swift
// Router protocol per screen — declares what navigation this screen needs
@MainActor
protocol HomeRouter {
    func showSettingsView()
    func showDetailView(id: String)
}

// CoreRouter wraps AnyRouter + Builder, implements all screen router protocols
struct CoreRouter {
    let router: AnyRouter
    let builder: CoreBuilder
}

extension CoreRouter: HomeRouter {
    func showSettingsView() {
        router.showScreen(.sheet) { router in
            builder.settingsView(router: router)
        }
    }

    func showDetailView(id: String) {
        router.showScreen(.push) { router in
            builder.detailView(router: router, id: id)
        }
    }
}

// Presenter holds router + interactor, View calls presenter
@Observable
@MainActor
class HomePresenter {
    private let interactor: HomeInteractor
    private let router: HomeRouter

    init(interactor: HomeInteractor, router: HomeRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onSettingsPressed() {
        interactor.trackEvent(event: .settingsTapped)
        router.showSettingsView()
    }
}

// View only talks to presenter
struct HomeView: View {
    @State var presenter: HomePresenter

    var body: some View {
        Text("Settings")
            .asButton(.press) {
                presenter.onSettingsPressed()
            }
    }
}

// Builder creates views with all dependencies wired
extension CoreBuilder {
    func homeView(router: AnyRouter, delegate: HomeDelegate) -> some View {
        HomeView(
            presenter: HomePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
```
