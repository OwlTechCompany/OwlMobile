//
//  EnterPhoneFeature.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import ComposableArchitecture
import Foundation

struct EnterPhoneFeature: Reducer {
    
    struct State: Equatable {
        @BindingState var phoneNumber: String
        var isPhoneNumberValid: Bool = false
        var alert: AlertState<Action>?
        var isLoading: Bool
    }
    
    enum Action: Equatable, BindableAction {
        case sendPhoneNumber
        case verificationIDResult(Result<String, NSError>)
        case dismissAlert
        
        case delegate(Delegate)
        case binding(BindingAction<State>)
        
        enum Delegate: Equatable {
            case success(_ phoneNumber: String)
        }
    }
    
    @Dependency(\.authClient) var authClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.validationClient) var validationClient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
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
                return .send(.delegate(.success(state.phoneNumber)))
                
            case let .verificationIDResult(.failure(error)):
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
                
            case .delegate:
                return .none
                
            case .binding:
                return .none
            }
        }
    }
    
}
