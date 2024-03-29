//
//  MainFlowCoordinator+Path.swift
//  Owl
//
//  Created by Anastasia Holovash on 15.04.2022.
//

import ComposableArchitecture

extension MainFlowCoordinator {

    struct Path { }
    
}

extension MainFlowCoordinator.Path: ReducerProtocol {
    
    enum State: Equatable {
        case chat(ChatFeature.State)
        case profile(ProfileFeature.State)
        case editProfile(EditProfileFeature.State)
    }
    
    enum Action: Equatable {
        case chat(ChatFeature.Action)
        case profile(ProfileFeature.Action)
        case editProfile(EditProfileFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: /State.chat, action: /Action.chat) {
            ChatFeature()
        }
        
        Scope(state: /State.profile, action: /Action.profile) {
            ProfileFeature()
        }
        
        Scope(state: /State.editProfile, action: /Action.editProfile) {
            EditProfileFeature()
        }
    }

}
