//
//  NavigationRouter.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs

protocol NavigationInteractable: Interactable {
    var router: NavigationRouting? { get set }
    var listener: NavigationListener? { get set }
}

protocol NavigationViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class NavigationRouter: ViewableRouter<NavigationInteractable, NavigationViewControllable>, NavigationRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: NavigationInteractable, viewController: NavigationViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
