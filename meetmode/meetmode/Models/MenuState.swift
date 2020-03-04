//
//  MenuState.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RxSwift

public enum State {
    case collapsed
    case expanded
}

public protocol MenuStateStream: class {
    var state: Observable<State> { get }
    func getMenuState() -> State
}

public protocol MutableMenuStateStream: MenuStateStream {
    func updateMenuState(with state: State)
}

public class MenuStateStreamImpl: MutableMenuStateStream {
    
    public init() {}
    
    public var state: Observable<State> {
        return variable
            .asObservable()
    }
    
    public func updateMenuState(with state: State) {
        variable.value = state
    }
    
    public func getMenuState() -> State {
        return variable.value
    }
    
    // MARK: - Private
    
    private let variable = Variable<State>(.collapsed)
}
