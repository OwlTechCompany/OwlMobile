//
//  LoginStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 08.04.2022.
//

import ComposableArchitecture

// MARK: - State

struct LoginState: Equatable, Hashable, RoutableState {

    @BindableState var phoneNumber: String

    var currentRoute: OnboardingView.Route?

    init() {
        phoneNumber = "+380992177560"
        currentRoute = nil
    }
}

// MARK: - Action

enum LoginAction: Equatable, BindableAction, RoutableAction {
    case sendPhoneNumber
    case verificationIDReceived(Result<String, NSError>)
    case loginSuccess

    case binding(BindingAction<LoginState>)

    typealias Route = OnboardingView.Route?
    case router(RoutingAction<Route>)
}

// MARK: - Environment

struct LoginEnvironment {
    let authClient: AuthClient
}

// MARK: - Reducer

let loginReducer = Reducer<LoginState, LoginAction, LoginEnvironment> { state, action, environment in
    switch action {
    case .loginSuccess:
        return .none

    case .sendPhoneNumber:
        print(state.phoneNumber)
        return environment.authClient
            .verifyPhoneNumber(state.phoneNumber)
            .mapError { $0 as NSError }
            .catchToEffect(LoginAction.verificationIDReceived)
            .eraseToEffect()

    case let .verificationIDReceived(.success(verificationId)):
        return Effect(value: .navigate(to: nil))
            .delay(for: 5, scheduler: DispatchQueue.main)
            .eraseToEffect()

    case let .verificationIDReceived(.failure(error)):
        return Effect(value: .navigate(to: nil))

    case .binding(\.$phoneNumber):
        print("Validating")
        return .none

    case .binding:
        return .none

    case .router:
        return .none
    }
}
.binding()
.routing()
