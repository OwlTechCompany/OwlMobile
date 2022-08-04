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

struct Login {

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

    // MARK: - Environment

    struct Environment {
        let authClient: AuthClient
        let userDefaultsClient: UserDefaultsClient
        let validationClient: ValidationClient
        let firestoreUsersClient: FirestoreUsersClient
        let storageClient: StorageClient
        let pushNotificationClient: PushNotificationClient
    }

    // MARK: - Reducer

//    var body: some ReducerProtocolOf<Self> {
//        Reduce { state, action in
//            switch action {
//            case .routeAction(_, .onboarding(.startMessaging)):
//                state.routes.push(.enterPhone(EnterPhone.State(phoneNumber: "+380", isLoading: false)))
//                return .none
//
//            case .routeAction(_, .enterPhone(.verificationIDResult(.success))):
//                guard var enterPhoneState = state.subState(routePath: ScreenProvider.EnterPhoneRoute.self) else {
//                    return .none
//                }
//                let enterCodeState = EnterCode.State(phoneNumber: enterPhoneState.phoneNumber)
//                state.routes.push(.enterCode(enterCodeState))
//                return .none
//
//            case let .routeAction(_, .enterCode(.setMeResult(.success(setMeSuccess)))):
//                switch setMeSuccess {
//                case .newUser:
//                    state.routes.push(.enterUserData(EnterUserData.State()))
//                    return .none
//
//                case .userExists:
//                    return environment.pushNotificationClient
//                        .getNotificationSettings
//                        .receive(on: DispatchQueue.main)
//                        .flatMap { settings -> Effect<Action, Never> in
//                            switch settings.authorizationStatus {
//                            case .notDetermined:
//                                return Effect(value: .showSetupPermission)
//
//                            default:
//                                return Effect.concatenate(
//                                    environment.pushNotificationClient
//                                        .register()
//                                        .fireAndForget(),
//
//                                    Effect(value: .delegate(.loginSuccess))
//                                )
//                            }
//                        }
//                        .eraseToEffect()
//                }
//
//            case let .routeAction(_, .enterUserData(.next(needSetupPermissions))):
//                switch needSetupPermissions {
//                case true:
//                    return Effect(value: .showSetupPermission)
//
//                case false:
//                    return Effect(value: .delegate(.loginSuccess))
//                }
//
//            case .showSetupPermission:
//                state.routes.push(.setupPermissions(SetupPermissions.State()))
//                return .none
//
//            case .routeAction(_, .setupPermissions(.later)),
//                    .routeAction(_, .setupPermissions(.next)):
//                return Effect(value: .delegate(.loginSuccess))
//
//            case .routeAction:
//                return .none
//
//            case .updateRoutes:
//                return .none
//
//            case .delegate:
//                return .none
//            }
//        }
//    }

    static private let reducerCore = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .routeAction(_, .onboarding(.startMessaging)):
            state.routes.push(.enterPhone(EnterPhone.State(phoneNumber: "+380", isLoading: false)))
            return .none

        case .routeAction(_, .enterPhone(.verificationIDResult(.success))):
            guard var enterPhoneState = state.subState(routePath: ScreenProvider.EnterPhoneRoute.self) else {
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
                return environment.pushNotificationClient
                    .getNotificationSettings
                    .receive(on: DispatchQueue.main)
                    .flatMap { settings -> Effect<Action, Never> in
                        switch settings.authorizationStatus {
                        case .notDetermined:
                            return Effect(value: .showSetupPermission)

                        default:
                            return Effect.concatenate(
                                environment.pushNotificationClient
                                    .register()
                                    .fireAndForget(),

                                Effect(value: .delegate(.loginSuccess))
                            )
                        }
                    }
                    .eraseToEffect()
            }

        case let .routeAction(_, .enterUserData(.next(needSetupPermissions))):
            switch needSetupPermissions {
            case true:
                return Effect(value: .showSetupPermission)

            case false:
                return Effect(value: .delegate(.loginSuccess))
            }

        case .showSetupPermission:
            state.routes.push(.setupPermissions(SetupPermissions.State()))
            return .none

        case .routeAction(_, .setupPermissions(.later)),
             .routeAction(_, .setupPermissions(.next)):
            return Effect(value: .delegate(.loginSuccess))

        case .routeAction:
            return .none

        case .updateRoutes:
            return .none

        case .delegate:
            return .none
        }
    }

    static let reducer = Reducer<State, Action, Environment>.combine(
        Login.ScreenProvider.reducer
            .forEachIdentifiedRoute(environment: { $0 })
            .withRouteReducer(reducerCore)
    )
}
