//
//  EnterCodeStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import ComposableArchitecture

struct EnterCode {

    // MARK: - State

    struct State: Equatable {
        @BindableState var verificationCode: String
        var phoneNumber: String

        // For some very strange reasons TextField Binding<String> is setting its value two time
        // To fix this (not to send code twice) i decided to use this variable
        var isCodeSent: Bool = false
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case delegate(DelegateAction)

        enum DelegateAction {
            case sendCode
            case resendCode
        }
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .binding(\.$verificationCode):
            if state.verificationCode.count == EnterCodeView.Constants.codeSize && !state.isCodeSent {
                state.isCodeSent = true
                return Effect(value: .delegate(.sendCode))
            } else {
                return .none
            }

        case .delegate(.resendCode):
            state.isCodeSent = false
            return .none

        case .delegate:
            return .none

        case .binding:
            return .none
        }
    }
    .binding()

}
