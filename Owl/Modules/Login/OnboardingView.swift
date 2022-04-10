//
//  OnboardingView.swift
//  Owl
//
//  Created by Denys Danyliuk on 08.04.2022.
//

import SwiftUI
import ComposableArchitecture

// MARK: - LoginState + ViewState

private extension LoginState {
    var view: OnboardingView.ViewState {
        get {
            OnboardingView.ViewState(currentRoute: currentRoute)
        }
        set {
            currentRoute = newValue.currentRoute
        }
    }
}

// MARK: - LoginAction + ViewAction

private extension LoginAction {
    static func view(_ viewAction: OnboardingView.ViewAction) -> Self {
        switch viewAction {
        case let .router(route):
            return .router(route)
        }
    }
}

// MARK: - View

struct OnboardingView: View {

    // MARK: - ViewState

    struct ViewState: Equatable, RoutableState {
        var currentRoute: Route?
    }

    // MARK: - ViewAction

    enum ViewAction: Equatable, RoutableAction {
        case router(RoutingAction<Route?>)
    }

    // MARK: - Route

    enum Route: Equatable, Hashable {
        case enterPhone(EnterPhoneView.Route?)
    }

    // MARK: - Properties

    var store: Store<LoginState, LoginAction>

    var body: some View {
        WithViewStore(store.scope(state: \LoginState.view, action: LoginAction.view)) { viewStore in
            VStack {
                VStack(spacing: 42) {
                    Rectangle()
                        .foregroundColor(.blue.opacity(0.2))
                        .frame(height: 270)
                        .cornerRadius(5)

                    Text("Connect easily with your family and friends over countries")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                }
                .padding()

                Spacer()

                NavigationLink(
                    with: viewStore,
                    case: /Route.enterPhone,
                    destination: { _ in
                        EnterPhoneView(store: store)
                            .navigationBarTitle("EnterPhoneView")
                    },
                    label: {
                        Button {
                            viewStore.send(.navigate(to: .enterPhone(nil)))
                        } label: {
                            Text("Start Messaging")
                                .font(.headline)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(6)
                        }
                    }
                )
            }
            .padding(20)
        }

    }
}

// MARK: - Preview

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(store: Store(
            initialState: LoginState(),
            reducer: loginReducer,
            environment: AppEnvironment.live.login
        ))
    }
}
