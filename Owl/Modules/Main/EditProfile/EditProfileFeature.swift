//
//  EditProfileFeature.swift
//  Owl
//
//  Created by Denys Danyliuk on 27.04.2022.
//

import ComposableArchitecture
import UIKit

struct EditProfileFeature: Reducer {
    
    struct State: Equatable {
        @BindingState var selectedImage: UIImage?
        @BindingState var firstName: String = ""
        @BindingState var lastName: String = ""
        
        var isLoading: Bool = false
        var photo: Photo
        
        var alert: AlertState<Action>?
        @BindingState var showImagePicker: Bool = false
        
        init(user: User) {
            firstName = user.firstName ?? ""
            lastName = user.lastName ?? ""
            photo = user.photo
        }
    }
    
    enum Action: Equatable, BindableAction {
        case showImagePicker
        
        case save
        
        case uploadPhoto(UIImage)
        case uploadPhotoResult(Result<URL, NSError>)
        
        case updateUser(_ photoURL: URL?)
        case updateUserResult(Result<Bool, NSError>)
        
        case dismissAlert
        
        case binding(BindingAction<State>)
    }
    
    @Dependency(\.firestoreUsersClient) var firestoreUsersClient
    @Dependency(\.storageClient) var storageClient
    
    var body: some ReducerOf<Self> {
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
                
            case .save:
                if let image = state.selectedImage {
                    return EffectPublisher(value: .uploadPhoto(image))
                } else {
                    return EffectPublisher(value: .updateUser(nil))
                }
                
            case let .uploadPhoto(image):
                state.isLoading = true
                let compressionQuality = storageClient.compressionQuality
                guard let data = image.jpegData(compressionQuality: compressionQuality) else {
                    let error = NSError(domain: "Unable to compress", code: 1)
                    return EffectPublisher(value: .updateUserResult(.failure(error)))
                }
                return storageClient.setMyPhoto(data)
                    .catchToEffect(Action.uploadPhotoResult)
                
            case let .uploadPhotoResult(.success(url)):
                state.isLoading = false
                return EffectPublisher(value: .updateUser(url))
                
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
                state.isLoading = false
                return .none
                
            case let .uploadPhotoResult(.failure(error)),
                let .updateUserResult(.failure(error)):
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
