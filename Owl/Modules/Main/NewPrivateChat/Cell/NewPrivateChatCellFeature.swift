//
//  NewPrivateChatCellFeature.swift
//  Owl
//
//  Created by Denys Danyliuk on 17.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct NewPrivateChatCellFeature: Reducer {
    
    struct State: Equatable, Identifiable {
        let id: String
        let image: UIImage
        let fullName: String
        let phoneNumber: String
    }
    
    enum Action: Equatable {
        case open
    }
    
    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
    
}

// MARK: - State Extension

extension NewPrivateChatCellFeature.State {
    
    init(model: User) {
        id = model.uid
        image = Asset.Images.owlWithPadding.image
        fullName = model.fullName
        phoneNumber = model.phoneNumber ?? ""
    }
    
}
