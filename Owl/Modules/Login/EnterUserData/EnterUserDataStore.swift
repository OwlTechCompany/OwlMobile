//
//  EnterUserDataStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 16.04.2022.
//

import ComposableArchitecture
import UIKit

struct EnterUserData {

    // MARK: - State

    struct State: Equatable {

        @BindableState var selectedImage: UIImage?
        @BindableState var firstName: String = ""
        @BindableState var lastName: String = ""

        var saveButtonEnabled: Bool = false
        var isLoading: Bool = false

        var alert: AlertState<Action>?
        @BindableState var showImagePicker: Bool = false
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case showImagePicker

        case later
        case save

        case uploadPhoto(UIImage)
        case uploadPhotoResult(Result<URL, NSError>)

        case updateUser(_ photoURL: URL?)
        case updateUserResult(Result<Bool, NSError>)

        case dismissAlert

        case next(showSetupPermissions: Bool)

        case binding(BindingAction<State>)
    }

    // MARK: - Environment

    struct Environment {
        let authClient: AuthClient
        let firestoreUsersClient: FirestoreUsersClient
        let storageClient: StorageClient
        let pushNotificationClient: PushNotificationClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .showImagePicker:
            state.showImagePicker = true
            state.isLoading = true
            return .none

        case .binding(\.$showImagePicker):
            state.isLoading = state.showImagePicker
            return .none

        case .binding(\.$firstName):
            state.saveButtonEnabled = !state.firstName.isEmpty
            return .none

        case .later:
            state.isLoading = true
            return environment.pushNotificationClient
                .getNotificationSettings
                .map { $0.authorizationStatus == .authorized }
                .receive(on: DispatchQueue.main)
                .flatMap { Effect(value: .next(showSetupPermissions: !$0)) }
                .eraseToEffect()

        case .save:
            if let image = state.selectedImage {
                return Effect(value: .uploadPhoto(image))
            } else {
                return Effect(value: .updateUser(nil))
            }

        case let .uploadPhoto(image):
            state.isLoading = true
            let compressionQuality = environment.storageClient.compressionQuality
            guard let data = image.jpegData(compressionQuality: compressionQuality) else {
                let error = NSError(domain: "Unable to compress", code: 1)
                return Effect(value: .updateUserResult(.failure(error)))
            }
            return environment.storageClient.setMyPhoto(data)
                .catchToEffect(Action.uploadPhotoResult)

        case let .uploadPhotoResult(.success(url)):
            state.isLoading = false
            return Effect(value: .updateUser(url))

        case let .updateUser(photoURL):
            state.isLoading = true
            let userUpdate = UserUpdate(
                firstName: state.firstName,
                lastName: state.lastName,
                photo: photoURL
            )
            return environment.firestoreUsersClient.updateMe(userUpdate)
                .catchToEffect(Action.updateUserResult)

        case .updateUserResult(.success):
            return environment.pushNotificationClient
                .getNotificationSettings
                .map { $0.authorizationStatus == .authorized }
                .receive(on: DispatchQueue.main)
                .flatMap { Effect(value: .next(showSetupPermissions: !$0)) }
                .eraseToEffect()

        case let .uploadPhotoResult(.failure(error)),
             let .updateUserResult(.failure(error)):
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

        case .next:
            state.isLoading = false
            return .none

        case .binding:
            return .none
        }
    }
    .binding()

}
