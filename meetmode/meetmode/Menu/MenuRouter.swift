//
//  MenuRouter.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs

protocol MenuInteractable: Interactable, HomeListener, NavigationListener {
    var router: MenuRouting? { get set }
    var listener: MenuListener? { get set }
}

protocol MenuViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
    func show(subView: ViewControllable)
    func hide(subView: ViewControllable)
}

final class MenuRouter: ViewableRouter<MenuInteractable, MenuViewControllable>, MenuRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    init(interactor: MenuInteractable, viewController: MenuViewControllable, homeBuilder: HomeBuildable, navigationBuilder: NavigationBuildable) {
        self.homeBuilder = homeBuilder
        self.navigationBuilder = navigationBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: - Home
    
    private var homeBuilder: HomeBuildable
    
    func routeToHome() {
        if let currentChild = currentChild {
            viewController.hide(subView: currentChild.viewControllable)
            detachChild(currentChild)
        }
        
        let home = homeBuilder.build(withListener: interactor)
        self.currentChild = home
        attachChild(home)
        viewController.show(subView: home.viewControllable)
    }
    
    // MARK: - Navigation
    
    private var navigationBuilder: NavigationBuildable
    
    func routeToNavigation() {
        if let currentChild = currentChild {
            viewController.hide(subView: currentChild.viewControllable)
            detachChild(currentChild)
        }
        
        let navigation = navigationBuilder.build(withListener: interactor)
        self.currentChild = navigation
        attachChild(navigation)
        viewController.show(subView: navigation.viewControllable)
    }
    
    private var currentChild: ViewableRouting?
}
