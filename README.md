# BottomSheet

## Description
BottomSheetView is a customizable, easy-to-use bottom sheet component for iOS apps. With the introduction of native bottom sheet support in iOS 15, many applications require similar functionality for earlier iOS versions. BottomSheetView addresses this need by providing a solution that is compatible with iOS 13 and above. It allows developers to quickly integrate a fully functional bottom sheet with customizable behaviors and animations.

## Features
* Customizable appearance and transitions.
* Gesture-based interactions (pan and tap).
* Safe area awareness.
* Keyboard interaction handling.
* Dynamic height adjustment based on content.
* Compatibility with both iPhones and iPads.


## Installation

### CocoaPods
To integrate BottomSheetView into your Xcode project using CocoaPods, specify it in your Podfile:

```markdown
pod 'BottomSheetView', '~> 1.0' 
```
### Swift Package Manager
To add BottomSheetView as a dependency to your Swift package, add it to the dependencies value of your Package.swift file:

```markdown
dependencies: [
    .package(url: "https://github.com/YourGitHub/BottomSheetView.git", .upToNextMajor(from: "1.0.0"))
]
```

## Usage
To start using the component, you need to import Bottom SheetView into your project:

```markdown
`
import BottomSheetView
`
```

### Creating a Custom Bottom Sheet
To create a custom bottom sheet view, you can design a .nib file with your desired UI components and layout. You then subclass BottomSheetView to integrate this custom design.

```swift
class SampleBottomsheetView: BottomSheetView {
  // MARK: Lifecycle
    override class func initFromNib() -> SampleBottomsheetView {
        let className = String(describing: SampleBottomsheetView.self)
        return Bundle.init(for: SampleBottomsheetView.self).loadNibNamed(className, owner: self, options: nil)!.first as! SampleBottomsheetView
    }
}
```
### Quick Start
Integrating BottomSheetView with a custom implementation is straightforward. Here's how you can quickly declare and present a bottom sheet in your view controller using a custom subclass.

#### Example: Displaying SampleBottomSheet
First, ensure you have created a custom bottom sheet class and the associated .nib file. Then, you can use the following snippet to instantiate and display the bottom sheet:
```swift
import UIKit

class YourViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize and show the bottom sheet
        let bottomSheet = SampleBottomSheet.initFromNib()
        bottomSheet.show()
    }
}
```

### Handling Device Rotation
Ensure that the bottom sheet adjusts correctly during device rotations by updating its constraints:
```swift
override func viewWill: Transition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: { _ in
        self.bottomSheet?.updateConstraintsForRotation(size: size)
    }, completion: nil)
}
```

### csutomization 
Remember, you can fully customize the appearance and behavior of your bottom sheet within your SampleBottomSheet subclass. Define your UI elements and interactions within the .nib file and corresponding Swift file to fit the specific needs of your application.


