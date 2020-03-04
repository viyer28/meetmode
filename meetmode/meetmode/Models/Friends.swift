//
//  Friends.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//
import RxSwift
import UIKit
import CoreLocation
import MapboxDirections

public class User: NSObject {
    var uid: String = ""
    
    var name: String = ""
    
    var image: UIImage!
    
    var coordinate: CLLocationCoordinate2D!
    
    var distance: Double = 0
    
    var address: String = "locating..."
    
    var walkRoute: Route?
    
    var driveRoute: Route?
}

public protocol FriendsStream: class {
    var friends: Observable<[User]> { get }
    func getFriends() -> [User]
}

public protocol MutableFriendsStream: FriendsStream {
    func updateFriends(with friends: [User])
    func prioritizeFriend(with indexPath: IndexPath)
}

public class FriendsStreamImpl: MutableFriendsStream {
    
    public init() {}
    
    public var friends: Observable<[User]> {
        return variable
            .asObservable()
    }
    
    public func updateFriends(with friends: [User]) {
        allFriends = friends
        variable.value = friends
    }
    
    public func prioritizeFriend(with indexPath: IndexPath) {
        if allFriends.count > 0 {
            let friend = allFriends.remove(at: indexPath.row)
            allFriends.insert(friend, at: 0)
            variable.value = allFriends
        }
    }
    
    public func getFriends() -> [User] {
        return variable.value
    }
    
    // MARK: - Private
    
    private let variable = Variable<[User]>([])
    private var allFriends: [User] = []
}
