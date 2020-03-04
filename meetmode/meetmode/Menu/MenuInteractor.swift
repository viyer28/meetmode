//
//  MenuInteractor.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs
import RxSwift
import MapboxDirections

protocol MenuRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToHome()
    func routeToNavigation()
}

protocol MenuPresentable: Presentable {
    var listener: MenuPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
    func transitionBackToHome()
    func transitionToNavigation()
}

protocol MenuListener: class {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func drawRoute(id: String, route: Route, dest: CLLocationCoordinate2D)
}

final class MenuInteractor: PresentableInteractor<MenuPresentable>, MenuInteractable, MenuPresentableListener {
    
    weak var router: MenuRouting?
    weak var listener: MenuListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(presenter: MenuPresentable, mutableMenuStateStream: MutableMenuStateStream) {
        self.mutableMenuStateStream = mutableMenuStateStream
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
        print("attached Menu")
        updateState()
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    // MARK: - HomeListener
    
    func navigate() {
        mutableMenuStateStream.updateMenuState(with: .expanded)
    }
    
    // MARK: - NavigationListener
    
    func drawRoute(id: String, route: Route, dest: CLLocationCoordinate2D) {
        listener?.drawRoute(id: id, route: route, dest: dest)
    }
    
    // MARK: - MenuPresentableListener
    
    func updateMenuState(state: State) {
        mutableMenuStateStream.updateMenuState(with: state)
    }
    
    // MARK: - Private
    
    private var mutableMenuStateStream: MutableMenuStateStream
    
    func updateState() {
        mutableMenuStateStream.state
            .subscribe(onNext: { [weak self] state in
                if state == .collapsed {
                    self?.router?.routeToHome()
                    self?.presenter.transitionBackToHome()
                } else if state == .expanded {
                    self?.router?.routeToNavigation()
                    self?.presenter.transitionToNavigation()
                }
            })
            .disposeOnDeactivate(interactor: self)
    }
}
