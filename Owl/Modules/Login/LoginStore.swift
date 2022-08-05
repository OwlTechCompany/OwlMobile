//
//  LoginStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 11.04.2022.
//

import TCACoordinators
import ComposableArchitecture
import SwiftUI
import FirebaseAuth

struct Login: ReducerProtocol {

    // MARK: - State

    struct State: Equatable {

        @NavigationStateOf<Login.ScreenProvider> var path

        init() {
            path.append(.onboarding(.init()))
        }

    }

    // MARK: - Action

    enum Action: Equatable {

        case delegate(DelegateAction)

        case showSetupPermission
        case path(NavigationActionOf<Login.ScreenProvider>)

        enum DelegateAction: Equatable {
            case loginSuccess
        }
    }

    @Dependency(\.authClient) var authClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.validationClient) var validationClient
    @Dependency(\.firestoreUsersClient) var firestoreUsersClient
    @Dependency(\.storageClient) var storageClient
    @Dependency(\.pushNotificationClient) var pushNotificationClient

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .path(.element(_, .onboarding(.startMessaging))):
                state.path.append(.enterPhone(EnterPhone.State(phoneNumber: "+380", isLoading: false)))
                return .none

            case let .path(.element(id, .enterPhone(.verificationIDResult(.success)))):
                guard case let (.enterPhone(enterPhoneState)) = state.$path[id: id] else {
                    return .none
                }
                let enterCodeState = EnterCode.State(phoneNumber: enterPhoneState.phoneNumber)
                state.path.append(.enterCode(enterCodeState))
                return .none

            case let .path(.element(_, .enterCode(.setMeResult(.success(setMeSuccess))))):
                switch setMeSuccess {
                case .newUser:
                    state.path.append(.enterUserData(EnterUserData.State()))
                    return .none

                case .userExists:
                    return pushNotificationClient.getNotificationSettings
                        .receive(on: DispatchQueue.main)
                        .flatMap { settings -> Effect<Action, Never> in
                            switch settings.authorizationStatus {
                            case .notDetermined:
                                return Effect(value: .showSetupPermission)

                            default:
                                return Effect.concatenate(
                                    pushNotificationClient.register()
                                        .fireAndForget(),

                                    Effect(value: .delegate(.loginSuccess))
                                )
                            }
                        }
                        .eraseToEffect()
                }

            case let .path(.element(_, .enterUserData(.next(needSetupPermissions)))):
                switch needSetupPermissions {
                case true:
                    return Effect(value: .showSetupPermission)

                case false:
                    return Effect(value: .delegate(.loginSuccess))
                }

            case .showSetupPermission:
                state.path.append(.setupPermissions(SetupPermissions.State()))
                return .none

            case .path(.element(_, .setupPermissions(.later))):
                return Effect(value: .delegate(.loginSuccess))

            case .path:
                return .none

            case .delegate:
                return .none
            }
        }
        .navigationDestination(state: \.$path, action: /Action.path) {
            Login.ScreenProvider()
        }
    }

//    var body: some ReducerProtocolOf<Self> {
//        Reduce(
//            Reducer(Login.ScreenProvider())
//                .forEachIdentifiedRoute(environment: { () })
//                .withRouteReducer(Reducer(bodyCore)),
//            environment: ()
//        )
//    }
}
