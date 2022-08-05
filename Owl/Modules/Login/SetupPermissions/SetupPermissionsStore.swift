//
//  SetupPermissionsStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 28.04.2022.
//

import ComposableArchitecture
import FirebaseMessaging

struct SetupPermissions: ReducerProtocol {

    // MARK: - State

    struct State: Equatable, Hashable { }

    // MARK: - Action

    enum Action: Equatable {
        case grandPermission
        case later
        case requestAuthorizationResult(Result<Bool, NSError>)
        case next
    }

    @Dependency(\.pushNotificationClient) var pushNotificationClient

    // MARK: - Reducer

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .grandPermission:
                return pushNotificationClient.requestAuthorization([.alert, .sound, .badge])
                    .receive(on: DispatchQueue.main)
                    .catchToEffect(Action.requestAuthorizationResult)

            case .later:
                return .none

            case .requestAuthorizationResult(.success):
                return Effect.concatenate(
                    pushNotificationClient.register()
                        .fireAndForget(),

                    Effect(value: .next)
                )

            case .requestAuthorizationResult(.failure):
                return .none

            case .next:
                return .none
            }
        }
    }

}
