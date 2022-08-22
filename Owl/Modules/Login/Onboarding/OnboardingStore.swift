//
//  OnboardingStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import ComposableArchitecture

struct Onboarding: ReducerProtocol {

    // MARK: - State

    struct State: Equatable { }

    // MARK: - Action

    enum Action: Equatable {
        case startMessaging
    }

    // MARK: - Reducer

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .startMessaging:
                return .none
            }
        }
    }

}
