//
//  LoginStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 08.04.2022.
//

import ComposableArchitecture

// MARK: - State

struct LoginState: Equatable {

    @BindableState var phoneNumber: String

    var route: OnboardingView.Route?

    typealias Route = OnboardingView.Route
//    enum Route: Equatable {
//        case enterPhone(EnterPhoneView.Route)
//    }

    init() {
        phoneNumber = "+380992177560"
        route = .enterPhone(.enterCode)
    }
}

// MARK: - Action

enum LoginAction: Equatable, BindableAction {
    case loginSuccess
    case setRoute(LoginState.Route?)
    case sendPhoneNumber
    case verificationIDReceived(Result<String, NSError>)
    case test

    case binding(BindingAction<LoginState>)
}

// MARK: - Environment

struct LoginEnvironment {
    let authClient: AuthClient
}

// MARK: - Reducer

let loginReducer = Reducer<LoginState, LoginAction, LoginEnvironment> { state, action, environment in
    switch action {

    case let .setRoute(route):
        print("Setting new route \(route)")
        state.route = route
        return .none

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
        state.route = .enterPhone(.enterCode)
        print(verificationId)
        return Effect(value: .test)
            .delay(for: 5, scheduler: DispatchQueue.main)
            .eraseToEffect()

    case .test:
        state.route = .enterPhone(.enterCode)
        return .none

    case let .verificationIDReceived(.failure(error)):
//        state.route = nil
        print(error.localizedDescription)
        return .none

    case .binding(\.$phoneNumber):
        print("Validating")
        print(state.phoneNumber)
        return .none

    case .binding:
        return .none
    }
}.binding()
