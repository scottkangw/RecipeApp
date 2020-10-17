//
//  RxTableViewDataSourceProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
import RxSwift
    
extension UITableView: HasDataSource {
    public typealias DataSource = UITableViewDataSource
}

private let tableViewDataSourceNotSet = TableViewDataSourceNotSet()

private final class TableViewDataSourceNotSet
    : NSObject
    , UITableViewDataSource {

    func tableView(_ ingredientTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ ingredientTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        rxAbstractMethod(message: dataSourceNotSet)
    }
}

/// For more information take a look at `DelegateProxyType`.
open class RxTableViewDataSourceProxy
    : DelegateProxy<UITableView, UITableViewDataSource>
    , DelegateProxyType 
    , UITableViewDataSource {

    /// Typed parent object.
    public weak private(set) var ingredientTableView: UITableView?

    /// - parameter tableView: Parent object for delegate proxy.
    public init(ingredientTableView: UITableView) {
        self.ingredientTableView = ingredientTableView
        super.init(parentObject: ingredientTableView, delegateProxy: RxTableViewDataSourceProxy.self)
    }

    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxTableViewDataSourceProxy(ingredientTableView: $0) }
    }

    private weak var _requiredMethodsDataSource: UITableViewDataSource? = tableViewDataSourceNotSet

    // MARK: delegate

    /// Required delegate method implementation.
    public func tableView(_ ingredientTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView(ingredientTableView, numberOfRowsInSection: section)
    }

    /// Required delegate method implementation.
    public func tableView(_ ingredientTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView(ingredientTableView, cellForRowAt: indexPath)
    }

    /// For more information take a look at `DelegateProxyType`.
    open override func setForwardToDelegate(_ forwardToDelegate: UITableViewDataSource?, retainDelegate: Bool) {
        _requiredMethodsDataSource = forwardToDelegate  ?? tableViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }

}

#endif
