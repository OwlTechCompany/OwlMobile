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

    var body: some ReducerProtocolOf<Self> {
        Reduce { _, action in
            switch action {
            case .startMessaging:
                return .none
            }
        }
    }

}
