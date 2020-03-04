//
//  LoggedInRouter.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs

protocol LoggedInInteractable: Interactable, MapListener {
    var router: LoggedInRouting? { get set }
    var listener: LoggedInListener? { get set }
}

protocol LoggedInViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy. Since
    // this RIB does not own its own view, this protocol is conformed to by one of this
    // RIB's ancestor RIBs' view.
    func present(viewController: ViewControllable)
    func dismiss(viewController: ViewControllable)
}

final class LoggedInRouter: Router<LoggedInInteractable>, LoggedInRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    init(interactor: LoggedInInteractable, viewController: LoggedInViewControllable, mapBuilder: MapBuildable) {
        self.viewController = viewController
        self.mapBuilder = mapBuilder
        super.init(interactor: interactor)
        interactor.router = self
    }

    func cleanupViews() {
        // TODO: Since this router does not own its view, it needs to cleanup the views
        // it may have added to the view hierarchy, when its interactor is deactivated.
    }
    
    // MARK: - LoggedInRouting
    
    func displayMap() {
        let map = mapBuilder.build(withListener: interactor)
        attachChild(map)
        viewController.present(viewController: map.viewControllable)
    }

    // MARK: - Private

    private let viewController: LoggedInViewControllable
    private let mapBuilder: MapBuildable
}
