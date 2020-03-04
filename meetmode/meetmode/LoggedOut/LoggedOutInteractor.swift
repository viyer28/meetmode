//
//  LoggedOutInteractor.swift
//  meetmode
//
//  Created by Varun Iyer on 3/4/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs
import RxSwift

protocol LoggedOutRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol LoggedOutPresentable: Presentable {
    var listener: LoggedOutPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol LoggedOutListener: class {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func login()
}

final class LoggedOutInteractor: PresentableInteractor<LoggedOutPresentable>, LoggedOutInteractable, LoggedOutPresentableListener {

    weak var router: LoggedOutRouting?
    weak var listener: LoggedOutListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: LoggedOutPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
        print("attached LoggedOut")
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
        print("detached LoggedOut")
    }
    
    // MARK: - LoggedOutPresentableListener
    
    func login() {
        listener?.login()
    }
}
