// The Swift Programming Language
// https://docs.swift.org/swift-book
//
//  BottomSheetView.swift
//  MSA
//
//  Created by Qamar/Salah Amassi on 1/25/20.
//  Copyright © 2020  Qamar/Salah. All rights reserved.
//
#if canImport(UIKit)
import UIKit

/// Bottom sheet view like facebook app
open class BottomSheetView: UIView {

    enum SheetStatus {
        case showed, hidden, topMode
    }

    open class func initFromNib() -> BottomSheetView {
        preconditionFailure("This method must be overridden")
    }

    private var viewBottomConstraint: NSLayoutConstraint?

    private var wrapperViewBottomConstraint: NSLayoutConstraint?
    
    private var wrapperViewWidthConstraint: NSLayoutConstraint?


    private var wrapperViewHeightConstraint: NSLayoutConstraint?

    private let bottomSheetPercentageHeight: CGFloat = 1.3

    private var fixedBottomSpaceUnderEdgePercentage: CGFloat = 0.25

    private var fixedBottomSpaceUnderEdgeValue: CGFloat {
        get {
            return UIScreen.main.bounds.height * fixedBottomSpaceUnderEdgePercentage
        }
    }

    private var totalViewHeight: CGFloat {
        get {
            return (UIScreen.main.bounds.height / bottomSheetPercentageHeight) + fixedBottomSpaceUnderEdgeValue
        }
    }

    private var bottomSpaceUnderEdgeValue: CGFloat {
        get {
            if let viewHeight = viewHeight {
                return totalViewHeight - viewHeight
            } else {
                return fixedBottomSpaceUnderEdgeValue
            }
        }
    }

    private var hasSafeArea: Bool {
        let appWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first
        guard
               let topPadding = appWindow?.safeAreaInsets.top, topPadding > 24 else {
            return false
        }
        return true
    }

    private lazy var blackMaskViewPanGestureRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleBottomSheetPanGestureRecognizer))
        panGestureRecognizer.isEnabled = enableGestureRecognizer
        return panGestureRecognizer
    }()

    private lazy var viewPanGestureRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleBottomSheetPanGestureRecognizer))
        panGestureRecognizer.isEnabled = enableGestureRecognizer
        return panGestureRecognizer
    }()

    private lazy var blackMaskTapGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBlackMaskTapTapGestureRecognizer))
        tapGestureRecognizer.isEnabled = enableGestureRecognizer
        return tapGestureRecognizer
    }()

    lazy var topIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 75).isActive = true
        view.heightAnchor.constraint(equalToConstant: 5).isActive = true
        return view
    }()

    private var viewHeightConstraint: NSLayoutConstraint?
    private var viewLeadingConstraint: NSLayoutConstraint?

    private (set) var isKeyboardShowed = false
    private (set) var sheetStatus: SheetStatus = SheetStatus.hidden

    var isTopModeSheet = false
    var mustObserveKeyboardChanges = false
    var notchHeight: CGFloat = .zero

    var needTopIndicator: Bool = true

    private var viewHeight: CGFloat? {
        didSet {
            if sheetStatus == .showed {
                wrapperViewBottomConstraint?.constant = bottomSpaceUnderEdgeValue
            }
            if let viewHeight = viewHeight {
                viewBottomConstraint?.constant = -(totalViewHeight - viewHeight)
            }
        }
    }
    
    open var isfixedHeight: Bool = false {
        didSet {
            resetViewHeight()
        }
    }
 
    
    private func resetViewHeight() {
        if self.isfixedHeight {
            viewHeight = getScreenHeightWithoutNavigationBar()
        }else {
            viewHeight = computeViewHeightAccordingToSubviews()
        }
    }
    
    
    var enableGestureRecognizer = true {
        didSet {
            viewPanGestureRecognizer.isEnabled = enableGestureRecognizer
        }
    }

    var animationDurationForShowing = 0.35
    var animationDurationForHiding = 0.35
    var animationDurationForHidingToTopMode = 0.75
    var maxBlackMaskAlpha: CGFloat = 0.6
    var parentHeight: CGFloat = 0

    let viewController = UIViewController()
    private var parentViewController: UIViewController?

    private let wrapperView = UIView()
    private let containerView = UIView()
    private let blackMaskView = UIView()
    

    /// sheet in showing progess
   open func willShowSheet() {}

    /// sheet in showing in top mode progess
    open func willShowSheetAsTopMode() {}

    /// sheet in hidding progess
    open func willHideSheet() {}

    /// sheet in hidding to top mode progess
    open func willHideSheetToTopMode() {}

    /// sheet show finished
    open func didShowSheet() {}

    /// sheet show in top mode finished
    open func didShowSheetAsTopMode() {}

    /// sheet hide finished
    open func didHideSheet() {}

    /// sheet hide finished and now showed in top mode
    open  func didHideSheetToTopMode() {}

    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }
    
   private func getScreenHeightWithoutNavigationBar() -> CGFloat {
     

       return UIScreen.main.bounds.height * 0.9
    }
    
    func computeViewHeightAccordingToSubviews() -> CGFloat {
        var totalHeight: CGFloat = 0.0
        
        for subview in subviews {
             let margins = subview.layoutMargins
             totalHeight += margins.top + margins.bottom
            if let sv = subview as? UIScrollView {
                totalHeight += sv.contentSize.height
            } else {
                totalHeight += subview.frame.height
            }
        }
        print("Total height is ", totalHeight)
        return totalHeight
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        //Configuration for light and dark mode
//        overrideUserInterfaceStyle = UserDefaultsManager.isDarkMode || traitCollection.userInterfaceStyle == .dark ? .dark : .light
//        viewController.overrideUserInterfaceStyle = UserDefaultsManager.isDarkMode || traitCollection.userInterfaceStyle == .dark ? .dark : .light
        if !isTopModeSheet {
            setupSheetView()
        }
    

    }


    /// add sheet view to viewController and setup views
    func setupSheetView() {
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else {return}
        viewController.view.frame =  window.frame
        viewController.view.backgroundColor = .clear
        viewController.view.addSubview(blackMaskView)
        viewController.view.addSubview(wrapperView)
        viewController.view.addSubview(topIndicatorView)

        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overCurrentContext
        wrapperView.backgroundColor = backgroundColor
        blackMaskView.backgroundColor = UIColor.black.withAlphaComponent(0)
        topIndicatorView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor).isActive = true
        blackMaskView.fillSuperview()
