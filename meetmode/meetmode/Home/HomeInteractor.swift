//
//  HomeInteractor.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs
import RxSwift
import RxDataSources
import UIKit

protocol HomeRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol HomePresentable: Presentable {
    var listener: HomePresentableListener? { get set }
    var homeSections: Variable<[HomeCollectionViewModel]>? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol HomeListener: class {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func navigate()
}

final class HomeInteractor: PresentableInteractor<HomePresentable>, HomeInteractable, HomePresentableListener {

    weak var router: HomeRouting?
    weak var listener: HomeListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(presenter: HomePresentable, friendsStream: MutableFriendsStream) {
        self.friendsStream = friendsStream
        super.init(presenter: presenter)
        presenter.listener = self
        presenter.homeSections = Variable([HomeCollectionViewModel(header: "", items: [])])
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
        print("attached Home")
        updateFriends()
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
        print("detached Home")
    }
    
    // MARK: - HomePresentableListener
    
    func tappedHomeItem(indexPath: IndexPath) {
        friendsStream.prioritizeFriend(with: indexPath)
        listener?.navigate()
    }
    
    // MARK: - Private
    
    private var friendsStream: MutableFriendsStream
    
    private func updateFriends() {
        friendsStream.friends
            .map {
                return $0.map{
                    return HomeCollectionData(friend: $0)
                }
            }
            .subscribe(onNext: { (data: [HomeCollectionData]) in
                self.presenter.homeSections!.value[0].items = data
            })
            .disposeOnDeactivate(interactor: self)
    }
}

struct HomeCollectionViewModel {
    var header: String
    var items: [HomeCollectionData]
}

extension HomeCollectionViewModel: AnimatableSectionModelType {
    typealias Item = HomeCollectionData
    typealias Identity = String
    
    var identity: String {
        return header
    }
    
    init(original: HomeCollectionViewModel, items: [HomeCollectionData]) {
        self = original
        self.items = items
    }
}

struct HomeCollectionData {
    var friend: User
}

extension HomeCollectionData: IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: String {
        return friend.uid
    }
    
    static func ==(lhs: HomeCollectionData, rhs: HomeCollectionData) -> Bool {
        return lhs.identity == rhs.identity && lhs.friend == rhs.friend
    }
}
