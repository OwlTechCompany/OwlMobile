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
                    .map { $0.authorizationStatus == .authorized }
                    .receive(on: DispatchQueue.main)
                    .flatMap { authorized -> Effect<Action, Never> in
                        switch authorized {
                        case true:
                            return Effect(value: .delegate(.loginSuccess))
                        case false:
                            return Effect(value: .showSetupPermission)
                        }
                    }
                    .eraseToEffect()
            }

        case let .routeAction(_, .enterUserData(.next(showSetupPermissions))):
            switch showSetupPermissions {
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

        case .delegate(.loginSuccess):
            return .concatenate(
                environment.pushNotificationClient
                    .register()
                    .fireAndForget(),

                environment.pushNotificationClient
                    .currentFCMToken()
                    .map { UserUpdate(fcmToken: $0) }
                    .flatMap { environment.firestoreUsersClient.updateMe($0) }
                    .fireAndForget()
            )

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
