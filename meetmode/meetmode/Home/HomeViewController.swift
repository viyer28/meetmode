//
//  HomeViewController.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs
import RxSwift
import UIKit
import RxDataSources

protocol HomePresentableListener: class {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func tappedHomeItem(indexPath: IndexPath)
}

final class HomeViewController: UIViewController, HomePresentable, HomeViewControllable {

    weak var listener: HomePresentableListener?
    var homeSections: Variable<[HomeCollectionViewModel]>?
    
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
        
        view.frame = CGRect(x: 0, y: 70, width: self.view.frame.width, height: 100)
        _setupHomeView()
        for view in view.subviews {
            view.alpha = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        homeEntranceAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if animator != nil {
            animator.stopAnimation(true)
        }
    }
    
    // MARK: - Private
        
    private func _setupHomeView() {
        homeFlowLayout = UICollectionViewFlowLayout()
        homeFlowLayout.minimumInteritemSpacing = 5
        homeFlowLayout.scrollDirection = .horizontal
        
        homeCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: w, height: 100), collectionViewLayout: homeFlowLayout)
        
        homeCollectionView.showsHorizontalScrollIndicator = false
        homeCollectionView.showsVerticalScrollIndicator = false
        homeCollectionView.isDirectionalLockEnabled = true
        homeCollectionView.alwaysBounceVertical = false
        homeCollectionView.alwaysBounceHorizontal = true
        homeCollectionView.isPagingEnabled = false
        homeCollectionView.delegate = self
        homeCollectionView.backgroundColor = UIColor.clear
        homeCollectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: "homeCell")
        
        view.addSubview(homeCollectionView)
        
        let homeCollectionDataSource = RxCollectionViewSectionedAnimatedDataSource<HomeCollectionViewModel>(configureCell: { (_, _, _, _) in
            fatalError()
        }, configureSupplementaryView: { (_, _, _, _) in
            fatalError()
        })
        
        homeCollectionDataSource.configureCell = { (datasource, collectionView, indexPath, item) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as? HomeCollectionViewCell
            
            cell?.configure(with: item)
            
            return cell!
        }
        
        if let homeSections = homeSections {
            homeSections.asObservable()
                .bind(to: homeCollectionView.rx.items(dataSource: homeCollectionDataSource))
                .disposed(by: disposeBag)
        }
        
        homeCollectionView.rx
            .itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.generator.impactOccurred()
                self?.listener?.tappedHomeItem(indexPath: indexPath)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Animation
    
    private func homeEntranceAnimation() {
        animator = UIViewPropertyAnimator(duration: 0.35, curve: .easeIn) {
            for view in self.view.subviews {
                view.alpha = 1
            }
        }
        
        animator.startAnimation()
    }
    
    private let w: CGFloat
    private let h: CGFloat
    private let disposeBag = DisposeBag()
    
    // Subviews
    private var homeFlowLayout: UICollectionViewFlowLayout!
    private var homeCollectionView: UICollectionView!
    
    // Animators
    private var animator: UIViewPropertyAnimator!
    
    // Generator
    private let generator = UIImpactFeedbackGenerator(style: .medium)
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 75, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
}
