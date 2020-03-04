//
//  LoggedOutViewController.swift
//  meetmode
//
//  Created by Varun Iyer on 3/4/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs
import RxSwift
import UIKit
import CoreLocation

protocol LoggedOutPresentableListener: class {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func login()
}

final class LoggedOutViewController: UIViewController, LoggedOutPresentable, LoggedOutViewControllable {

    weak var listener: LoggedOutPresentableListener?
    
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
        
        view.backgroundColor = UIColor(red: 15/255, green: 16/255, blue: 18/255, alpha: 1.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loggedOutAnimation()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom]
    }
    
    // MARK: - Private
    
    private func _setupLocation() {
        locationLabel = UILabel()
        locationLabel.numberOfLines = 0
        locationLabel.text = "MEETMODE USES YOUR LOCATION\nTO SHOW YOU FRIENDS NEARBY"
        locationLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.thin)
        locationLabel.textColor = UIColor(red: 213/255, green: 168/255, blue: 94/255, alpha: 1.0)
        locationLabel.textAlignment = .center
        locationLabel.sizeToFit()
        locationLabel.alpha = 0
        
        view.addSubview(locationLabel)
        locationLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.snp.centerX)
            make.centerY.equalTo(self.view.frame.height/5)
        }
        
        locationImageView = UIImageView(image: UIImage(named: "allowMeetmodeLocation")!)
        locationImageView.contentMode = .scaleAspectFill
        locationImageView.alpha = 0
        
        view.addSubview(locationImageView)
        locationImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.snp.centerX)
            make.centerY.equalTo(self.view.snp.centerY)
            make.left.equalTo(self.view.snp.left).offset(30)
            make.right.equalTo(self.view.snp.right).offset(-30)
        }
        
        locationImageView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.generator.impactOccurred()
                self?.locationManager.delegate = self!
                self?.locationManager.requestWhenInUseAuthorization()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Animation
    
    private func loggedOutAnimation() {
        self.view.isUserInteractionEnabled = false
        _setupLocation()
        
        let animator = UIViewPropertyAnimator(duration: 0.35, curve: .easeOut) {
            self.locationLabel.alpha = 1
            self.locationImageView.alpha = 1
        }
        
        animator.addCompletion { _ in
            self.view.isUserInteractionEnabled = true
        }
        
        animator.startAnimation()
    }
    
    private let disposeBag = DisposeBag()
    private let w: CGFloat
    private let h: CGFloat
    private let locationManager = CLLocationManager()
    private let generator = UIImpactFeedbackGenerator(style: .medium)
    
    // Location
    private var locationLabel: UILabel!
    private var locationImageView: UIImageView!
}

extension LoggedOutViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            listener?.login()
            break
        case .authorizedWhenInUse:
            listener?.login()
            break
        case .notDetermined:
            break
        default:
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "so... i kinda need your location for this to work 😅", message: "please turn on \"location\" in settings", preferredStyle: .alert)
                let settingsAction = UIAlertAction(title: "settings", style: .default) { (_) -> Void in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                    }
                }
                alertController.addAction(settingsAction)
                self.present(alertController, animated: true, completion: nil)
            }
            break
        }
    }
}
