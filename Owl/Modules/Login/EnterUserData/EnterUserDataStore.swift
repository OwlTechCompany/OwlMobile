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

        case binding(BindingAction<State>)
    }

    // MARK: - Environment

    struct Environment {
        let authClient: AuthClient
        let firestoreUsersClient: FirestoreUsersClient
        let storageClient: StorageClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .showImagePicker:
            state.showImagePicker = true
            return .none

        case .binding(\.$firstName):
            state.saveButtonEnabled = !state.firstName.isEmpty
            return .none

        case .later:
            return .none

        case .save:
            if let image = state.selectedImage {
                return Effect(value: .uploadPhoto(image))
            } else {
                return Effect(value: .updateUser(nil))
            }

        case let .uploadPhoto(image):
            state.isLoading = true
            guard let data = image.jpegData(compressionQuality: 0.7) else {
                let error = NSError(domain: "Unable to compress", code: 1)
                return Effect(value: .updateUserResult(.failure(error)))
            }
            return environment.storageClient.setMyPhoto(data)
                .catchToEffect(Action.uploadPhotoResult)

        case let .uploadPhotoResult(.success(url)):
            state.isLoading = false
            return Effect(value: .updateUser(url))

        case let .updateUser(photoURL):
            guard let authUser = environment.authClient.currentUser() else {
                return .none
            }
            state.isLoading = true
            let userUpdate = UserUpdate(
                uid: authUser.uid,
                firstName: state.firstName,
                lastName: state.lastName,
                photo: photoURL
            )
            return environment.firestoreUsersClient.updateUser(userUpdate)
                .catchToEffect(Action.updateUserResult)

        case .updateUserResult(.success):
            state.isLoading = false
            return .none

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

        case .binding:
            return .none
        }
    }
    .binding()

}
