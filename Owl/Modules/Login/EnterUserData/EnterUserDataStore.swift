//
//  EnterUserDataStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 16.04.2022.
//

import ComposableArchitecture
import UIKit

struct EnterUserData: ReducerProtocol {

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

        case checkNotificationService
        case next(needSetupPermissions: Bool)

        case binding(BindingAction<State>)
    }

    @Dependency(\.authClient) var authClient
    @Dependency(\.firestoreUsersClient) var firestoreUsersClient
    @Dependency(\.storageClient) var storageClient
    @Dependency(\.pushNotificationClient) var pushNotificationClient

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
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
                return Effect(value: .checkNotificationService)

            case .save:
                if let image = state.selectedImage {
                    return Effect(value: .uploadPhoto(image))
                } else {
                    return Effect(value: .updateUser(nil))
                }

            case let .uploadPhoto(image):
                state.isLoading = true
                let compressionQuality = storageClient.compressionQuality
                guard let data = image.jpegData(compressionQuality: compressionQuality) else {
                    let error = NSError(domain: "Unable to compress", code: 1)
                    return Effect(value: .updateUserResult(.failure(error)))
                }
                return storageClient.setMyPhoto(data)
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
                return firestoreUsersClient.updateMe(userUpdate)
                    .catchToEffect(Action.updateUserResult)

            case .updateUserResult(.success):
                return Effect(value: .checkNotificationService)

            case let .uploadPhotoResult(.failure(error)),
                let .updateUserResult(.failure(error)):
                state.isLoading = false
                state.alert = AlertState(
                    title: TextState("Error"),
                    message: TextState("\(error.localizedDescription)"),
                    dismissButton: .default(TextState("Ok"))
                )
                return .none

            case .checkNotificationService:
                return pushNotificationClient
                    .getNotificationSettings
                    .receive(on: DispatchQueue.main)
                    .flatMap { settings -> Effect<Action, Never> in
                        switch settings.authorizationStatus {
                        case .notDetermined:
                            return Effect(value: .next(needSetupPermissions: true))

                        default:
                            return Effect.concatenate(
                                pushNotificationClient
                                    .register()
                                    .fireAndForget(),

                                Effect(value: .next(needSetupPermissions: false))
                            )
                        }
                    }
                    .eraseToEffect()

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
    }

}
