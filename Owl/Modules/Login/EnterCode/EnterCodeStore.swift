//
//  EnterCodeStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import ComposableArchitecture
import FirebaseAuth

struct EnterCode: ReducerProtocol {

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
        case setMeResult(Result<SignInUserType, NSError>)

        case dismissAlert

        case binding(BindingAction<State>)
    }

    @Dependency(\.authClient) var authClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.firestoreUsersClient) var firestoreUsersClient

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(\.$verificationCode):
                if state.verificationCode.count == EnterCodeView.Constants.codeSize {
                    return EffectPublisher(value: .sendCode)
                } else {
                    return .none
                }

            case .sendCode:
                state.isLoading = true
                let verificationID = userDefaultsClient.getVerificationID()
                let model = SignIn(
                    verificationID: verificationID,
                    verificationCode: state.verificationCode
                )
                return authClient.signIn(model)
                    .catchToEffect(Action.authDataResult)

            case .authDataResult(.success):
                return EffectPublisher(value: .setMe)

            case .setMe:
                return firestoreUsersClient.setMeIfNeeded()
                    .catchToEffect(Action.setMeResult)

            case .setMeResult(.success):
                state.isLoading = false
                return .none

            case let .verificationIDResult(.success(verificationId)):
                state.isLoading = false
                userDefaultsClient.setVerificationID(verificationId)
                return .none

            case .resendCode:
                state.isLoading = true
                return authClient
                    .verifyPhoneNumber(state.phoneNumber)
                    .catchToEffect(Action.verificationIDResult)

            case let .authDataResult(.failure(error)),
                let .verificationIDResult(.failure(error)),
                let .setMeResult(.failure(error)):
                state.isLoading = false
                state.alert = AlertState(
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
    }

}
