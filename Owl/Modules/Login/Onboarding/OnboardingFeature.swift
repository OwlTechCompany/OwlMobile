//
//  OnboardingFeature.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import ComposableArchitecture

struct OnboardingFeature: Reducer {
    
    struct State: Equatable { }
    
    enum Action: Equatable {
        case startMessaging
    }
    
    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .startMessaging:
                return .none
            }
        }
    }
    
}
