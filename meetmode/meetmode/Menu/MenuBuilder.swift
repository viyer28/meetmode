//
//  MenuBuilder.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs

protocol MenuDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var w: CGFloat { get }
    var h: CGFloat { get }
    var mutableMenuStateStream: MutableMenuStateStream { get }
    var mutableFriendsStream: MutableFriendsStream { get }
}

final class MenuComponent: Component<MenuDependency>, HomeDependency, NavigationDependency {
    var w: CGFloat {
       return dependency.w
    }

    var h: CGFloat {
       return dependency.h
    }

    var mutableMenuStateStream: MutableMenuStateStream {
       return dependency.mutableMenuStateStream
    }
    
    var mutableFriendsStream: MutableFriendsStream {
        return dependency.mutableFriendsStream
    }
    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol MenuBuildable: Buildable {
    func build(withListener listener: MenuListener) -> MenuRouting
}

final class MenuBuilder: Builder<MenuDependency>, MenuBuildable {

    override init(dependency: MenuDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: MenuListener) -> MenuRouting {
        let component = MenuComponent(dependency: dependency)
        let viewController = MenuViewController(w: component.w, h: component.h)
        let interactor = MenuInteractor(presenter: viewController, mutableMenuStateStream: component.mutableMenuStateStream)
        interactor.listener = listener
        
        let homeBuilder = HomeBuilder(dependency: component)
        let navigationBuilder = NavigationBuilder(dependency: component)
        return MenuRouter(interactor: interactor, viewController: viewController, homeBuilder: homeBuilder, navigationBuilder: navigationBuilder)
    }
}
