//
//  LoginFlowCoordinator + Path.swift
//  Owl
//
//  Created by Denys Danyliuk on 12.04.2022.
//

import ComposableArchitecture
import TCACoordinators

extension LoginFlowCoordinator {

    struct Path {}

}

extension LoginFlowCoordinator.Path: Reducer {
    
    enum State: Equatable {
        case enterPhone(EnterPhoneFeature.State)
        case enterCode(EnterCodeFeature.State)
        case enterUserData(EnterUserDataFeature.State)
        case setupPermissions(SetupPermissionsFeature.State)
    }
    
    enum Action: Equatable {
        case enterPhone(EnterPhoneFeature.Action)
        case enterCode(EnterCodeFeature.Action)
        case enterUserData(EnterUserDataFeature.Action)
        case setupPermissions(SetupPermissionsFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: /State.enterPhone, action: /Action.enterPhone) {
            EnterPhoneFeature()
        }
        
        Scope(state: /State.enterCode, action: /Action.enterCode) {
            EnterCodeFeature()
        }
        
        Scope(state: /State.enterUserData, action: /Action.enterUserData) {
            EnterUserDataFeature()
        }
        
        Scope(state: /State.setupPermissions, action: /Action.setupPermissions) {
            SetupPermissionsFeature()
        }
    }
    
}
