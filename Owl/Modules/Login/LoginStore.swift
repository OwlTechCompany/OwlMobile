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

    struct State: Equatable, IdentifiedRouterState {

        var routes: IdentifiedArrayOf<Route<ScreenProvider.State>>

        static let initialState = State(
            routes: [
                .root(.onboarding(Onboarding.State()), embedInNavigationView: true)
            ]
        )
    }

    // MARK: - Action

    enum Action: Equatable, IdentifiedRouterAction {

        case delegate(DelegateAction)

        case showSetupPermission
        case routeAction(ScreenProvider.State.ID, action: ScreenProvider.Action)
        case updateRoutes(IdentifiedArrayOf<Route<ScreenProvider.State>>)

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

    var bodyCore: some ReducerProtocol<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .routeAction(_, .onboarding(.startMessaging)):
                state.routes.push(.enterPhone(EnterPhone.State(phoneNumber: "+380", isLoading: false)))
                return .none

            case .routeAction(_, .enterPhone(.verificationIDResult(.success))):
                guard let enterPhoneState = state.subState(routePath: ScreenProvider.EnterPhoneRoute.self) else {
                    return .none
                }
                let enterCodeState = EnterCode.State(phoneNumber: enterPhoneState.phoneNumber)
                state.routes.push(.enterCode(enterCodeState))
                return .none

            case let .routeAction(_, .enterCode(.setMeResult(.success(setMeSuccess)))):
                switch setMeSuccess {
                case .newUser:
                    state.routes.push(.enterUserData(EnterUserData.State()))
                    return .none

                case .userExists:
                    return pushNotificationClient.getNotificationSettings
                        .receive(on: DispatchQueue.main)
                        .flatMap { settings -> EffectPublisher<Action, Never> in
                            switch settings.authorizationStatus {
                            case .notDetermined:
                                return EffectPublisher(value: .showSetupPermission)

                            default:
                                return EffectPublisher.concatenate(
                                    pushNotificationClient.register()
                                        .fireAndForget(),

                                    EffectPublisher(value: .delegate(.loginSuccess))
                                )
                            }
                        }
                        .eraseToEffect()
                }

            case let .routeAction(_, .enterUserData(.next(needSetupPermissions))):
                switch needSetupPermissions {
                case true:
                    return EffectPublisher(value: .showSetupPermission)

                case false:
                    return EffectPublisher(value: .delegate(.loginSuccess))
                }

            case .showSetupPermission:
                state.routes.push(.setupPermissions(SetupPermissions.State()))
                return .none

            case .routeAction(_, .setupPermissions(.later)),
                 .routeAction(_, .setupPermissions(.next)):
                return EffectPublisher(value: .delegate(.loginSuccess))

            case .routeAction:
                return .none

            case .updateRoutes:
                return .none

            case .delegate:
                return .none
            }
        }
    }

    var body: some ReducerProtocol<State, Action> {
        bodyCore
            .forEachRoute {
                Login.ScreenProvider()
            }
    }
}