//        wrapperView.anchor(leading: viewController.view.leadingAnchor, trailing: viewController.view.trailingAnchor, padding: .init(top: 0, left: isIpad ? 20 : 0, bottom: 0, right:  isIpad ?  20 : 0))
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
         wrapperViewHeightConstraint =  wrapperView.heightAnchor.constraint(equalToConstant: totalViewHeight)
        wrapperView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor).isActive = true
        wrapperViewWidthConstraint = wrapperView.widthAnchor.constraint(equalToConstant:  isIpad ? (UIScreen.main.fixedCoordinateSpace.bounds.width * 0.9) : UIScreen.main.fixedCoordinateSpace.bounds.width)
        wrapperViewBottomConstraint = wrapperView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor, constant: totalViewHeight)
        wrapperViewWidthConstraint?.isActive = true
        wrapperViewHeightConstraint?.isActive = true
        wrapperViewBottomConstraint?.isActive = true
        topIndicatorView.anchor(bottom: wrapperView.topAnchor, padding: .init(top: 0, left: 0, bottom: 6, right: 0))
        wrapperView.addSubview(self)
        fillSuperview(padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        blackMaskView.addGestureRecognizer(blackMaskTapGestureRecognizer)
        blackMaskView.addGestureRecognizer(blackMaskViewPanGestureRecognizer)
        addGestureRecognizer(viewPanGestureRecognizer)
        if mustObserveKeyboardChanges {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
    }
    
    open func updateConstraintsForRotation(size: CGSize) {
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        if !isIpad {return}
        resetViewHeight()
        self.wrapperViewHeightConstraint?.constant = totalViewHeight
        if sheetStatus != .showed {return}
//        self.wrapperViewBottomConstraint?.constant = bottomSpaceUnderEdgeValue

        hide {
           self.show()
        }
        // Calculate the new totalViewHeight based on the updated size or any other necessary logic
    }

    open func recalcualteContentHeight() {
        resetViewHeight()
    }


    @discardableResult
    func setupTopModeSheet(with parent: UIViewController, notchHeight: CGFloat) -> BottomSheetView {
        isTopModeSheet = true
        self.notchHeight = notchHeight
        willShowSheetAsTopMode()
        let height: CGFloat
        if hasSafeArea {
            height = 108
        } else {
            height = 76
        }

        containerView.backgroundColor = .clear
        viewController.view.backgroundColor = .clear
        blackMaskView.backgroundColor = UIColor.black.withAlphaComponent(0)
        wrapperView.backgroundColor = backgroundColor

        parent.view.addSubview(containerView)
        containerView.anchor(.leading(parent.view.trailingAnchor, constant: .zero),
                             .leading(parent.view.leadingAnchor, constant: .zero))

        let safeHeight = parent.view.frame.height - 88 // 88 is nav bar height
        containerView.heightAnchor.constraint(equalToConstant: safeHeight).isActive = true
        wrapperViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor, constant: 0)
        wrapperViewBottomConstraint?.isActive = true

        containerView.addSubview(viewController.view)

        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.view.addSubview(topIndicatorView)
        viewController.view.addSubview(wrapperView)

        topIndicatorView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor).isActive = true
        wrapperView.anchor(.top(topIndicatorView.bottomAnchor, constant: 8),
                           .leading(viewController.view.leadingAnchor, constant: .zero),
                           .bottom(viewController.view.bottomAnchor, constant: .zero),
                           .trailing(viewController.view.trailingAnchor, constant: .zero))

        wrapperView.addSubview(self)
        topIndicatorView.anchor(.top(wrapperView.topAnchor, constant: 5))

        anchor(.top(wrapperView.topAnchor, constant: .zero),
               .leading(wrapperView.leadingAnchor, constant: .zero),
               .bottom(wrapperView.bottomAnchor, constant: fixedBottomSpaceUnderEdgeValue),
               .trailing(wrapperView.trailingAnchor, constant: .zero))

        parent.addChild(viewController)
        viewController.didMove(toParent: parent)

        blackMaskView.addGestureRecognizer(blackMaskTapGestureRecognizer)
        blackMaskView.addGestureRecognizer(blackMaskViewPanGestureRecognizer)
        addGestureRecognizer(viewPanGestureRecognizer)
        wrapperViewBottomConstraint?.constant = parent.view.frame.height - 88 - height - notchHeight // 88 navbar height
        parentHeight = parent.view.frame.height

        wrapperView.with(cornerRadius: 12)
        didShowSheetAsTopMode()
        sheetStatus = .topMode
        topIndicatorView.isHidden = true
        return self
    }

    /// show bottom sheet as top mode or full open
    /// - Parameter topMode:flag for show bottom sheet from top mode status
    open func show(topMode: Bool = false) {
        if topMode {
            showTopMode()
        } else {
            show()
        }
    }

    /// show sheet in top mode
    private func showTopMode() {
        guard let superview = containerView.superview else { return }
        guard let parent = containerView.findViewController() else { return }
        
        if superview.subviews.contains(blackMaskView) == false {
            superview.addSubview(blackMaskView)
            blackMaskView.frame = UIScreen.main.bounds
            superview.bringSubviewToFront(containerView)
        }
        willShowSheet()
        let height: CGFloat
        if hasSafeArea {
            height = 108
        } else {
            height = 76
        }

        wrapperViewBottomConstraint?.constant = parent.view.frame.height - 88 - height - (viewHeight ?? .zero)
        UIView.animate(withDuration: animationDurationForShowing, delay: 0, options: .curveEaseInOut, animations: {
            self.blackMaskView.backgroundColor = UIColor.black.withAlphaComponent(self.maxBlackMaskAlpha)
            self.topIndicatorView.backgroundColor = UIColor.white.withAlphaComponent(1)
            self.topIndicatorView.with(cornerRadius: 1.9)
            self.viewController.view.layoutIfNeeded()
            self.containerView.superview?.layoutIfNeeded()
        }) { (_) in
            self.didShowSheet()
            self.sheetStatus = .showed
        }
    }

    /// show full sheet
    private func show() {
        guard let rootViewController =  UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController else { return }
        willShowSheet()
        rootViewController.present(viewController, animated: false) {
            self.wrapperViewBottomConstraint?.constant = self.bottomSpaceUnderEdgeValue
            UIView.animate(withDuration: self.animationDurationForShowing, delay: 0, options: .curveEaseInOut, animations: {
                self.wrapperView.with(corners: [.topLeft,.topRight], radius: 12.0)
                self.topIndicatorView.with(cornerRadius: 1.9)
                self.topIndicatorView.isHidden = !self.needTopIndicator
                self.topIndicatorView.backgroundColor = UIColor.white.withAlphaComponent(1)
                self.blackMaskView.backgroundColor = UIColor.black.withAlphaComponent(self.maxBlackMaskAlpha)
                self.viewController.view.layoutIfNeeded()
                self.layoutIfNeeded()
            }, completion: { (_) in
                self.didShowSheet()
                self.sheetStatus = .showed
            })
        }
    }

    /// hide bottom sheet full hide or hide  to  top mode
    /// - Parameter topMode: flag to know if must show top mode
   open func hide(topMode: Bool = false, _ completion: (() -> Void)? = nil) {
        if topMode {
            hideToTopMode()
        } else {
            hide(completion)
        }
    }

    /// hide  to  top model
    private func hideToTopMode() {
        willHideSheetToTopMode()
        let height: CGFloat
        if hasSafeArea {
            height = 108
        } else {
            height = 76
        }
        wrapperViewBottomConstraint?.constant = parentHeight - 88 - height - notchHeight  // 88 navbar height

        UIView.animate(withDuration: animationDurationForShowing, delay: 0, options: .curveEaseInOut, animations: {
            self.blackMaskView.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.topIndicatorView.backgroundColor = UIColor.white.withAlphaComponent(0)
            self.topIndicatorView.with(cornerRadius: 0.0)
            self.viewController.view.layoutIfNeeded()
            self.containerView.superview?.layoutIfNeeded()
        }) { (_) in
            self.didHideSheetToTopMode()
            self.sheetStatus = .topMode
            self.blackMaskView.removeFromSuperview()
        }
    }

    /// hide full sheet
    private func hide(_ completion: (() -> Void)?) {
        willHideSheet()
        wrapperViewBottomConstraint?.constant = totalViewHeight
        UIView.animate(withDuration: animationDurationForHiding, delay: 0, options: .curveEaseInOut, animations: {
            self.wrapperView.with(corners: [.topLeft, .topRight], radius: 12.0)
            self.topIndicatorView.with(cornerRadius: 1.9)
            self.topIndicatorView.backgroundColor = UIColor.white.withAlphaComponent(0)
            self.blackMaskView.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.viewController.view.layoutIfNeeded()
            self.layoutIfNeeded()
        }, completion: { (_) in
            self.endEditing(true)
            self.didHideSheet()
            self.sheetStatus = .hidden
            self.viewController.dismiss(animated: false, completion: completion)
        })
    }

    @objc
    private func keyboardWillShow(_ notification: NSNotification) {
        if sheetStatus != .showed { return }
        guard let userInfo = notification.userInfo else { return }
        let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        isKeyboardShowed = true
        UIView.animate(withDuration: 0.3) {
            self.topIndicatorView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
            self.wrapperView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
        }
    }

    @objc
    private func keyboardWillHide(_ notification: NSNotification) {
        if sheetStatus != .showed { return }
        isKeyboardShowed = false
        UIView.animate(withDuration: 0.3) {
            self.topIndicatorView.transform = .identity
            self.wrapperView.transform = .identity
        }
    }

    @objc
    private func handleBlackMaskTapTapGestureRecognizer() {
        if sheetStatus == .showed {
            hide(topMode: isTopModeSheet)
        }
    }

    @objc
    private func handleBottomSheetPanGestureRecognizer(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            handleBottomSheetPanBegan(gesture)
        } else if gesture.state == .changed {
            handleBottomSheetPanChanged(gesture)
        } else if gesture.state == .ended {
            handleBottomSheetPanEnded(gesture)
        }
    }

    private func handleBottomSheetPanBegan(_ gesture: UIPanGestureRecognizer) {
        guard let superview = containerView.superview else { return }
        if isTopModeSheet && sheetStatus != .showed {
            willShowSheet()
            if superview.subviews.contains(blackMaskView) == false {
                superview.addSubview(blackMaskView)
                blackMaskView.frame = UIScreen.main.bounds
                superview.bringSubviewToFront(containerView)
            }
            blackMaskView.backgroundColor = UIColor.black.withAlphaComponent(0.05)
            topIndicatorView.backgroundColor = UIColor.white.withAlphaComponent(1)
            topIndicatorView.with(cornerRadius: 1.9)
        }
    }

    private func handleBottomSheetPanChanged(_ gesture: UIPanGestureRecognizer) {
        if isKeyboardShowed { return }
        let translation = gesture.translation(in: superview)
        if isTopModeSheet {
            let topModeHeight: CGFloat
            if hasSafeArea {
                topModeHeight = 108
            } else {
                topModeHeight = 76
            }
            let height = viewController.view.frame.size.height - topModeHeight
            if abs(translation.y) < height {
                if sheetStatus == .showed {
                    if translation.y > 0 || abs(translation.y) < bottomSpaceUnderEdgeValue {
                        if gesture.view is BottomSheetView && translation.y > 0 { return }
                        containerView.transform = CGAffineTransform(translationX: 0, y: translation.y)
                        let newHight = (height) - translation.y
                        //                        print("newHight", newHight)
                        var alpha: CGFloat = (newHight * maxBlackMaskAlpha) / height
                        if alpha > maxBlackMaskAlpha {
                            alpha = maxBlackMaskAlpha
                        }
                        blackMaskView.backgroundColor = UIColor.black.withAlphaComponent(alpha)
                    }
                } else {
                    containerView.transform = CGAffineTransform(translationX: 0, y: translation.y)
                    let newHight = (topModeHeight) - translation.y
                    //                    print("newHight", newHight)
                    var alpha: CGFloat = (newHight * maxBlackMaskAlpha) / height
                    if alpha > maxBlackMaskAlpha {
                        alpha = maxBlackMaskAlpha
                    }
                    blackMaskView.backgroundColor = UIColor.black.withAlphaComponent(alpha)
                }
                //print("bottomSpaceUnderEdgeValue",bottomSpaceUnderEdgeValue)
                //print("height",height)
            }
        } else {
            let height = totalViewHeight - bottomSpaceUnderEdgeValue
            if translation.y > 0 || abs(translation.y) < bottomSpaceUnderEdgeValue {
                wrapperView.transform = CGAffineTransform(translationX: 0, y: translation.y)
                topIndicatorView.transform = CGAffineTransform(translationX: 0, y: translation.y)
                let newHight = height - translation.y
                var alpha: CGFloat = (newHight * maxBlackMaskAlpha) / height
                if alpha > maxBlackMaskAlpha {
                    alpha = maxBlackMaskAlpha
                }
                blackMaskView.backgroundColor = UIColor.black.withAlphaComponent(alpha)
            }
        }
    }

    private func handleBottomSheetPanEnded(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        if isTopModeSheet {
            UIView.animate(withDuration: animationDurationForHiding, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.containerView.transform = .identity
                if self.sheetStatus == .showed {
                    if gesture.view is BottomSheetView && translation.y > 0 { return }
                    if translation.y > 290  || velocity.y > 500 {
                        self.hideToTopMode()
                    }
                } else {
                    if translation.y < -290  || velocity.y < -500 {
                        self.showTopMode()
                    } else {
                        self.hideToTopMode()
                    }
                }
            })
        } else {
            let height = totalViewHeight - bottomSpaceUnderEdgeValue
            UIView.animate(withDuration: animationDurationForHiding, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                let newHight = height - translation.y
                if newHight < UIScreen.main.bounds.height/2 {
                    self.wrapperView.transform = .identity
                    self.topIndicatorView.transform = .identity
                    self.hide()
                } else {
                    self.wrapperView.transform = .identity
                    self.topIndicatorView.transform = .identity
                    self.blackMaskView.backgroundColor =  UIColor.black.withAlphaComponent(self.maxBlackMaskAlpha)
                }
            })
        }
    }
}
#endif
