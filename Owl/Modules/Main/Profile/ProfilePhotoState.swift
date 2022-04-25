//
//  ProfilePhotoState.swift
//  Owl
//
//  Created by Denys Danyliuk on 25.04.2022.
//

import UIKit

enum ProfilePhotoState {
    case big
    case small

    var height: CGFloat {
        switch self {
        case .big:
            return screen.width
        case .small:
            return 100
        }
    }

    var width: CGFloat {
        switch self {
        case .big:
            return screen.width
        case .small:
            return 100
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .big:
            return 0
        case .small:
            return height / 2
        }
    }

    var isScaled: Bool {
        return self == .big
    }

    mutating func toggle() {
        switch self {
        case .big:
            self = .small
        case .small:
            self = .big
        }
    }
}
