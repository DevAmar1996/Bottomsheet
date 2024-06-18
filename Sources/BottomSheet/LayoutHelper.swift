//
//  LayoutHelper.swift
//  MSA
//
//  Created by Qamar/Salah Amassi on 4/18/20. orignal code from LBTA Library
//  Copyright © 2020 WincMSAEngine. All rights reserved.
//
#if canImport(UIKit)
import UIKit

internal struct AnchoredConstraints {
    public var top, leading, left, bottom, trailing, right, centerY, centerX, width, height: NSLayoutConstraint?
}

internal typealias BarButtonItemAction = ((_ sender: UIBarButtonItem) -> Void)
internal typealias ButtonAction = ((_ sender: UIButton) -> Void)

internal enum Anchor {
    case top(_ top: NSLayoutYAxisAnchor, constant: CGFloat = 0)
    case left(_ left: NSLayoutXAxisAnchor, constant: CGFloat = 0)
    case leading(_ leading: NSLayoutXAxisAnchor, constant: CGFloat = 0)
    case bottom(_ bottom: NSLayoutYAxisAnchor, constant: CGFloat = 0)
    case trailing(_ trailing: NSLayoutXAxisAnchor, constant: CGFloat = 0)
    case right(_ right: NSLayoutXAxisAnchor, constant: CGFloat = 0)
    case centerY(_ layoutYAxis: NSLayoutYAxisAnchor, constant: CGFloat = 0)
    case centerX(_ layoutXAxis: NSLayoutXAxisAnchor, constant: CGFloat = 0)
    case center(_ layoutYAxis: NSLayoutYAxisAnchor, constant: CGFloat = 0, layoutXAxis: NSLayoutXAxisAnchor, constantX: CGFloat = 0)
    case centerYInParent(_ constant: CGFloat = 0)
    case centerXInParent(_ constant: CGFloat = 0)
    case centerInParent(_ constant: CGFloat = 0)
    case height(_ constant: CGFloat)
    case width(_ constant: CGFloat)
    case widthGreaterThanOrEqual(_ constant: CGFloat)
    case widthLessThanOrEqual(_ constant: CGFloat)
    case fillSuperview(_ padding: UIEdgeInsets = .zero, safeArea: Bool = false)
    case fillSuperviewHorizontally(_ padding: UIEdgeInsets = .zero, safeArea: Bool = false)
    case fillSuperviewVertically(_ padding: UIEdgeInsets = .zero, safeArea: Bool = false)
    @available(*, deprecated, message: "user fillSuperView with safeArea = true")
    case fillSuperviewWithSafeAreaLayoutGuide(_ padding: UIEdgeInsets = .zero)
}

internal extension UIView {
    
    @discardableResult
    func anchor(_ anchors: Anchor...) -> AnchoredConstraints {
        return anchor(anchors)
    }
    //
    @discardableResult
    func anchor(_ anchors: [Anchor]) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        anchors.forEach { anchor in
            switch anchor {
            case .top(let anchor, let constant):
                anchoredConstraints.top = topAnchor.constraint(equalTo: anchor, constant: constant)
                
            case .leading(let anchor, let constant):
                anchoredConstraints.leading = leadingAnchor.constraint(equalTo: anchor, constant: constant)
                
            case .left(let anchor, let constant):
                anchoredConstraints.left = leftAnchor.constraint(equalTo: anchor, constant: constant)
                
            case .bottom(let anchor, let constant):
                anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: anchor, constant: -constant)
                //
            case .trailing(let anchor, let constant):
                anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: anchor, constant: -constant)
                
            case .right(let anchor, let constant):
                anchoredConstraints.right = rightAnchor.constraint(equalTo: anchor, constant: -constant)
            case .centerY(let anchor, let constant):
                anchoredConstraints.centerY = centerYAnchor.constraint(equalTo: anchor, constant: constant)
            case .centerX(let anchor, let constant):
                anchoredConstraints.centerX = centerXAnchor.constraint(equalTo: anchor, constant: constant)
                
