//
//  ProfileFeature.swift
//  Owl
//
//  Created by Denys Danyliuk on 18.04.2022.
//

import ComposableArchitecture
import UIKit

struct ProfileFeature: Reducer {
    
    struct State: Equatable {
        var user: User
        var alert: AlertState<Action>?
    }
    
    enum Action: Equatable {
        case onAppear
        case close
        case edit
        
        case updateUser(User)
        
        case logoutTapped
        case logout
        
        case dismissAlert
    }
    
    @Dependency(\.userClient) var userClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return EffectPublisher.run { subscriber in
                    userClient.firestoreUser
                        .compactMap { $0 }
                        .sink { subscriber.send(.updateUser($0)) }
                }
                .cancellable(id: Main.ListenersId())
                
            case let .updateUser(user):
                state.user = user
                return .none
                
            case .close:
                return .none
                
            case .edit:
                return .none
                
            case .logoutTapped:
                state.alert = AlertState(
                    title: TextState("Are you sure?"),
                    primaryButton: .cancel(TextState("Cancel")),
                    secondaryButton: .destructive(
                        TextState("Logout"),
                        action: .send(.logout)
                    )
                )
                return .none
                
            case .logout:
                return .none
                
            case .dismissAlert:
                state.alert = nil
                return .none
            }
            
        }
    }
    
}
