//
//  LoggedInBuilder.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs

protocol LoggedInDependency: Dependency {
    // TODO: Make sure to convert the variable into lower-camelcase.
    var loggedInViewController: LoggedInViewControllable { get }
    var mutableFriendsStream: MutableFriendsStream { get }
    // TODO: Declare the set of dependencies required by this RIB, but won't be
    // created by this RIB.
}

final class LoggedInComponent: Component<LoggedInDependency>, MapDependency {

    // TODO: Make sure to convert the variable into lower-camelcase.
    fileprivate var loggedInViewController: LoggedInViewControllable {
        return dependency.loggedInViewController
    }
    
    let w: CGFloat
    let h: CGFloat
    
    init(dependency: LoggedInDependency, w: CGFloat, h: CGFloat) {
        self.w = w
        self.h = h
        super.init(dependency: dependency)
    }
    
    var mutableFriendsStream: MutableFriendsStream {
        return dependency.mutableFriendsStream
    }

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol LoggedInBuildable: Buildable {
    func build(withListener listener: LoggedInListener, w: CGFloat, h: CGFloat) -> LoggedInRouting
}

final class LoggedInBuilder: Builder<LoggedInDependency>, LoggedInBuildable {

    override init(dependency: LoggedInDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: LoggedInListener, w: CGFloat, h: CGFloat) -> LoggedInRouting {
        let component = LoggedInComponent(dependency: dependency, w: w, h: h)
        let interactor = LoggedInInteractor(friendsStream: component.mutableFriendsStream)
        interactor.listener = listener
        
        let mapBuilder = MapBuilder(dependency: component)
        return LoggedInRouter(interactor: interactor, viewController: component.loggedInViewController, mapBuilder: mapBuilder)
    }
}
