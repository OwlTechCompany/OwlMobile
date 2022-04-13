//
//  OwlApp.swift
//  Owl
//
//  Created by Anastasia Holovash on 07.04.2022.
//

import SwiftUI
import ComposableArchitecture

@main
struct OwlApp: SwiftUI.App {

    static let store = Store<App.State, App.Action>(
        initialState: App.State(),
        reducer: App.reducer,
        environment: .live
    )

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            AppView(store: OwlApp.store)
        }
    }
}
