//
//  EnterPhoneView.swift
//  Owl
//
//  Created by Anastasia Holovash on 07.04.2022.
//

import SwiftUI
import ComposableArchitecture

// MARK: - ViewState

struct EnterPhoneState: Equatable {
    @BindableState var phoneNumber: String
}

// MARK: - ViewAction

enum EnterPhoneAction: Equatable, BindableAction {
    case sendPhoneNumber

    case binding(BindingAction<EnterPhoneState>)
}

// MARK: - Environment

struct EnterPhoneEnvironment { }

// MARK: - Reducer

let enterPhoneReducer = Reducer<EnterPhoneState, EnterPhoneAction, EnterPhoneEnvironment> { state, action, environment in
    switch action {
    case .sendPhoneNumber:
        return .none

    case .binding(\.$phoneNumber):
        print("Validating")
        return .none

    case .binding:
        return .none
    }
}

// MARK: - View

struct EnterPhoneView: View {

    // MARK: - Properties

    var store: Store<EnterPhoneState, EnterPhoneAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 16) {
                TextField("Phone number", text: viewStore.binding(\.$phoneNumber))
                    .textFieldStyle(PlainTextFieldStyle())

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
            initialState: EnterPhoneState(phoneNumber: "+380992177560"),
            reducer: enterPhoneReducer,
            environment: EnterPhoneEnvironment()
        ))
    }
}
