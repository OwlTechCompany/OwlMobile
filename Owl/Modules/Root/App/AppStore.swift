//
//  AppStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import ComposableArchitecture
import FirebaseAuth
import UserNotifications

struct App {

    // MARK: - State

    struct State: Equatable {
        var appDelegate: AppDelegate.State = AppDelegate.State()
        var login: Login.State?
        var main: Main.State?

        mutating func set(_ currentState: CurrentState) {
            switch currentState {
            case .login:
                self.login = .initialState
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
        case appDelegate(AppDelegate.Action)
        case login(Login.Action)
        case main(Main.Action)

        case setupMain
        case signOut
        case handlePushRoute(Result<PushRoute, NSError>)
    }

    // MARK: - Environment

    struct Environment {
        let firebaseClient: FirebaseClient
        let userClient: UserClient
        let authClient: AuthClient
        let userDefaultsClient: UserDefaultsClient
        let validationClient: ValidationClient
        let firestoreUsersClient: FirestoreUsersClient
        let chatsClient: FirestoreChatsClient
        let storageClient: StorageClient
        let pushNotificationClient: PushNotificationClient

        static var live: Self {
            let userDefaultsClient = UserDefaultsClient.live()
            let userClient = UserClient.live(userDefaults: userDefaultsClient)
            return Self(
                firebaseClient: .live(),
                userClient: userClient,
                authClient: .live(),
                userDefaultsClient: userDefaultsClient,
                validationClient: .live(),
                firestoreUsersClient: .live(userClient: userClient),
                chatsClient: .live(userClient: userClient),
                storageClient: .live(userClient: userClient),
                pushNotificationClient: .live()
            )
        }
    }

    // MARK: - Reducer

    static var reducer = Reducer<State, Action, Environment>.combine(
        AppDelegate.reducer
            .pullback(
                state: \State.appDelegate,
                action: /Action.appDelegate,
                environment: { $0.appDelegate }
            ),

        Login.reducer
            .optional()
            .pullback(
                state: \State.login,
                action: /Action.login,
                environment: { $0.login }
            ),

        Main.reducer
            .optional()
            .pullback(
                state: \State.main,
                action: /Action.main,
                environment: { $0.main }
            ),

        reducerCore
    ).debug()

    static var reducerCore = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .appDelegate(.didFinishLaunching):
            if environment.userClient.authUser.value != nil,
               let user = environment.userClient.firestoreUser.value {
                state.set(.main(user))
                return Effect(value: .setupMain)

            } else {
                state.set(.login)
            }
            return .none

        case .login(.delegate(.loginSuccess)):
            if let user = environment.userClient.firestoreUser.value {
                state.set(.main(user))
                return Effect(value: .setupMain)
            }
            return .none

        case .main(.delegate(.logout)):
            return Effect.concatenate(
                environment.firestoreUsersClient
                    .updateMe(UserUpdate(fcmToken: ""))
                    .fireAndForget(),
                Effect(value: .signOut)
            )

        case let .appDelegate(.userNotificationCenterDelegate(.didReceiveResponse(response, completionHandler))):
            let action = response.actionIdentifier
            if action == UNNotificationDefaultActionIdentifier {
                return environment.pushNotificationClient
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
            guard environment.userClient.firestoreUser.value != nil else {
                return .none
            }
            switch pushRoute {
            case let .openChat(chatsListPrivateItem):
                let chatState = Chat.State(model: chatsListPrivateItem)
                state.main?.routes.push(.chat(chatState))
            }
            return .none

        case let .handlePushRoute(.failure(error)):
            return .none

        case .setupMain:
            return Effect.run { subscriber in
                environment.userClient
                    .firestoreUser
                    .removeDuplicates()
                    .sink { user in
                        if user == nil {
                            subscriber.send(.signOut)
                        }
                    }
            }

        case .signOut:
            state.set(.login)
            environment.authClient.signOut()
            return Effect.cancel(id: MainListenersId())

        case .appDelegate:
            return .none

        case .login:
            return .none

        case .main:
            return .none
        }
    }
}

// MARK: App.Environment + Extensions

extension App.Environment {

    var appDelegate: AppDelegate.Environment {
        AppDelegate.Environment(
            firebaseClient: firebaseClient,
            userClient: userClient,
            authClient: authClient,
            firestoreUserClient: firestoreUsersClient,
            pushNotificationClient: pushNotificationClient
        )
    }

    var login: Login.Environment {
        Login.Environment(
            authClient: authClient,
            userDefaultsClient: userDefaultsClient,
            validationClient: validationClient,
            firestoreUsersClient: firestoreUsersClient,
            storageClient: storageClient,
            pushNotificationClient: pushNotificationClient
        )
    }

    var main: Main.Environment {
        Main.Environment(
            userClient: userClient,
            authClient: authClient,
            chatsClient: chatsClient,
            firestoreUsersClient: firestoreUsersClient,
            storageClient: storageClient
        )
    }

}
