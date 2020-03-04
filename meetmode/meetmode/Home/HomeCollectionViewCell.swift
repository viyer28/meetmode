//
//  HomeCollectionViewCell.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class HomeCollectionViewCell: UICollectionViewCell {

    private var imageView: UIImageView!
    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    
    private var friend: User!
    
    func configure(with collectionViewModel: HomeCollectionData) -> (Void) {
        friend = collectionViewModel.friend
        
        imageView.image = friend.image
        imageView.contentMode = .scaleAspectFill
        
        titleLabel.text = friend.name
        
        if friend.distance < 528 {
            subtitleLabel.text = "\(Int(friend.distance)) ft"
        } else {
            subtitleLabel.text = "\(Double(round(10*(friend.distance/5280))/10)) mi"
        }
        subtitleLabel.textAlignment = .center
        subtitleLabel.sizeToFit()

        imageView.layer.cornerRadius = 50/2
        imageView.clipsToBounds = true
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top)
            make.centerX.equalTo(self.snp.centerX)
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(imageView.snp.centerX)
            make.top.equalTo(imageView.snp.bottom).offset(10)
        }
        
        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(imageView.snp.centerX)
            make.top.equalTo(titleLabel.snp.bottom).offset(2.5)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        _setupView()
    }
    
    private func _setupView() {
        imageView = UIImageView()
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.alpha = 0.9
        
        subtitleLabel = UILabel()
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.bold)
        subtitleLabel.textColor = UIColor(red: 213/255, green: 168/255, blue: 94/255, alpha: 1.0)
        subtitleLabel.textAlignment = .center
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
