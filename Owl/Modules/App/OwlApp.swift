//
//  OwlApp.swift
//  Owl
//
//  Created by Anastasia Holovash on 07.04.2022.
//

import SwiftUI
import ComposableArchitecture

@main
struct OwlApp: App {

    static let store = Store<AppState, AppAction>(
        initialState: AppState(),
        reducer: appReducer,
        environment: .live
    )

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            AppView(store: OwlApp.store)
        }
    }
}
