//
//  AppStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import ComposableArchitecture
import FirebaseAuth
import UserNotifications

struct App: ReducerProtocol {

    // MARK: - State

    struct State: Equatable {
        var appDelegate: AppDelegateStore.State = AppDelegateStore.State()
        var login: LoginFlowCoordinator.State?
        var main: Main.State?

        mutating func set(_ currentState: CurrentState) {
            switch currentState {
            case .login:
                self.login = .init()
                self.main = .none

            case let .main(user):
                self.main = .initialState(user: user)
                self.login = .none
            }
        }

        enum CurrentState {
            case login
            case main(User)
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case appDelegate(AppDelegateStore.Action)
        case login(LoginFlowCoordinator.Action)
        case main(Main.Action)

        case subscribeOnUserChange
        case signOut
        case handlePushRoute(Result<PushRoute, NSError>)
    }

    @Dependency(\.userClient) var userClient
    @Dependency(\.authClient) var authClient
    @Dependency(\.firestoreUsersClient) var firestoreUsersClient
    @Dependency(\.pushNotificationClient) var pushNotificationClient

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \State.appDelegate, action: /Action.appDelegate) {
            AppDelegateStore()
        }

        Reduce { state, action in
            switch action {
            case .appDelegate(.didFinishLaunching):
                if userClient.authUser.value != nil,
                   let user = userClient.firestoreUser.value {
                    state.set(.main(user))
                    return EffectPublisher(value: .subscribeOnUserChange)

                } else {
                    state.set(.login)
                    return .none
                }

            case .login(.delegate(.loginSuccess)):
                if let user = userClient.firestoreUser.value {
                    state.set(.main(user))
                    return EffectPublisher(value: .subscribeOnUserChange)

                } else {
                    return .none
                }

            case .main(.delegate(.logout)):
                return EffectPublisher.concatenate(
                    firestoreUsersClient
                        .updateMe(UserUpdate(fcmToken: ""))
                        .fireAndForget(),
                    EffectPublisher(value: .signOut)
                )

            case let .appDelegate(.userNotificationCenterDelegate(.didReceiveResponse(response, completionHandler))):
                let action = response.actionIdentifier
                if action == UNNotificationDefaultActionIdentifier {
                    return pushNotificationClient
                        .handleDidReceiveResponse(
                            response,
                            completionHandler
                        )
                        .mapError { $0 as NSError }
                        .catchToEffect(Action.handlePushRoute)
                } else {
                    return .none
                }

            case let .handlePushRoute(.success(pushRoute)):
                guard userClient.firestoreUser.value != nil else {
                    return .none
                }
                switch pushRoute {
                case let .openChat(chatsListPrivateItem):
                    let chatState = Chat.State(model: chatsListPrivateItem)
                    state.main?.routes.push(.chat(chatState))
                }
                return .none

            case .handlePushRoute(.failure):
                return .none

            case .subscribeOnUserChange:
                return EffectPublisher.run { subscriber in
                    userClient.firestoreUser
                        .removeDuplicates()
                        .sink { user in
                            guard user == nil else {
                                return
                            }
                            subscriber.send(.signOut)
                        }
                }

            case .signOut:
                state.set(.login)
                authClient.signOut()
                return EffectPublisher.cancel(id: Main.ListenersId())

            case .appDelegate:
                return .none

            case .login:
                return .none

            case .main:
                return .none
            }
        }
        // TODO: Move to IfLetReducer if possible
        .ifLet(
            \State.login,
            action: /Action.login,
            then: { LoginFlowCoordinator() }
        )
        .ifLet(
            \State.main,
            action: /Action.main,
            then: { Main() }
        )
    }

}
