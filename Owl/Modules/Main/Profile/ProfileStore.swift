//
//  ProfileStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 18.04.2022.
//

import ComposableArchitecture
import UIKit

struct Profile {

    // MARK: - State

    struct State: Equatable {
        var image: UIImage
//        var 
    }

    // MARK: - Action

    enum Action: Equatable {
        case startMessaging
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .startMessaging:
            return .none
        }
    }

}
