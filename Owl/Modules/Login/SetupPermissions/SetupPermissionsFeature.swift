//
//  SetupPermissionsFeature.swift
//  Owl
//
//  Created by Denys Danyliuk on 28.04.2022.
//

import ComposableArchitecture
import FirebaseMessaging

struct SetupPermissionsFeature: Reducer {
    
    struct State: Equatable { }
    
    enum Action: Equatable {
        case grandPermission
        case later
        case requestAuthorizationResult(Result<Bool, NSError>)
        case next
    }
    
    @Dependency(\.pushNotificationClient) var pushNotificationClient
    
    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .grandPermission:
                return pushNotificationClient.requestAuthorization([.alert, .sound, .badge])
                    .receive(on: DispatchQueue.main)
                    .catchToEffect(Action.requestAuthorizationResult)
                
            case .later:
                return .none
                
            case .requestAuthorizationResult(.success):
                return EffectPublisher.concatenate(
                    pushNotificationClient.register()
                        .fireAndForget(),
                    
                    EffectPublisher(value: .next)
                )
                
            case .requestAuthorizationResult(.failure):
                return .none
                
            case .next:
                return .none
            }
        }
    }
    
}
