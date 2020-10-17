//
//  RxTableViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
import RxSwift

/// For more information take a look at `DelegateProxyType`.
open class RxTableViewDelegateProxy
    : RxScrollViewDelegateProxy
    , UITableViewDelegate {

    /// Typed parent object.
    public weak private(set) var ingredientTableView: UITableView?

    /// - parameter tableView: Parent object for delegate proxy.
    public init(ingredientTableView: UITableView) {
        self.ingredientTableView = ingredientTableView
        super.init(scrollView: ingredientTableView)
    }

}

#endif
