//
//  EnterPhoneView.swift
//  Owl
//
//  Created by Anastasia Holovash on 07.04.2022.
//

import SwiftUI
import ComposableArchitecture

// MARK: - LoginState + ViewState

private extension LoginState {
    var view: EnterPhoneView.ViewState {
        get {
            EnterPhoneView.ViewState(phoneNumber: phoneNumber)
        }
        set {
            phoneNumber = newValue.phoneNumber
        }
    }
}

// MARK: - LoginAction + ViewAction

private extension LoginAction {
    static func view(_ viewAction: EnterPhoneView.ViewAction) -> Self {
        switch viewAction {
        case let .binding(action):
            return .binding(action.pullback(\.view))

        case .sendPhoneNumber:
            return .sendPhoneNumber
        }
    }
}

// MARK: - View

struct EnterPhoneView: View {

    // MARK: - ViewState

    struct ViewState: Equatable {
        @BindableState var phoneNumber: String
    }

    // MARK: - ViewAction

    enum ViewAction: Equatable, BindableAction {
        case sendPhoneNumber
        case binding(BindingAction<ViewState>)
    }

    // MARK: - Properties

    var store: Store<LoginState, LoginAction>

    var body: some View {
        WithViewStore(store.scope(state: \LoginState.view, action: LoginAction.view)) { viewStore in
            VStack {
                TextField("Phone number", text: viewStore.binding(\.$phoneNumber))
                Button(
                    action: { viewStore.send(.sendPhoneNumber) },
                    label: { Text("Next") }
                )
            }
            .padding()
        }
    }
}

// MARK: - Preview

struct EnterPhoneNumber_Previews: PreviewProvider {
    static var previews: some View {
        EnterPhoneView(store: Store(
            initialState: LoginState(),
            reducer: loginReducer,
            environment: AppEnvironment.live.login
        ))
    }
}
