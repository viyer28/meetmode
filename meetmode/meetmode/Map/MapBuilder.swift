//
//  MapBuilder.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs

protocol MapDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var w: CGFloat { get }
    var h: CGFloat { get }
    var mutableFriendsStream: MutableFriendsStream { get }
}

final class MapComponent: Component<MapDependency>, MenuDependency {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
    var w: CGFloat {
        return dependency.w
    }
    
    var h: CGFloat {
        return dependency.h
    }
    
    var mutableMenuStateStream: MutableMenuStateStream {
        return shared { MenuStateStreamImpl() }
    }
    
    var mutableFriendsStream: MutableFriendsStream {
        return dependency.mutableFriendsStream
    }
}

// MARK: - Builder

protocol MapBuildable: Buildable {
    func build(withListener listener: MapListener) -> MapRouting
}

final class MapBuilder: Builder<MapDependency>, MapBuildable {

    override init(dependency: MapDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: MapListener) -> MapRouting {
        let component = MapComponent(dependency: dependency)
        let viewController = MapViewController(w: component.w, h: component.h)
        let interactor = MapInteractor(presenter: viewController, friendsStream: component.mutableFriendsStream, menuStateStream: component.mutableMenuStateStream)
        interactor.listener = listener
        
        let menuBuilder = MenuBuilder(dependency: component)
        return MapRouter(interactor: interactor, viewController: viewController, menuBuilder: menuBuilder)
    }
}
