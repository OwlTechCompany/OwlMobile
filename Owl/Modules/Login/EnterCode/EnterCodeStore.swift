//
//  EnterCodeStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import ComposableArchitecture
import FirebaseAuth

struct EnterCode {

    // MARK: - State

    struct State: Equatable {
        @BindableState var verificationCode: String = ""
        var alert: AlertState<Action>?
        var phoneNumber: String
        var isLoading: Bool = false
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case sendCode
        case resendCode
        case setMe

        case verificationIDResult(Result<String, NSError>)
        case authDataResult(Result<AuthDataResult, NSError>)
        case setMeResult(Result<Bool, NSError>)

        case dismissAlert

        case binding(BindingAction<State>)
    }

    // MARK: - Environment

    struct Environment {
        let authClient: AuthClient
        let userDefaultsClient: UserDefaultsClient
        let firestoreUsersClient: FirestoreUsersClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .binding(\.$verificationCode):
            if state.verificationCode.count == EnterCodeView.Constants.codeSize {
                return Effect(value: .sendCode)
            } else {
                return .none
            }

        case .sendCode:
            state.isLoading = true
            let verificationID = environment.userDefaultsClient.getVerificationID()
            let model = SignIn(
                verificationID: verificationID,
                verificationCode: state.verificationCode
            )
            return environment.authClient.signIn(model)
                .catchToEffect(Action.authDataResult)
                .eraseToEffect()

        case .authDataResult(.success):
            return Effect(value: .setMe)

        case .setMe:
            return environment.firestoreUsersClient.setMeIfNeeded()
                .catchToEffect(Action.setMeResult)
                .eraseToEffect()

        case .setMeResult(.success):
            state.isLoading = false
            return .none

        case let .verificationIDResult(.success(verificationId)):
            state.isLoading = false
            environment.userDefaultsClient.setVerificationID(verificationId)
            return .none

        case .resendCode:
            state.isLoading = true
            return environment.authClient
                .verifyPhoneNumber(state.phoneNumber)
                .mapError { $0 as NSError }
                .catchToEffect(Action.verificationIDResult)
                .eraseToEffect()

        case let .authDataResult(.failure(error)),
             let .verificationIDResult(.failure(error)),
             let .setMeResult(.failure(error)):
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
