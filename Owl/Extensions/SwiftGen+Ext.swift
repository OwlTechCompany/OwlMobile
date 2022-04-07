//
//  SwiftGen+Ext.swift
//  Owl
//
//  Created by Denys Danyliuk on 07.04.2022.
//

import SwiftUI

typealias Colors = Asset.Colors

extension ColorAsset {

    var swiftUIColor: SwiftUI.Color {
        SwiftUI.Color(self.color)
    }
}
