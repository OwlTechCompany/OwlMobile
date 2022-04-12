//
//  Routable.swift
//  Owl
//
//  Created by Denys Danyliuk on 12.04.2022.
//

import ComposableArchitecture
import TCACoordinators

protocol Routable {

    associatedtype ID
    associatedtype ScreenProvider: Equatable & Identifiable
    associatedtype RouteState: Equatable

    static var id: ID { get }
    static var statePath: CasePath<ScreenProvider, RouteState> { get }
}

extension Routable {
    static var id: String {
        return String(describing: self)
    }
}
