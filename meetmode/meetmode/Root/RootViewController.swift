//
//  RootViewController.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs
import RxSwift
import UIKit

protocol RootPresentableListener: class {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class RootViewController: UIViewController, RootPresentable, RootViewControllable {

    weak var listener: RootPresentableListener?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Method is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - RootViewControllable
    
    func present(viewController: ViewControllable) {
        viewController.uiviewController.modalPresentationStyle = .fullScreen
        if #available(iOS 13.0, *) {
            uiviewController.isModalInPresentation = false
        } else {
            // Fallback on earlier versions
        }
        present(viewController.uiviewController, animated: false, completion: nil)
    }
    
    func dismiss(viewController: ViewControllable) {
        if presentedViewController === viewController.uiviewController {
            dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - Private
}

// MARK: LoggedInViewControllable

extension RootViewController: LoggedInViewControllable {
    
}

// MARK: LoggedOutViewControllable

extension RootViewController: LoggedOutViewControllable {
    
}
