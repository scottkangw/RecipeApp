//
//  TableViewProtocal.swift
//  RecipeApp
//
//  Created by Scott.L on 16/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//

import Foundation
import UIKit


// MARK: Protocol definition
/// Make your `UITableViewCell` and `UICollectionViewCell` subclasses
/// conform to this protocol when they are *not* NIB-based but only code-based
/// to be able to dequeue them in a type-safe manner
public protocol Reusable: class {
    /// The reuse identifier to use when registering and later dequeuing a reusable cell
    static var reuseIdentifier: String { get }
}

/// Make your `UITableViewCell` and `UICollectionViewCell` subclasses
/// conform to this typealias when they *are* NIB-based
/// to be able to dequeue them in a type-safe manner
public typealias NibReusable = Reusable & NibLoadable

// MARK: - Default implementation
public extension Reusable {
    /// By default, use the name of the class as String for its reuseIdentifier
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
// MARK: Protocol Definition
/// Make your UIView subclasses conform to this protocol when:
///  * they *are* NIB-based, and
///  * this class is used as the XIB's root view
///
/// to be able to instantiate them from the NIB in a type-safe manner
public protocol NibLoadable: class {
    /// The nib file to use to load a new instance of the View designed in a XIB
    static var nib: UINib { get }
}

// MARK: Default implementation
public extension NibLoadable {
    /// By default, use the nib which have the same name as the name of the class,
    /// and located in the bundle of that class
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}

// MARK: Support for instantiation from NIB
public extension NibLoadable where Self: UIView {
    /**
     Returns a `UIView` object instantiated from nib
     - returns: A `NibLoadable`, `UIView` instance
     */
    static func loadFromNib() -> Self {
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("The nib \(nib) expected its root view to be of type \(self)")
        }
        return view
    }
}

public extension UIView {
    
    func fillSuperview() {
        guard let superview = superview
            else {
                return
        }
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            topAnchor.constraint(equalTo: superview.topAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor)
        ]
        constraints.forEach {
            $0.priority = UILayoutPriority(999)
            $0.isActive = true
        }
    }
    
    @discardableResult
    func addSubviewAndFill(_ subview: UIView, inset: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            subview.topAnchor.constraint(equalTo: topAnchor, constant: inset.top),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset.left),
            bottomAnchor.constraint(equalTo: subview.bottomAnchor, constant: inset.bottom),
            rightAnchor.constraint(equalTo: subview.rightAnchor, constant: inset.right)
        ]
        constraints.forEach {
            $0.isActive = true
        }
        return constraints
    }
    
    @discardableResult
    func addSubviewCenterXY(_ subview: UIView, width: CGFloat? = nil, height: CGFloat? = nil) -> [NSLayoutConstraint] {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [
            subview.centerXAnchor.constraint(equalTo: centerXAnchor),
            subview.centerYAnchor.constraint(equalTo: centerYAnchor),
        ]
        if let rawWidth = width, let rawHeight = height {
            let rawConstraints = [
                subview.widthAnchor.constraint(equalToConstant: rawWidth),
                subview.heightAnchor.constraint(equalToConstant: rawHeight),
            ]
            constraints.append(contentsOf: rawConstraints)
        }
        constraints.forEach {
            $0.isActive = true
        }
        return constraints
    }
}

// MARK: - Interfacte Builder helpers

public extension UIView {
    
    func viewFromOwnedNib(named nibName: String? = nil) -> UIView {
        let bundle = Bundle(for: self.classForCoder)
        return {
            if let nibName = nibName {
                return bundle.loadNibNamed(nibName, owner: self, options: nil)!.last as! UIView
            }
            return bundle.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)!.last as! UIView
            }()
    }
    
    /// Convenience function for creating a view from a nib file.
    /// Returns an instance of the `UIView` subclass that called the function.
    class func instantiateFromNib() -> Self {
        return self.instantiateFromNib(in: Bundle.main)
    }
    
}

fileprivate extension UIView {
    
    /// Creates a `UIView` subclass from a nib file of the same name. If an XIB file of the same name
    /// as the class does not exist and this function is invoked, a fatal error is thrown
    /// since it is a developer error that must definitely be fixed.
    class func instantiateFromNib<T>(in bundle: Bundle) -> T {
        let objects = bundle.loadNibNamed(String(describing: self), owner: self, options: nil)!
        let view = objects.last as! T
        return view
    }
    
}


