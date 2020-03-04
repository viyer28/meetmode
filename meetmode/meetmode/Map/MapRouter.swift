//
//  MapRouter.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs

protocol MapInteractable: Interactable, MenuListener {
    var router: MapRouting? { get set }
    var listener: MapListener? { get set }
}

protocol MapViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
    func show(view: ViewControllable)
    func hide(view: ViewControllable)
}

final class MapRouter: ViewableRouter<MapInteractable, MapViewControllable>, MapRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    init(interactor: MapInteractable, viewController: MapViewControllable, menuBuilder: MenuBuildable) {
        self.menuBuilder = menuBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    override func didLoad() {
        super.didLoad()
        
        attachMenu()
    }
    
    // MARK: - Menu
    
    private var menuBuilder: MenuBuildable
    
    private func attachMenu() {
        let menu = menuBuilder.build(withListener: interactor)
        attachChild(menu)
        viewController.show(view: menu.viewControllable)
    }
}
