//
//  LaunchViewController.swift
//  meetmode
//
//  Created by Varun Iyer on 3/4/20.
//  Copyright © 2020 spott. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    private var launchImage: UIImageView!
    
    init(w: CGFloat, h: CGFloat) {
        self.w = w
        self.h = h
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        _setupLaunchImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Private
    
    private func _setupLaunchImage() {
        launchImage = UIImageView(image: UIImage(named: "appLaunch")!)
        launchImage.frame = CGRect(x: 0, y: 0, width: w, height: h)
        launchImage.contentMode = .scaleAspectFill
        
        view.addSubview(launchImage)
    }
    
    private let w: CGFloat
    private let h: CGFloat
}