// MARK: Reusable support for UITableView
public extension UITableView {
    /**
     Register a NIB-Based `UITableViewCell` subclass (conforming to `Reusable` & `NibLoadable`)
     - parameter cellType: the `UITableViewCell` (`Reusable` & `NibLoadable`-conforming) subclass to register
     - seealso: `register(_:,forCellReuseIdentifier:)`
     */
    final func register<T: UITableViewCell>(cellType: T.Type)
        where T: Reusable & NibLoadable {
            self.register(cellType.nib, forCellReuseIdentifier: cellType.reuseIdentifier)
    }
    
    /**
     Register a Class-Based `UITableViewCell` subclass (conforming to `Reusable`)
     - parameter cellType: the `UITableViewCell` (`Reusable`-conforming) subclass to register
     - seealso: `register(_:,forCellReuseIdentifier:)`
     */
    final func register<T: UITableViewCell>(cellType: T.Type)
        where T: Reusable {
            self.register(cellType.self, forCellReuseIdentifier: cellType.reuseIdentifier)
    }
    
    /**
     Returns a reusable `UITableViewCell` object for the class inferred by the return-type
     - parameter indexPath: The index path specifying the location of the cell.
     - parameter cellType: The cell class to dequeue
     - returns: A `Reusable`, `UITableViewCell` instance
     - note: The `cellType` parameter can generally be omitted and infered by the return type,
     except when your type is in a variable and cannot be determined at compile time.
     - seealso: `dequeueReusableCell(withIdentifier:,for:)`
     */
    final func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T
        where T: Reusable {
            guard let cell = self.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
                fatalError(
                    "Failed to dequeue a cell with identifier \(cellType.reuseIdentifier) matching type \(cellType.self). "
                        + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                        + "and that you registered the cell beforehand"
                )
            }
            return cell
    }
    
    /**
     Register a NIB-Based `UITableViewHeaderFooterView` subclass (conforming to `Reusable` & `NibLoadable`)
     - parameter headerFooterViewType: the `UITableViewHeaderFooterView` (`Reusable` & `NibLoadable`-conforming)
     subclass to register
     - seealso: `register(_:,forHeaderFooterViewReuseIdentifier:)`
     */
    final func register<T: UITableViewHeaderFooterView>(headerFooterViewType: T.Type)
        where T: Reusable & NibLoadable {
            self.register(headerFooterViewType.nib, forHeaderFooterViewReuseIdentifier: headerFooterViewType.reuseIdentifier)
    }
    
    /**
     Register a Class-Based `UITableViewHeaderFooterView` subclass (conforming to `Reusable`)
     - parameter headerFooterViewType: the `UITableViewHeaderFooterView` (`Reusable`-confirming) subclass to register
     - seealso: `register(_:,forHeaderFooterViewReuseIdentifier:)`
     */
    final func register<T: UITableViewHeaderFooterView>(headerFooterViewType: T.Type)
        where T: Reusable {
            self.register(headerFooterViewType.self, forHeaderFooterViewReuseIdentifier: headerFooterViewType.reuseIdentifier)
    }
    
    /**
     Returns a reusable `UITableViewHeaderFooterView` object for the class inferred by the return-type
     - parameter viewType: The view class to dequeue
     - returns: A `Reusable`, `UITableViewHeaderFooterView` instance
     - note: The `viewType` parameter can generally be omitted and infered by the return type,
     except when your type is in a variable and cannot be determined at compile time.
     - seealso: `dequeueReusableHeaderFooterView(withIdentifier:)`
     */
    final func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ viewType: T.Type = T.self) -> T?
        where T: Reusable {
            guard let view = self.dequeueReusableHeaderFooterView(withIdentifier: viewType.reuseIdentifier) as? T? else {
                fatalError(
                    "Failed to dequeue a header/footer with identifier \(viewType.reuseIdentifier) "
                        + "matching type \(viewType.self). "
                        + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                        + "and that you registered the header/footer beforehand"
                )
            }
            return view
    }
    
    
    final func dequeueReusableHeaderCell<T: UITableViewCell>(cellType: T.Type = T.self) -> T
        where T: Reusable {
            guard let cell = self.dequeueReusableCell(withIdentifier: T.reuseIdentifier) as? T else {
                fatalError(
                    "Failed to dequeue a cell with identifier \(cellType.reuseIdentifier) matching type \(cellType.self). "
                        + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                        + "and that you registered the cell beforehand"
                )
            }
            return cell
    }
}

final class ContentSizedTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