            case .center(let anchorY, let constantY, let anchorX, let constantX):
                anchoredConstraints.centerY = centerYAnchor.constraint(equalTo: anchorY, constant: constantY)
                anchoredConstraints.centerX = centerXAnchor.constraint(equalTo: anchorX, constant: constantX)
                
                
            case .centerYInParent(let constant):
                if let superview = superview {
                    anchoredConstraints.centerY = centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: constant)
                }
                
            case .centerXInParent(let constant):
                if let superview = superview {
                    anchoredConstraints.centerX = centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: constant)
                }
                
            case .centerInParent(let constant):
                if let superview = superview {
                    anchoredConstraints.centerY = centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: constant)
                    anchoredConstraints.centerX = centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: constant)
                }
                
            case .height(let constant):
                if constant > 0 {
                    anchoredConstraints.height = heightAnchor.constraint(equalToConstant: constant)
                }
                
            case .width(let constant):
                if constant > 0 {
                    anchoredConstraints.width = widthAnchor.constraint(equalToConstant: constant)
                }
                
            case .widthGreaterThanOrEqual(let constant):
                if constant > 0 {
                    anchoredConstraints.width = widthAnchor.constraint(greaterThanOrEqualToConstant: constant)
                }
            case .widthLessThanOrEqual(let constant):
                if constant > 0 {
                    anchoredConstraints.width = widthAnchor.constraint(lessThanOrEqualToConstant: constant)
                }
            case .fillSuperview(let padding, let safeArea):
                anchoredConstraints = fillSuperview(padding: padding, safeArea: safeArea)
                
            case .fillSuperviewHorizontally(let padding, let safeArea):
                anchoredConstraints = fillSuperviewHorizontally(padding: padding, safeArea: safeArea)
                
            case .fillSuperviewVertically(let padding, let safeArea):
                anchoredConstraints = fillSuperviewVertically(padding: padding, safeArea: safeArea)
                
            case .fillSuperviewWithSafeAreaLayoutGuide(let padding):
                anchoredConstraints = fillSuperviewSafeAreaLayoutGuide(padding: padding)
                
                
                
            }
        }
        [anchoredConstraints.top,
         anchoredConstraints.leading,
         anchoredConstraints.left,
         anchoredConstraints.bottom,
         anchoredConstraints.trailing,
         anchoredConstraints.right,
         anchoredConstraints.centerY,
         anchoredConstraints.centerX,
         anchoredConstraints.width,
         anchoredConstraints.height].forEach {
            $0?.isActive = true
        }
        return anchoredConstraints
    }
    
    // to not broke the app compatibility
    @discardableResult
    func anchor(top: NSLayoutYAxisAnchor? = nil, leading: NSLayoutXAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, trailing: NSLayoutXAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, padding: UIEdgeInsets = .zero, size: CGSize = .zero) -> AnchoredConstraints {
        
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        
        if let top = top {
            anchoredConstraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)
        }
        
        if let leading = leading {
            anchoredConstraints.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
        }
        
        if let bottom = bottom {
            anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
        }
        
        if let trailing = trailing {
            anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
        }
        
        if let right = right {
            anchoredConstraints.right = rightAnchor.constraint(equalTo: right, constant: -padding.right)
        }
        
        if size.width != 0 {
            anchoredConstraints.width = widthAnchor.constraint(equalToConstant: size.width)
        }
        
        if size.height != 0 {
            anchoredConstraints.height = heightAnchor.constraint(equalToConstant: size.height)
        }
        
        [ anchoredConstraints.top,
          anchoredConstraints.leading,
          anchoredConstraints.left,
          anchoredConstraints.bottom,
          anchoredConstraints.trailing,
          anchoredConstraints.right,
          anchoredConstraints.centerY,
          anchoredConstraints.centerX,
          anchoredConstraints.width,
          anchoredConstraints.height].forEach {
            $0?.isActive = true
        }
        
        return anchoredConstraints
    }
    
    @discardableResult
    func fillSuperview(padding: UIEdgeInsets = .zero, safeArea: Bool = false) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        let anchoredConstraints = AnchoredConstraints()
        guard let superviewTopAnchor = safeArea ? superview?.safeAreaLayoutGuide.topAnchor : superview?.topAnchor,
              let superviewBottomAnchor = safeArea ? superview?.safeAreaLayoutGuide.bottomAnchor : superview?.bottomAnchor,
              let superviewLeadingAnchor = safeArea ? superview?.safeAreaLayoutGuide.leadingAnchor :superview?.leadingAnchor,
              let superviewTrailingAnchor = safeArea ? superview?.safeAreaLayoutGuide.trailingAnchor : superview?.trailingAnchor else {
            return anchoredConstraints
        }
        return anchor(top: superviewTopAnchor, leading: superviewLeadingAnchor, bottom: superviewBottomAnchor, trailing: superviewTrailingAnchor, padding: padding)
    }
    //
    @discardableResult
    func fillSuperviewHorizontally(padding: UIEdgeInsets = .zero, safeArea: Bool = false) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        let anchoredConstraints = AnchoredConstraints()
        guard let superviewLeadingAnchor = safeArea ? superview?.safeAreaLayoutGuide.leadingAnchor :superview?.leadingAnchor,
              let superviewTrailingAnchor = safeArea ? superview?.safeAreaLayoutGuide.trailingAnchor : superview?.trailingAnchor else {
            return anchoredConstraints
        }
        return anchor(top: nil, leading: superviewLeadingAnchor, bottom: nil, trailing: superviewTrailingAnchor, padding: padding)
    }
    //
    @discardableResult
    func fillSuperviewVertically(padding: UIEdgeInsets = .zero, safeArea: Bool = false) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        let anchoredConstraints = AnchoredConstraints()
        guard let superviewTopAnchor = safeArea ? superview?.safeAreaLayoutGuide.topAnchor : superview?.topAnchor,
              let superviewBottomAnchor = safeArea ? superview?.safeAreaLayoutGuide.bottomAnchor : superview?.bottomAnchor else {
            return anchoredConstraints
        }
        return anchor(top: superviewTopAnchor, leading: nil, bottom: superviewBottomAnchor, trailing: nil, padding: padding)
    }
    
    @discardableResult
    func fillSuperviewSafeAreaLayoutGuide(padding: UIEdgeInsets = .zero) -> AnchoredConstraints {
        let anchoredConstraints = AnchoredConstraints()
        guard let superviewTopAnchor = superview?.safeAreaLayoutGuide.topAnchor,
              let superviewBottomAnchor = superview?.safeAreaLayoutGuide.bottomAnchor,
              let superviewLeadingAnchor = superview?.safeAreaLayoutGuide.leadingAnchor,
              let superviewTrailingAnchor = superview?.safeAreaLayoutGuide.trailingAnchor else {
            return anchoredConstraints
        }
        return anchor(top: superviewTopAnchor, leading: superviewLeadingAnchor, bottom: superviewBottomAnchor, trailing: superviewTrailingAnchor, padding: padding)
    }
    
    func centerInSuperview(size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
        }
        
        if let superviewCenterYAnchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    @discardableResult
    func constrainHeight(_ constant: CGFloat) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        anchoredConstraints.height = heightAnchor.constraint(equalToConstant: constant)
        anchoredConstraints.height?.isActive = true
        return anchoredConstraints
    }
    
    @discardableResult
    func constrainWidth(_ constant: CGFloat) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        anchoredConstraints.width = widthAnchor.constraint(equalToConstant: constant)
        anchoredConstraints.width?.isActive = true
        return anchoredConstraints
    }
}

extension UIView {
    
    @discardableResult
    func with(alpha: CGFloat) -> UIView {
        self.alpha = alpha
        return self
    }
    
    @discardableResult
    func with(cornerRadius: CGFloat) -> UIView {
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        return self
    }
    
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
    
    
    @discardableResult
    func with(corners: UIRectCorner, radius: CGFloat) -> UIView {
        let mask = _round(corners: corners, radius: radius)
        addBorder(mask: mask)
        return self
    }
    
    @discardableResult func _round(corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        return mask
    }
    
    func addBorder(mask: CAShapeLayer) {
        let borderLayer = CAShapeLayer()
        borderLayer.path = mask.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = bounds
        layer.addSublayer(borderLayer)
    }
    
}
#endif
