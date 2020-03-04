//
//  NavigationInteractor.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs
import RxSwift
import MapboxDirections

protocol NavigationRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol NavigationPresentable: Presentable {
    var listener: NavigationPresentableListener? { get set }
    var friend: User? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol NavigationListener: class {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func drawRoute(id: String, route: Route, dest: CLLocationCoordinate2D)
}

final class NavigationInteractor: PresentableInteractor<NavigationPresentable>, NavigationInteractable, NavigationPresentableListener {
    
    weak var router: NavigationRouting?
    weak var listener: NavigationListener? {
        didSet {
            if let r = self.route {
                if let i = id {
                    if let d = dest {
                        if let l = listener {
                            l.drawRoute(id: i, route: r, dest: d)
                        }
                    }
                }
                self.route = nil
                self.id = nil
                self.dest = nil
            }
        }
    }

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(presenter: NavigationPresentable, friendsStream: MutableFriendsStream, menuStateStream: MutableMenuStateStream) {
        self.friendsStream = friendsStream
        self.menuStateStream = menuStateStream
        super.init(presenter: presenter)
        presenter.listener = self
        presenter.friend = friendsStream.getFriends()[0]
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
        print("attached Navigation")
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
        print("detached Navigation")
    }
    
    // MARK: - NavigationPresentableListener
    
    func drawRoute(id: String, route: Route, dest: CLLocationCoordinate2D) {
        if let l = listener {
            l.drawRoute(id: id, route: route, dest: dest)
        } else {
            self.route = route
            self.id = id
            self.dest = dest
        }
    }
    
    // MARK: - Private
    
    private var route: Route?
    private var id: String?
    private var dest: CLLocationCoordinate2D?
    
    private var friendsStream: MutableFriendsStream
    
    private var menuStateStream: MutableMenuStateStream
}
