//
//  MenuViewController.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs
import RxSwift
import UIKit
import SnapKit

protocol MenuPresentableListener: class {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func updateMenuState(state: State)
}

final class MenuViewController: UIViewController, MenuPresentable, MenuViewControllable {

    weak var listener: MenuPresentableListener?
    
    init(w: CGFloat, h: CGFloat) {
        self.w = w
        self.h = h
        self.menuHeight = h/10
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Method is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.frame = self.collapsedFrame()
        
        _setupMenuView()
        _setupGestures()
        
        for view in view.subviews {
            view.alpha = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        menuEntranceAnimation()
    }
    
    // MARK: - MenuViewControllable
    
    func show(subView: ViewControllable) {
        addChild(subView.uiviewController)
        view.addSubview(subView.uiviewController.view)
    }
    
    func hide(subView: ViewControllable) {
        subView.uiviewController.removeFromParent()
        subView.uiviewController.view.removeFromSuperview()
    }
    
    // MARK: - MenuPresentable
    
    func transitionBackToHome() {
        if self.state != .collapsed {
            self.state = .collapsed
            self.startInteractiveTransition(state: self.state, duration: self.animatorDuration)
            self.continueInteractiveTransition(fractionComplete: 0.05)
        }
    }
    
    func transitionToNavigation() {
        if self.state != .expanded {
            self.state = .expanded
            self.startInteractiveTransition(state: self.state, duration: self.animatorDuration)
            self.continueInteractiveTransition(fractionComplete: 0.05)
        }
    }
    
    // MARK: - Private
    
    private func _setupMenuView() {
        backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 15/255, green: 16/255, blue: 18/255, alpha: 1.0)
        backgroundView.layer.cornerRadius = 30
        if #available(iOS 11.0, *) {
            backgroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.snp.centerX)
            make.centerY.equalTo(self.view.snp.centerY)
            make.height.equalTo(self.view.snp.height)
            make.width.equalTo(self.view.snp.width)
        }
        
        meetLabel = UILabel()
        meetLabel.font = UIFont.systemFont(ofSize: 28, weight: UIFont.Weight.bold)
        meetLabel.textAlignment = .left
        meetLabel.text = "friends"
        meetLabel.textColor = UIColor(red: 213/255, green: 168/255, blue: 94/255, alpha: 1.0)
        meetLabel.sizeToFit()
        
        view.addSubview(meetLabel)
        meetLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.top).offset(20)
            make.left.equalTo(self.view.snp.left).offset(self.w/8 - 30)
        }
    }
    
    private func _setupGestures() {
        let panGesture = view.rx
            .panGesture()
            .share(replay: 1)
        
        panGesture
            .when(.began)
            .asLocation()
            .subscribe(onNext: { point in
                if self.translationY != 0 {
                    self.translationY = 0
                }
            })
            .disposed(by: disposeBag)
        
        panGesture
            .when(.changed)
            .asTranslation()
            .filter { _, velocity in
                return abs(velocity.y) > abs(velocity.x)
            }
            .subscribe(onNext: { translation, _ in
                self.translationY = translation.y
                if self.runningAnimators.isEmpty {
                    self.startInteractiveTransition(state: self.nextState(), duration: self.animatorDuration)
                } else {
                    self.updateInteractiveTransition(fractionComplete: self.fractionComplete(state: self.nextState(), translation: translation))
                }
            })
            .disposed(by: disposeBag)
        
        panGesture
            .when(.ended)
            .asTranslation()
            .subscribe(onNext: { translation, _ in
                if !self.runningAnimators.isEmpty {
                    self.translationY = translation.y
                    self.continueInteractiveTransition(fractionComplete: self.fractionComplete(state: self.nextState(), translation: translation))
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Util
    
    private func collapsedFrame() -> CGRect {
        return CGRect(
            x: 0,
            y: h - 225,
            width: self.view.frame.width,
            height: menuHeight*4.5)
    }
    
    private func expandedFrame() -> CGRect {
        return CGRect(
            x: 0,
            y: h - menuHeight*4.5,
            width: self.view.frame.width,
            height: menuHeight*4.5
        )
    }
    
    private func fractionComplete(state: State, translation: CGPoint) -> CGFloat {
        switch state {
        case .expanded:
            return -translation.y / (h - menuHeight) + progressWhenInterrupted
        case .collapsed:
            return translation.y / (h - menuHeight) + progressWhenInterrupted
        }
    }
    
    private func nextState() -> State {
        switch self.state {
        case .collapsed:
            if self.translationY == 0 {
                return .expanded
            } else {
                return .collapsed
            }
        case .expanded:
            if self.translationY < 0 {
                return .expanded
            } else {
                return .collapsed
            }
        }
    }
    
    // MARK: Animation
    
    private func menuEntranceAnimation() {
        let animator = UIViewPropertyAnimator(duration: 0.35, curve: .easeIn) {
            for view in self.view.subviews {
                view.alpha = 1
            }
        }
        
        animator.startAnimation()
    }
    
    // Frame Animation
    private func addFrameAnimator(state: State, duration: TimeInterval) {
        // Frame Animation
        let frameAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
            switch state {
            case .expanded:
                self.view.frame = self.expandedFrame()
                self.meetLabel.alpha = 0
            case .collapsed:
                self.view.frame = self.collapsedFrame()
                self.meetLabel.alpha = 1
            }
        }
        frameAnimator.addCompletion({ (position) in
            switch position {
            case .end:
                self.translationY = 0
                self.view.isUserInteractionEnabled = true
            default:
                break
            }
            self.runningAnimators.removeAll()
        })
        runningAnimators.append(frameAnimator)
    }
    
    // Perform all animations with animators if not already running
    private func animateTransitionIfNeeded(state: State, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            self.addFrameAnimator(state: state, duration: duration)
        }
    }
    
    // Starts transition if necessary or reverse it on tap
    private func animateOrReverseRunningTransition(state: State, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
            runningAnimators.forEach({ $0.startAnimation() })
        } else {
            runningAnimators.forEach({ $0.isReversed = !$0.isReversed })
        }
    }
    
    // Starts transition if necessary and pauses on pan .began
    private func startInteractiveTransition(state: State, duration: TimeInterval) {
        self.animateTransitionIfNeeded(state: state, duration: duration)
        runningAnimators.forEach({ $0.pauseAnimation() })
        progressWhenInterrupted = runningAnimators.first?.fractionComplete ?? 0
    }
    
    // Scrubs transition on pan .changed
    private func updateInteractiveTransition(fractionComplete: CGFloat) {
        runningAnimators.forEach({ $0.fractionComplete = fractionComplete })
    }
    
    // Continues or reverse transition on pan .ended
    private func continueInteractiveTransition(fractionComplete: CGFloat) {
        let cancel: Bool = fractionComplete < 0.05
        
        if cancel {
            runningAnimators.forEach({
                $0.isReversed = !$0.isReversed
                $0.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            })
            return
        } else {
            self.view.isUserInteractionEnabled = false
            if translationY != 0 {
                self.lightGenerator.impactOccurred()
                if self.state != self.nextState() {
                    self.listener?.updateMenuState(state: self.nextState())
                    self.state = self.nextState()
                }
            }
        }
        
        let timing = UICubicTimingParameters(animationCurve: .linear)
        runningAnimators.forEach({ $0.continueAnimation(withTimingParameters: timing, durationFactor: 0) })
    }
    
    private let disposeBag = DisposeBag()
    private let w: CGFloat
    private let h: CGFloat
    
    private var backgroundView: UIView!
    private var meetLabel: UILabel!
    
    private let menuHeight: CGFloat
    private let animatorDuration: TimeInterval = 0.25
    
    // Tracks all running aninmators
    private var progressWhenInterrupted: CGFloat = 0
    private var runningAnimators = [UIViewPropertyAnimator]()
    private var state: State = .collapsed
    private var translationY: CGFloat = 0
    
    private var lightGenerator = UIImpactFeedbackGenerator(style: .light)
}
