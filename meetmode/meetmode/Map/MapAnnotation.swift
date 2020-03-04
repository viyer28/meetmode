//
//  MapAnnotation.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import UIKit
import Mapbox
import SnapKit

class MapAnnotation: MGLPointAnnotation {
    var type: String?
    var friend: User!
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FriendAnnotationView: MGLAnnotationView {
    var friendImageView: UIImageView!
    var friend: User!
    var animator: UIViewPropertyAnimator!
    
    convenience init (reuseIdentifier: String?, friend: User)
    {
        self.init(reuseIdentifier: reuseIdentifier)
        self.alpha = 0
        self.friend = friend
        
        self.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        
        friendImageView = UIImageView(image: friend.image)
        friendImageView.contentMode = .scaleAspectFit
        friendImageView.layer.cornerRadius = 45/2
        friendImageView.clipsToBounds = true
        
        friendImageView.layer.borderColor = UIColor(red: 213/255, green: 168/255, blue: 94/255, alpha: 1.0).cgColor
        friendImageView.layer.borderWidth = 2
        friendImageView.frame = CGRect(x: self.frame.width/2 - 45/2, y: 0, width: 45, height: 45)
        
        addSubview(friendImageView)
        
        showAnimation()
    }
    
    func showAnimation() {
        animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: {
            self.alpha = 1
        })
        
        animator.startAnimation()
    }
    
    func selectAnimation() {
        friendImageView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        UIView.animate(withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.3,
            initialSpringVelocity: 6.0,
            options: .allowUserInteraction,
            animations: { [weak self] in
              self?.friendImageView.transform = .identity
            },
            completion: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
      
        if animator != nil {
            animator.stopAnimation(true)
        }
        self.alpha = 0
        
        animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: {
            self.alpha = 1
        })
        
        animator.startAnimation()
    }
    
    override init (reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

