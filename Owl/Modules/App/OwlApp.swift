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

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            AppView(store: self.appDelegate.store)
        }
    }
}
