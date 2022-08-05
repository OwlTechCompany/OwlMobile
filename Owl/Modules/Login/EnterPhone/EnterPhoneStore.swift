//
//  EnterPhoneStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import ComposableArchitecture

struct EnterPhone: ReducerProtocol {

    // MARK: - State

    struct State: Equatable, Hashable {
        @BindableState var phoneNumber: String
        var isPhoneNumberValid: Bool = false
        var alert: AlertState<Action>?
        var isLoading: Bool

        func hash(into hasher: inout Hasher) {
            hasher.combine(phoneNumber)
            hasher.combine(isPhoneNumberValid)
            hasher.combine(isLoading)
        }
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case sendPhoneNumber
        case verificationIDResult(Result<String, NSError>)
        case dismissAlert

        case binding(BindingAction<State>)
    }

    @Dependency(\.authClient) var authClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.validationClient) var validationClient

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .binding(\.$phoneNumber):
                state.isPhoneNumberValid = validationClient.phoneValidation(state.phoneNumber)
                return .none

            case .sendPhoneNumber:
                state.isLoading = true
                return authClient
                    .verifyPhoneNumber(state.phoneNumber)
                    .catchToEffect(Action.verificationIDResult)

            case let .verificationIDResult(.success(verificationId)):
                state.isLoading = false
                userDefaultsClient.setVerificationID(verificationId)
                return .none

            case let .verificationIDResult(.failure(error)):
                state.isLoading = false
                state.alert = .init(
                    title: TextState("Error"),
                    message: TextState("\(error.localizedDescription)"),
                    dismissButton: .default(TextState("Ok"))
                )
                return .none

            case .dismissAlert:
                state.alert = nil
                return .none

            case .binding:
                return .none
            }
        }
        .binding()
    }

}
