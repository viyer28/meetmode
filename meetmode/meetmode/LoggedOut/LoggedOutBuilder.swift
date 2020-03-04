//
//  LoggedOutBuilder.swift
//  meetmode
//
//  Created by Varun Iyer on 3/4/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs

protocol LoggedOutDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var loggedOutViewController: LoggedOutViewControllable { get }
}

final class LoggedOutComponent: Component<LoggedOutDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
    fileprivate var loggedOutViewController: LoggedOutViewControllable {
        return dependency.loggedOutViewController
    }
}

// MARK: - Builder

protocol LoggedOutBuildable: Buildable {
    func build(withListener listener: LoggedOutListener, w: CGFloat, h: CGFloat) -> LoggedOutRouting
}

final class LoggedOutBuilder: Builder<LoggedOutDependency>, LoggedOutBuildable {

    override init(dependency: LoggedOutDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: LoggedOutListener, w: CGFloat, h: CGFloat) -> LoggedOutRouting {
        let component = LoggedOutComponent(dependency: dependency)
        let viewController = LoggedOutViewController(w: w, h: h)
        let interactor = LoggedOutInteractor(presenter: viewController)
        interactor.listener = listener
        
        return LoggedOutRouter(interactor: interactor, viewController: viewController)
    }
}
