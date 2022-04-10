//
//  OnboardingView.swift
//  Owl
//
//  Created by Denys Danyliuk on 08.04.2022.
//

import SwiftUI
import ComposableArchitecture

//// MARK: - LoginState + ViewState
//
//private extension LoginState {
//    var view: OnboardingView.ViewState {
//        get {
//            OnboardingView.ViewState(
//                route: (/LoginState.Route.enterPhone).extract(from: route)
//            )
//        }
//        set {
//            phoneNumber = newValue.phoneNumber
//        }
//    }
//}
//
//// MARK: - LoginAction + ViewAction
//
//private extension LoginAction {
//    static func view(_ viewAction: OnboardingView.ViewAction) -> Self {
//        switch viewAction {
//        case let .setRoute(route):
//            return .setRoute(.enterPhone(route))
//
//        case .sendPhoneNumber:
//            return .sendPhoneNumber
//        }
//    }
//}

// MARK: - View

struct OnboardingView: View {

    // MARK: - ViewState
//
//    struct ViewState: Equatable {
//        var route: Route?
//    }
//
//    // MARK: - ViewAction
//
//    enum ViewAction: Equatable, BindableAction {
//        case setRoute(Route?)
//    }

    // MARK: - Route

    enum Route: Equatable {
        case enterPhone(EnterPhoneView.Route?)
    }

    // MARK: - Properties

    var store: Store<LoginState, LoginAction>

    var body: some View {
        WithViewStore(store) { viewStore in
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

//                NavigationLink(
//                    isActive: viewStore.binding(get: \.route, send: LoginAction.setRoute).isPresent(/Route.enterPhone),
//                    destination: { EnterPhoneView(store: store) },
//                    label: { Text("Link") }
//                )
                NavigationLink(
                    unwrapping: viewStore.binding(get: \.route, send: LoginAction.setRoute),
                    case: /LoginState.Route.enterPhone,
                    destination: { _ in
                        EnterPhoneView(store: store)
                            .navigationBarTitle("EnterPhoneView")
                    }, onNavigate: { _ in

                    }, label: {
                        Button {
                            viewStore.send(.setRoute(.enterPhone(nil)))
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
//            .sheet(isPresented: viewStore.binding(get: \.route, send: LoginAction.setRoute).isPresent(/Route.enterPhone), content: {
//                NavigationView {
//                    EnterPhoneView(store: store)
//                        .navigationBarTitle("Test")
//                }
//            })
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
