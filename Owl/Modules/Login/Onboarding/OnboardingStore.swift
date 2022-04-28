//
//  OnboardingStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import ComposableArchitecture

struct Onboarding {

    // MARK: - State

    struct State: Equatable { }

    // MARK: - Action

    enum Action: Equatable {
        case startTapped
        case registerForRemoteNotificationsResult(Result<Bool, NSError>)
        case startMessaging
    }

    // MARK: - Environment

    struct Environment {
        var pushNotificationClient: PushNotificationClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, environment in
        switch action {
        case .startTapped:
            return environment.pushNotificationClient
                .registerForRemoteNotifications([.alert, .sound, .badge])
                .receive(on: DispatchQueue.main)
                .catchToEffect(Action.registerForRemoteNotificationsResult)

        case let .registerForRemoteNotificationsResult(.success(result)):
            print(result)
            return Effect(value: .startMessaging)

        case .registerForRemoteNotificationsResult(.failure):
            print("ERROR")
            return .none

        case .startMessaging:
            return .none
        }
    }
    
}
