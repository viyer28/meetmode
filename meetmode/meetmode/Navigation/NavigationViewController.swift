//
//  NavigationViewController.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs
import RxSwift
import UIKit
import EFCountingLabel
import SnapKit
import RxGesture
import MessageUI
import UberRides
import CoreLocation
import LyftSDK
import MapboxDirections


protocol NavigationPresentableListener: class {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func drawRoute(id: String, route: Route, dest: CLLocationCoordinate2D)
}

final class NavigationViewController: UIViewController, NavigationPresentable, NavigationViewControllable {

    weak var listener: NavigationPresentableListener?
    var friend: User? {
        didSet {
            if let f = self.friend {
                _setupNavigationView(friend: f)
                for view in view.subviews {
                   view.alpha = 0
                }
                if let walkRoute = f.walkRoute {
                    if let driveRoute = f.driveRoute {
                        navigationEntranceAnimation(distance: f.distance, walkTime: walkRoute.expectedTravelTime, driveTime: driveRoute.expectedTravelTime)
                    } else {
                        navigationEntranceAnimation(distance: f.distance, walkTime: walkRoute.expectedTravelTime, driveTime: 0)
                    }
                } else {
                    if let driveRoute = f.driveRoute {
                        navigationEntranceAnimation(distance: f.distance, walkTime: 0, driveTime: driveRoute.expectedTravelTime)
                    } else {
                        navigationEntranceAnimation(distance: f.distance, walkTime: 0, driveTime: 0)
                    }
                }
            }
        }
    }
    
