//
//  LoginFlowCoordinator.swift
//  Owl
//
//  Created by Denys Danyliuk on 11.04.2022.
//

import ComposableArchitecture
import FirebaseAuth

struct LoginFlowCoordinator: Reducer {
    
    struct State: Equatable {
        var path: StackState<Path.State>
        var onboarding: OnboardingFeature.State
        
        init() {
            path = StackState()
            onboarding = OnboardingFeature.State()
        }
    }
    
    enum Action: Equatable {
        case onboarding(OnboardingFeature.Action)
        case path(StackAction<Path.State, Path.Action>)
        case showSetupPermission
        case delegate(DelegateAction)
        
        enum DelegateAction: Equatable {
            case loginSuccess
        }
    }

    @Dependency(\.authClient) var authClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.validationClient) var validationClient
    @Dependency(\.firestoreUsersClient) var firestoreUsersClient
    @Dependency(\.storageClient) var storageClient
    @Dependency(\.pushNotificationClient) var pushNotificationClient
    
    var body: some ReducerOf<Self> {
        Scope(state: \State.onboarding, action: /Action.onboarding) {
            OnboardingFeature()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .onboarding(.startMessaging):
                state.path.append(.enterPhone(EnterPhoneFeature.State(phoneNumber: "+380", isLoading: false)))
                return .none

            case let .path(.element(_, .enterPhone(.delegate(.success(phoneNumber))))):
                let enterCodeState = EnterCodeFeature.State(phoneNumber: phoneNumber)
                state.path.append(.enterCode(enterCodeState))
                return .none

            case let .path(.element(_, .enterCode(.setMeResult(.success(setMeSuccess))))):
                switch setMeSuccess {
                case .newUser:
                    state.path.append(.enterUserData(EnterUserDataFeature.State()))
                    return .none

                case .userExists:
                    return pushNotificationClient.getNotificationSettings
                        .receive(on: DispatchQueue.main)
                        .flatMap { settings -> EffectPublisher<Action, Never> in
                            switch settings.authorizationStatus {
                            case .notDetermined:
                                return EffectPublisher(value: .showSetupPermission)

                            default:
                                return EffectPublisher.concatenate(
                                    pushNotificationClient.register()
                                        .fireAndForget(),

                                    EffectPublisher(value: .delegate(.loginSuccess))
                                )
                            }
                        }
                        .eraseToEffect()
                }

            case let .path(.element(_, .enterUserData(.next(needSetupPermissions)))):
                switch needSetupPermissions {
                case true:
                    return .send(.showSetupPermission)

                case false:
                    return .send(.delegate(.loginSuccess))
                }

            case .showSetupPermission:
                state.path.append(.setupPermissions(SetupPermissionsFeature.State()))
                return .none

            case .path(.element(_, .setupPermissions(.later))),
                 .path(.element(_, .setupPermissions(.next))):
                return .send(.delegate(.loginSuccess))
                
            case .onboarding:
                return .none

            case .path:
                return .none
            
            case .delegate:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            Path()
        }
    }
}
