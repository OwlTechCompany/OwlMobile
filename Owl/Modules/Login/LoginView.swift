//
//  LoginView.swift
//  Owl
//
//  Created by Anastasia Holovash on 07.04.2022.
//

import SwiftUI
import ComposableArchitecture

// MARK: - State

struct LoginState: Equatable {
    @BindableState var phoneNumber: String

    init() {
        phoneNumber = "+380931314850"
    }
}

// MARK: - Action

enum LoginAction: Equatable, BindableAction {
    case loginSuccess
    case sendPhoneNumber
    case verificationIDReceived(Result<String, NSError>)

    case binding(BindingAction<LoginState>)
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
        return environment.authClient
            .verifyPhoneNumber(state.phoneNumber)
            .mapError { $0 as NSError }
            .catchToEffect(LoginAction.verificationIDReceived)
            .eraseToEffect()

    case let .verificationIDReceived(.success(verificationId)):
        print(verificationId)
        return .none

    case let .verificationIDReceived(.failure(error)):
        print(error.localizedDescription)
        return .none

    case .binding(\.$phoneNumber):
        return .none

    case .binding:
        return .none
    }
}.binding()


// MARK: - View

struct LoginView: View {

    var store: Store<LoginState, LoginAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                TextField("Phone number", text: viewStore.binding(\.$phoneNumber))
                Button(
                    action: {
                        viewStore.send(.sendPhoneNumber)
                    },
                    label: {
                        Text("Next")
                    }
                )
            }
            .padding()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(store: Store(
            initialState: .init(),
            reducer: loginReducer,
            environment: AppEnvironment.live.login
        ))
    }
}