    init(w: CGFloat, h: CGFloat) {
        self.w = w
        self.h = h
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Method is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 4.5*h/10)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if animator != nil {
            animator.stopAnimation(true)
        }
    }
    
    // MARK: - Private
    
    private func _setupNavigationView(friend: User) {
        distanceLabel = EFCountingLabel()
        distanceLabel.font = UIFont.systemFont(ofSize: 28, weight: UIFont.Weight.semibold)
        distanceLabel.textAlignment = .center
        distanceLabel.textColor = UIColor(red: 213/255, green: 168/255, blue: 94/255, alpha: 1.0)
        distanceLabel.setUpdateBlock { [weak self] value, label in
            if value < 528 {
                label.text = "\(Int(value)) ft away"
            } else {
                label.text = "\(Double(round(10*(friend.distance/5280))/10)) mi away"
            }
            self?.distanceLabel.sizeToFit()
        }
        distanceLabel.text = "0 ft away"
        distanceLabel.sizeToFit()
        
        view.addSubview(distanceLabel)
        distanceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.snp.left).offset(15)
            make.top.equalTo(self.view.snp.top).offset(20)
        }
        
        addressLabel = UILabel()
        addressLabel.text = friend.address
        addressLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        addressLabel.textColor = .white
        addressLabel.textAlignment = .left
        addressLabel.lineBreakMode = .byTruncatingTail
        
        view.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.snp.left).offset(15)
            make.right.equalTo(self.view.snp.right).offset(-15)
            make.top.equalTo(distanceLabel.snp.bottom).offset(10)
        }
        
        walkingBackgroundView = UIView()
        walkingBackgroundView.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1.0)
        walkingBackgroundView.layer.cornerRadius = 20
        
        view.addSubview(walkingBackgroundView)
        walkingBackgroundView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.snp.left).offset(15)
            make.right.equalTo(self.view.snp.centerX).offset(-7.5)
            make.height.equalTo(125)
            make.centerY.equalTo(self.view.snp.centerY)
        }
        
        walkingBackgroundView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                if self!.mode != "walking" {
                    self?.generator.impactOccurred()
                    self?.walkingSelectAnimation()
                    self?.walkingBackgroundView.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1.0)
                    self?.walkingTimeLabel.textColor = UIColor(red: 213/255, green: 168/255, blue: 94/255, alpha: 1.0)
                    self?.walkingLabel.textColor = UIColor(red: 213/255, green: 168/255, blue: 94/255, alpha: 1.0)
                    self?.drivingBackgroundView.backgroundColor = .darkGray
                    self?.drivingTimeLabel.textColor = .lightGray
                    self?.drivingLabel.textColor = .lightGray
                    if let route = friend.walkRoute {
                        self?.listener?.drawRoute(id: friend.uid + "w", route: route, dest: friend.coordinate)
                    }
                    self?.mode = "walking"
                }
            })
            .disposed(by: disposeBag)
        
        drivingBackgroundView = UIView()
        drivingBackgroundView.backgroundColor = .darkGray
        drivingBackgroundView.layer.cornerRadius = 20
        
        drivingBackgroundView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                if self!.mode != "driving" {
                    self?.generator.impactOccurred()
                    self?.drivingSelectAnimation()
                    self?.drivingBackgroundView.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1.0)
                    self?.drivingTimeLabel.textColor = UIColor(red: 213/255, green: 168/255, blue: 94/255, alpha: 1.0)
                    self?.drivingLabel.textColor = UIColor(red: 213/255, green: 168/255, blue: 94/255, alpha: 1.0)
                    self?.walkingBackgroundView.backgroundColor = .darkGray
                    self?.walkingTimeLabel.textColor = .lightGray
                    self?.walkingLabel.textColor = .lightGray
                    if let route = friend.driveRoute {
                        self?.listener?.drawRoute(id: friend.uid + "d", route: route, dest: friend.coordinate)
                    }
                    self?.mode = "driving"
                }
            })
            .disposed(by: disposeBag)
        
        view.addSubview(drivingBackgroundView)
        drivingBackgroundView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.snp.centerX).offset(7.5)
            make.right.equalTo(self.view.snp.right).offset(-15)
            make.height.equalTo(125)
            make.centerY.equalTo(self.view.snp.centerY)
        }
        
        walkingLabel = UILabel()
        walkingLabel.text = "WALK"
        walkingLabel.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.thin)
        walkingLabel.textColor = UIColor(red: 213/255, green: 168/255, blue: 94/255, alpha: 1.0)
        walkingLabel.textAlignment = .center
        walkingLabel.sizeToFit()
        
        view.addSubview(walkingLabel)
        walkingLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(walkingBackgroundView.snp.centerX)
            make.bottom.equalTo(walkingBackgroundView.snp.bottom).offset(-20)
        }
        
        drivingLabel = UILabel()
        drivingLabel.text = "DRIVE"
        drivingLabel.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.thin)
        drivingLabel.textColor = .lightGray
        drivingLabel.textAlignment = .center
        drivingLabel.sizeToFit()
        
        view.addSubview(drivingLabel)
        drivingLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(drivingBackgroundView.snp.centerX)
            make.bottom.equalTo(drivingBackgroundView.snp.bottom).offset(-20)
        }
        
        walkingTimeLabel = EFCountingLabel()
        walkingTimeLabel.font = UIFont.systemFont(ofSize: 28, weight: UIFont.Weight.semibold)
        walkingTimeLabel.textAlignment = .center
        walkingTimeLabel.textColor = UIColor(red: 213/255, green: 168/255, blue: 94/255, alpha: 1.0)
        walkingTimeLabel.setUpdateBlock { [weak self] value, label in
            let hours = Int(value) / 3600
            let minutes = Int(value) / 60 % 60
            let seconds = Int(value) % 60
            if hours > 0 {
                self?.walkingTimeLabel.text = "\(hours)h\(minutes)m"
            } else if minutes > 0 {
                self?.walkingTimeLabel.text = "\(minutes) min"
            } else {
                self?.walkingTimeLabel.text = "\(seconds) sec"
            }
            self?.walkingTimeLabel.sizeToFit()
        }
        walkingTimeLabel.text = "0 sec"
        walkingTimeLabel.sizeToFit()
        
        view.addSubview(walkingTimeLabel)
        walkingTimeLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(walkingBackgroundView.snp.centerX)
            make.centerY.equalTo(walkingBackgroundView.snp.centerY).offset(-15)
        }
        
        drivingTimeLabel = EFCountingLabel()
        drivingTimeLabel.font = UIFont.systemFont(ofSize: 28, weight: UIFont.Weight.semibold)
        drivingTimeLabel.textAlignment = .center
        drivingTimeLabel.textColor = .lightGray
        drivingTimeLabel.setUpdateBlock { [weak self] value, label in
            let hours = Int(value) / 3600
            let minutes = Int(value) / 60 % 60
            let seconds = Int(value) % 60
            if hours > 0 {
                self?.drivingTimeLabel.text = "\(hours)h\(minutes)m"
            } else if minutes > 0 {
                self?.drivingTimeLabel.text = "\(minutes) min"
            } else {
                self?.drivingTimeLabel.text = "\(seconds) sec"
            }
            self?.drivingTimeLabel.sizeToFit()
        }
        drivingTimeLabel.text = "0 sec"
        drivingTimeLabel.sizeToFit()
        
        view.addSubview(drivingTimeLabel)
        drivingTimeLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(drivingBackgroundView.snp.centerX)
            make.centerY.equalTo(drivingBackgroundView.snp.centerY).offset(-15)
        }
        
        directionsBackgroundView = UIView()
        directionsBackgroundView.backgroundColor = UIColor(red: 213/255, green: 168/255, blue: 94/255, alpha: 1.0)
        directionsBackgroundView.layer.cornerRadius = 25
        
        view.addSubview(directionsBackgroundView)
        directionsBackgroundView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(w-30)
            make.height.equalTo(50)
            make.bottom.equalTo(self.view.snp.bottom).offset(-30)
        }
        
        directionsBackgroundView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.generator.impactOccurred()
                self?.directionsSelectAnimation()
                let alertController = UIAlertController(title: "", message: "\(friend.address)", preferredStyle: .actionSheet)
                let uberAction = UIAlertAction(title: "Uber", style: .default) { (_) -> Void in
                    
                    let builder = RideParametersBuilder()
                    let dropoffLocation = CLLocation(latitude: friend.coordinate.latitude, longitude: friend.coordinate.longitude)
                    builder.dropoffLocation = dropoffLocation
                    builder.dropoffNickname = friend.name
                    let rideParameters = builder.build()
                    
                    let uberDeepLink = RequestDeeplink(rideParameters: rideParameters, fallbackType: .mobileWeb)
                    uberDeepLink.execute()
                    
                    alertController.dismiss(animated: true)
                }
                alertController.addAction(uberAction)
                let lyftAction = UIAlertAction(title: "Lyft", style: .default) { (_) -> Void in
                    LyftDeepLink.requestRide(kind: .Standard, to: friend.coordinate)
                    alertController.dismiss(animated: true)
                }
                alertController.addAction(lyftAction)
                let appleAction = UIAlertAction(title: "Maps", style: .default) { [weak self] (_) -> Void in
                    let formattedAddress = friend.address.replacingOccurrences(of: " ", with: "+")
                    if let url = URL(string:"http://maps.apple.com/?daddr=\(formattedAddress)&dirflg=\(String(self!.mode.first!))") {
                        UIApplication.shared.open(url)
                    } else if let llurl = URL(string:"http://maps.apple.com/?daddr=\(friend.coordinate.latitude),\(friend.coordinate.longitude)&dirflg=\(String(self!.mode.first!))") {
                        UIApplication.shared.open(llurl)
                    }
                    alertController.dismiss(animated: true)
                }
                alertController.addAction(appleAction)
                let googleAction = UIAlertAction(title: "Google Maps", style: .default) { [weak self] (_) -> Void in
                    if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                        let formattedAddress = friend.address.replacingOccurrences(of: " ", with: "+")
                        if let url = URL(string:
                            "comgooglemaps://?daddr=\(formattedAddress)&directionsmode=\(self!.mode)") {
                            UIApplication.shared.open(url)
                        } else if let llurl = URL(string:
                            "comgooglemaps://?daddr=\(friend.coordinate.latitude),\(friend.coordinate.longitude)&directionsmode=\(self!.mode)") {
                            UIApplication.shared.open(llurl)
                        }
                    }
                    alertController.dismiss(animated: true)
                }
                alertController.addAction(googleAction)
                let wazeAction = UIAlertAction(title: "Waze", style: .default) { (_) -> Void in
                    if (UIApplication.shared.canOpenURL(URL(string:"waze://")!)) {
                        let formattedAddress = friend.address.replacingOccurrences(of: " ", with: "+")
                        if let url = URL(string: "waze://?q=\(formattedAddress)&navigate=yes") {
                            UIApplication.shared.open(url)
                        } else if let llurl = URL(string:
                            "waze://?ll=\(friend.coordinate.latitude),\(friend.coordinate.longitude)&navigate=yes") {
                            UIApplication.shared.open(llurl)
                        }
                    }
                    alertController.dismiss(animated: true)
                }
                alertController.addAction(wazeAction)
                self?.present(alertController, animated: true)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
                    alertController.dismiss(animated: true)
                }
                alertController.addAction(cancelAction)
            })
            .disposed(by: disposeBag)
        
        directionsLabel = UILabel()
        directionsLabel.text = "get directions"
        directionsLabel.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.bold)
        directionsLabel.textColor = UIColor(red: 15/255, green: 16/255, blue: 18/255, alpha: 1.0)
        directionsLabel.textAlignment = .center
        directionsLabel.sizeToFit()
        
        view.addSubview(directionsLabel)
        directionsLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(directionsBackgroundView.snp.centerX)
            make.centerY.equalTo(directionsBackgroundView.snp.centerY)
        }
        
        shareImageView = UIImageView(image: UIImage(named: "shareAddr")!)
        shareImageView.contentMode = .scaleAspectFit
        
        view.addSubview(shareImageView)
        shareImageView.snp.makeConstraints { (make) in
            make.right.equalTo(self.view.snp.right).offset(-15)
            make.centerY.equalTo(distanceLabel.snp.centerY).offset(-2.5)
            make.height.equalTo(30)
            make.width.equalTo(30*86.67/110.2)
        }
        
        shareImageView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.generator.impactOccurred()
                self?.shareSelectAnimation()
                let alertController = UIAlertController(title: "", message: "\(friend.address)", preferredStyle: .actionSheet)
                let copyAddrAction = UIAlertAction(title: "Copy Address", style: .default) { (_) -> Void in
                    UIPasteboard.general.string = "\(friend.address)"
                    alertController.dismiss(animated: true)
                }
                alertController.addAction(copyAddrAction)
                let copyGPSAction = UIAlertAction(title: "Copy GPS Coordinates", style: .default) { (_) -> Void in
                    UIPasteboard.general.string = "lat: \(friend.coordinate.latitude), lon: \(friend.coordinate.longitude)"
                    alertController.dismiss(animated: true)
                }
                alertController.addAction(copyGPSAction)
                let appleAction = UIAlertAction(title: "Open in Apple Maps", style: .default) { (_) -> Void in
                    let formattedAddress = friend.address.replacingOccurrences(of: " ", with: "+")
                    if let url = URL(string:"http://maps.apple.com/?address=\(formattedAddress)") {
                        UIApplication.shared.open(url)
                    } else  if let llurl = URL(string:"http://maps.apple.com/?address=\(friend.coordinate.latitude),\(friend.coordinate.longitude)") {
                        UIApplication.shared.open(llurl)
                    }
                    alertController.dismiss(animated: true)
                }
                alertController.addAction(appleAction)
                let googleAction = UIAlertAction(title: "Open in Google Maps", style: .default) { [weak self] (_) -> Void in
                    if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                        print("can open google maps")
                        let formattedAddress = friend.address.replacingOccurrences(of: " ", with: "+")
                        if let url = URL(string:
                            "comgooglemaps://?daddr=\(formattedAddress)&directionsmode=\(self!.mode)") {
                            UIApplication.shared.open(url)
                        } else if let llurl = URL(string:
                            "comgooglemaps://?daddr=\(friend.coordinate.latitude),\(friend.coordinate.longitude)&directionsmode=\(self!.mode)") {
                            UIApplication.shared.open(llurl)
                        }
                    }
                    alertController.dismiss(animated: true)
                }
                
                alertController.addAction(googleAction)
                let textAction = UIAlertAction(title: "Send by Text", style: .default) { [weak self] (_) -> Void in
                    let composeVC = MFMessageComposeViewController()
                    composeVC.messageComposeDelegate = self
                    composeVC.body = friend.address
                     
                    // Present the view controller modally.
                    self?.present(composeVC, animated: true, completion: nil)
                    alertController.dismiss(animated: true)
                }
                alertController.addAction(textAction)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
                    alertController.dismiss(animated: true)
                }
                alertController.addAction(cancelAction)
                self?.present(alertController, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Animation
    
    private func navigationEntranceAnimation(distance: Double, walkTime: Double, driveTime: Double) {
        animator = UIViewPropertyAnimator(duration: 0.35, curve: .easeIn) {
            for view in self.view.subviews {
                if view == self.addressLabel {
                    view.alpha = 0.9
                } else {
                    view.alpha = 1
                }
            }
        }
        
        animator.startAnimation()
        distanceLabel.countFrom(0, to: CGFloat(distance), withDuration: 0.75)
        if walkTime == 0 {
            walkingTimeLabel.text = "n/a"
        } else {
            walkingTimeLabel.countFrom(0, to: CGFloat(walkTime), withDuration: 0.75)
            walkingSelectAnimation()
            listener?.drawRoute(id: friend!.uid + "w", route: friend!.walkRoute!, dest: friend!.coordinate)
        }
        if driveTime == 0 {
            drivingTimeLabel.text = "n/a"
        } else {
            drivingTimeLabel.countFrom(0, to: CGFloat(driveTime), withDuration: 0.75)
        }
    }
    
    private func walkingSelectAnimation() {
        walkingBackgroundView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        walkingLabel.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        walkingTimeLabel.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        UIView.animate(withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.3,
            initialSpringVelocity: 6.0,
            options: .allowUserInteraction,
            animations: { [weak self] in
                self?.walkingLabel.transform = .identity
                self?.walkingTimeLabel.transform = .identity
                self?.walkingBackgroundView.transform = .identity
            },
            completion: nil)
    }
    
    private func drivingSelectAnimation() {
        drivingBackgroundView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        drivingLabel.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        drivingTimeLabel.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        UIView.animate(withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.3,
            initialSpringVelocity: 6.0,
            options: .allowUserInteraction,
            animations: { [weak self] in
                self?.drivingLabel.transform = .identity
                self?.drivingTimeLabel.transform = .identity
                self?.drivingBackgroundView.transform = .identity
            },
            completion: nil)
    }
    
    private func shareSelectAnimation() {
        shareImageView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        UIView.animate(withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.3,
            initialSpringVelocity: 6.0,
            options: .allowUserInteraction,
            animations: { [weak self] in
                self?.shareImageView.transform = .identity
            },
            completion: nil)
    }
    
    private func directionsSelectAnimation() {
        directionsBackgroundView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        directionsLabel.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        UIView.animate(withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.3,
            initialSpringVelocity: 6.0,
            options: .allowUserInteraction,
            animations: { [weak self] in
                self?.directionsLabel.transform = .identity
                self?.directionsBackgroundView.transform = .identity
            },
            completion: nil)
    }
    
    private let w: CGFloat
    private let h: CGFloat
    private var mode = "walking"
    private let disposeBag = DisposeBag()
    
    private var distanceLabel: EFCountingLabel!
    private var addressLabel: UILabel!
    
    private var walkingLabel: UILabel!
    private var walkingTimeLabel: EFCountingLabel!
    private var walkingBackgroundView: UIView!
    
    private var drivingLabel: UILabel!
    private var drivingTimeLabel: EFCountingLabel!
    private var drivingBackgroundView: UIView!
    
    private var directionsLabel: UILabel!
    private var directionsBackgroundView: UIView!
    
    private var shareImageView: UIImageView!
    
    // Animators
    private var animator: UIViewPropertyAnimator!
    
    // Generator
    private var generator = UIImpactFeedbackGenerator(style: .medium)
}

extension NavigationViewController: MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
