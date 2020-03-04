//
//  MapInteractor.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs
import RxSwift
import CoreLocation
import MapboxDirections

protocol MapRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol MapPresentable: Presentable {
    var listener: MapPresentableListener? { get set }
    func addAnnotations(friends: [User])
    func drawRoute(id: String, route: Route, dest: CLLocationCoordinate2D)
    func resetRoute()
    func showAnnotations()
    func backButtonEntranceAnimation()
    func backButtonExitAnimation()
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol MapListener: class {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func updateFriends(coordinate: CLLocationCoordinate2D)
}

final class MapInteractor: PresentableInteractor<MapPresentable>, MapInteractable, MapPresentableListener {

    weak var router: MapRouting?
    weak var listener: MapListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(presenter: MapPresentable, friendsStream: MutableFriendsStream, menuStateStream: MutableMenuStateStream) {
        self.friendsStream = friendsStream
        self.menuStateStream = menuStateStream
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
        print("attached Map")
        updateFriendAnnotations()
        updateMenuState()
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    // MARK: - MenuListener
    
    func drawRoute(id: String, route: Route, dest: CLLocationCoordinate2D) {
        presenter.drawRoute(id: id, route: route, dest: dest)
    }
    
    // MARK: - MapPresentableListener
    
    func updateLocation(coordinate: CLLocationCoordinate2D) {
        listener?.updateFriends(coordinate: coordinate)
    }
    
    func tappedBackButton() {
        menuStateStream.updateMenuState(with: .collapsed)
    }
    
    func tappedOnFriendAnnotation(friend: User) {
        if let index = friendsStream.getFriends().firstIndex(of: friend) {
            friendsStream.prioritizeFriend(with: IndexPath(row: index, section: 0))
            menuStateStream.updateMenuState(with: .expanded)
        }
    }
    
    // MARK: - Private
    
    private func updateFriendAnnotations() {
        friendsStream.friends
            .take(2)
            .subscribe(onNext: { [weak self] friends in
                self?.presenter.addAnnotations(friends: friends)
            })
            .disposeOnDeactivate(interactor: self)
    }
    
    private func updateMenuState() {
        menuStateStream.state
            .subscribe(onNext: { [weak self] state in
                if state == .expanded {
                    self?.presenter.backButtonEntranceAnimation()
                } else if state == .collapsed {
                    self?.presenter.resetRoute()
                    self?.presenter.showAnnotations()
                    self?.presenter.backButtonExitAnimation()
                }
            })
            .disposeOnDeactivate(interactor: self)
    }
    
    private var friendsStream: MutableFriendsStream
    private var menuStateStream: MutableMenuStateStream
}
