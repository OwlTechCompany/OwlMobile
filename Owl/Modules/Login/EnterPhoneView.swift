//
//  EnterPhoneView.swift
//  Owl
//
//  Created by Anastasia Holovash on 07.04.2022.
//

import SwiftUI
import ComposableArchitecture

// MARK: - LoginState + ViewState

private extension LoginState {
    var view: EnterPhoneView.ViewState {
        get {
            EnterPhoneView.ViewState(
                phoneNumber: phoneNumber,
                currentRoute: (/OnboardingView.Route.enterPhone).extract(from: currentRoute)
            )
        }
        set {
            phoneNumber = newValue.phoneNumber
            currentRoute = (/OnboardingView.Route.enterPhone).embed(newValue.currentRoute)
        }
    }
}

// MARK: - LoginAction + ViewAction

private extension LoginAction {
    static func view(_ viewAction: EnterPhoneView.ViewAction) -> Self {
        switch viewAction {
        case let .binding(action):
            return .binding(action.pullback(\.view))

        case let .router(action):
            return .navigate(to: .enterPhone(action.route))

        case .sendPhoneNumber:
            return .sendPhoneNumber
        }
    }
}

// MARK: - View

struct EnterPhoneView: View {

    // MARK: - ViewState

    struct ViewState: Equatable, RoutableState {
        @BindableState var phoneNumber: String
        var currentRoute: Route?
    }

    // MARK: - ViewAction

    enum ViewAction: Equatable, BindableAction, RoutableAction {
        case sendPhoneNumber
        case binding(BindingAction<ViewState>)
        case router(RoutingAction<Route?>)
    }

    enum Route: Equatable, Hashable {
        case enterCode
    }

    // MARK: - Properties

    var store: Store<LoginState, LoginAction>

    var body: some View {
        return WithViewStore(store.scope(state: \LoginState.view, action: LoginAction.view)) { viewStore in
            VStack(spacing: 16) {
                TextField("Phone number", text: viewStore.binding(\.$phoneNumber))
                    .textFieldStyle(PlainTextFieldStyle())

                NavigationLink(
                    with: viewStore,
                    case: /Route.enterCode,
                    destination: { _ in
                        Text("Enter code")
                            .background(Color.orange)
                            .navigationBarTitle("Enter code")
                            .zIndex(100)
                    },
                    label: {
                        Button(
                            action: { viewStore.send(.sendPhoneNumber) },
                            label: { Text("Next") }
                        )
                    }
                )
            }
            .padding()
        }
    }
}

// MARK: - Preview

struct EnterPhoneNumber_Previews: PreviewProvider {
    static var previews: some View {
        EnterPhoneView(store: Store(
            initialState: LoginState(),
            reducer: loginReducer,
            environment: AppEnvironment.live.login
        ))
    }
}
