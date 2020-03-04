//
//  RootRouter.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs

protocol RootInteractable: Interactable, LoggedInListener, LoggedOutListener {
    var router: RootRouting? { get set }
    var listener: RootListener? { get set }
}

protocol RootViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
    func present(viewController: ViewControllable)
    func dismiss(viewController: ViewControllable)
}

final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable>, RootRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    init(interactor: RootInteractable, viewController: RootViewControllable, loggedInBuilder: LoggedInBuildable, loggedOutBuilder: LoggedOutBuildable) {
        self.loggedInBuilder = loggedInBuilder
        self.loggedOutBuilder = loggedOutBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    override func didLoad() {
        super.didLoad()
    }
    
    func routeToLoggedIn() {
        if let currentChild = currentChild {
            detachChild(currentChild)
            viewController.dismiss(viewController: currentChild.viewControllable)
        }
        
        let loggedIn = loggedInBuilder.build(withListener: interactor, w: viewController.uiviewController.view.frame.width, h: viewController.uiviewController.view.frame.height)
        attachChild(loggedIn)
    }
    
    func routeToLoggedOut() {
        let loggedOut = loggedOutBuilder.build(withListener: interactor, w: viewController.uiviewController.view.frame.width, h: viewController.uiviewController.view.frame.height)
        attachChild(loggedOut)
        viewController.present(viewController: loggedOut.viewControllable)
        
        currentChild = loggedOut
    }
    
    // MARK: - Private
    
    private var currentChild: ViewableRouting?
    
    private let loggedInBuilder: LoggedInBuildable
    
    private let loggedOutBuilder: LoggedOutBuildable
}
