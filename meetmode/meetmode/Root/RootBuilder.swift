//
//  RootBuilder.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs

protocol RootDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class RootComponent: Component<RootDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
    
    let rootViewController: RootViewController
    
    init(dependency: RootDependency, rootViewController: RootViewController) {
        self.rootViewController = rootViewController
        super.init(dependency: dependency)
    }

    var mutableFriendsStream: MutableFriendsStream {
        return shared { FriendsStreamImpl() }
    }
}

// MARK: - Builder

protocol RootBuildable: Buildable {
    func build(loggedIn: Bool) -> LaunchRouting
}

final class RootBuilder: Builder<RootDependency>, RootBuildable {

    override init(dependency: RootDependency) {
        super.init(dependency: dependency)
    }

    func build(loggedIn: Bool) -> LaunchRouting {
        let viewController = RootViewController()
        let component = RootComponent(dependency: dependency, rootViewController: viewController)
        let interactor = RootInteractor(presenter: viewController, loggedIn: loggedIn)
        
        let loggedInBuilder = LoggedInBuilder(dependency: component)
        let loggedOutBuilder = LoggedOutBuilder(dependency: component)
        return RootRouter(interactor: interactor, viewController: viewController, loggedInBuilder: loggedInBuilder, loggedOutBuilder: loggedOutBuilder)
    }
}
