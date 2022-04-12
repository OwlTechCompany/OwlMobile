//
//  EnterPhoneView.swift
//  Owl
//
//  Created by Anastasia Holovash on 07.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct EnterPhone {

    // MARK: - ViewState

    struct State: Equatable {
        @BindableState var phoneNumber: String
    }

    // MARK: - ViewAction

    enum Action: Equatable, BindableAction {

        case binding(BindingAction<State>)
        case delegate(DelegateAction)

        enum DelegateAction {
            case sendPhoneNumber
        }
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .binding(\.$phoneNumber):
            return .none

        case .delegate:
            return .none

        case .binding:
            return .none
        }
    }
    .binding()
}

// MARK: - View

struct EnterPhoneView: View {

    var store: Store<EnterPhone.State, EnterPhone.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 16) {
                TextField("Phone number", text: viewStore.binding(\.$phoneNumber))
                    .textFieldStyle(PlainTextFieldStyle())

                Button(
                    action: { viewStore.send(.delegate(.sendPhoneNumber)) },
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
            initialState: EnterPhone.State(phoneNumber: "+380992177560"),
            reducer: EnterPhone.reducer,
            environment: EnterPhone.Environment()
        ))
    }
}
