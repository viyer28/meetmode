//
//  LoggedInInteractor.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs
import RxSwift
import CoreLocation
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation
import SwiftLocation

protocol LoggedInRouting: Routing {
    func cleanupViews()
    func displayMap()
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol LoggedInListener: class {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class LoggedInInteractor: Interactor, LoggedInInteractable {

    weak var router: LoggedInRouting?
    weak var listener: LoggedInListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(friendsStream: MutableFriendsStream) {
        self.friendsStream = friendsStream
        super.init()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
        print("attached LoggedIn")
        router?.displayMap()
    }

    override func willResignActive() {
        super.willResignActive()

        router?.cleanupViews()
        // TODO: Pause any business logic.
    }
    
    // MARK: - MapListener
    
    func updateFriends(coordinate: CLLocationCoordinate2D) {
        var friends: [User] = []
        
        let friend1 = User()
        friend1.name = "becca"
        friend1.uid = "1"
        friend1.image = UIImage(named: friend1.name)
        friend1.coordinate = generateRandomCoordinates(currentLoc: coordinate, min: 200, max: 201)
        friends.append(friend1)
        
        let friend2 = User()
        friend2.name = "gianna"
        friend2.uid = "2"
        friend2.image = UIImage(named: friend2.name)
        friend2.coordinate = generateRandomCoordinates(currentLoc: coordinate, min: 300, max: 301)
        friends.append(friend2)
        
        let friend3 = User()
        friend3.name = "jimmy"
        friend3.uid = "3"
        friend3.image = UIImage(named: friend3.name)
        friend3.coordinate = generateRandomCoordinates(currentLoc: coordinate, min: 400, max: 401)
        friends.append(friend3)

        let friend4 = User()
        friend4.name = "malik"
        friend4.uid = "4"
        friend4.image = UIImage(named: friend4.name)
        friend4.coordinate = generateRandomCoordinates(currentLoc: coordinate, min: 500, max: 501)
        friends.append(friend4)
        
        let friend5 = User()
        friend5.name = "nina"
        friend5.uid = "5"
        friend5.image = UIImage(named: friend5.name)
        friend5.coordinate = generateRandomCoordinates(currentLoc: coordinate, min: 600, max: 601)
        friends.append(friend5)
        
        let friend6 = User()
        friend6.name = "shay"
        friend6.uid = "6"
        friend6.image = UIImage(named: friend6.name)
        friend6.coordinate = generateRandomCoordinates(currentLoc: coordinate, min: 700, max: 701)
        friends.append(friend6)
        
        let friend7 = User()
        friend7.name = "shelby"
        friend7.uid = "7"
        friend7.image = UIImage(named: friend7.name)
        friend7.coordinate = generateRandomCoordinates(currentLoc: coordinate, min: 800, max: 801)
        friends.append(friend7)
        
        let friend8 = User()
        friend8.name = "varun"
        friend8.uid = "8"
        friend8.image = UIImage(named: friend8.name)
        friend8.coordinate = generateRandomCoordinates(currentLoc: coordinate, min: 900, max: 901)
        friends.append(friend8)
        
        for friend in friends {
            friend.distance = friend.coordinate.distance(from: coordinate)*3.28084
            
            let options = GeocoderRequest.Options()

            LocationManager.shared.locateFromCoordinates(friend.coordinate, service: .apple(options)) { result in
              switch result {
                case .failure(let error):
                    debugPrint("An error has occurred: \(error)")
                case .success(let places):
                    if places.count > 0 {
                        if let address = places[0].formattedAddress {
                            let formattedAddress = address.replacingOccurrences(of: "\n", with: ", ")
                            friend.address = formattedAddress
                            print("\(friend.name) at \(friend.address)")
                        }
                    }
                }
            }
            
            let origin = Waypoint(coordinate: coordinate, name: "you")
            let destination = Waypoint(coordinate: friend.coordinate, name: friend.name)
            
            let walkingOptions = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .walking)
            
            Directions.shared.calculate(walkingOptions) { (waypoints, routes, error) in
                if let route = routes?.first {
                    friend.walkRoute = route
                    print("\(friend.name) got walk")
                }
            }
            
            let drivingOptions = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobile)
            Directions.shared.calculate(drivingOptions) { (waypoints, routes, error) in
                if let route = routes?.first {
                    friend.driveRoute = route
                    print("\(friend.name) got drive")
                }
            }
        }
        
        friendsStream.updateFriends(with: friends)
    }
    
    // MARK: - Private
    
    func generateRandomCoordinates(currentLoc: CLLocationCoordinate2D, min: UInt32, max: UInt32)-> CLLocationCoordinate2D {
        let currentLong = currentLoc.longitude
        let currentLat = currentLoc.latitude

        // 1 KiloMeter = 0.00900900900901° So, 1 Meter = 0.00900900900901 / 1000
        let meterCord = 0.00900900900901 / 1000

        // Generate random meters between the maximum and minimum Meters
        let randomMeters = UInt(arc4random_uniform(max) + min)

        // then Generating Random numbers for different Methods
        let randomPM = arc4random_uniform(6)

        //Then we convert the distance in meters to coordinates by Multiplying the number of meters with 1 Meter Coordinate
        let metersCordN = meterCord * Double(randomMeters)

        //here we generate the last Coordinates
        if randomPM == 0 {
            return CLLocationCoordinate2D(latitude: currentLat + metersCordN, longitude: currentLong + metersCordN)
        } else if randomPM == 1 {
            return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong - metersCordN)
        } else if randomPM == 2 {
            return CLLocationCoordinate2D(latitude: currentLat + metersCordN, longitude: currentLong - metersCordN)
        } else if randomPM == 3 {
            return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong + metersCordN)
        } else if randomPM == 4 {
            return CLLocationCoordinate2D(latitude: currentLat, longitude: currentLong - metersCordN)
        } else {
            return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong)
        }

    }
    
    private var friendsStream: MutableFriendsStream
    private let geocoder = CLGeocoder()
}
