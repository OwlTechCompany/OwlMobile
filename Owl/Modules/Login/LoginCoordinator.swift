//
//  LoginCoordinator.swift
//  Owl
//
//  Created by Denys Danyliuk on 11.04.2022.
//

import TCACoordinators
import ComposableArchitecture
import SwiftUI

enum ScreenState: Equatable {
    case onboarding(OnboardingState)
    case enterPhone(EnterPhoneState)
}

enum ScreenAction: Equatable {
    case onboarding(OnboardingAction)
    case enterPhone(EnterPhoneAction)
}

struct ScreenEnvironment {}

let screenReducer = Reducer<ScreenState, ScreenAction, ScreenEnvironment>.combine(
    onboardingReducer
        .pullback(
            state: /ScreenState.onboarding,
            action: /ScreenAction.onboarding,
            environment: { _ in OnboardingEnvironment() }
        ),
    enterPhoneReducer
        .pullback(
            state: /ScreenState.enterPhone,
            action: /ScreenAction.enterPhone,
            environment: { _ in EnterPhoneEnvironment() }
        )
)

struct LoginCoordinator {

    struct State: Equatable, IndexedRouterState {

        var routes: [Route<ScreenState>]

        static let initialState = State(
            routes: [.root(.onboarding(.init()), embedInNavigationView: true)]
        )
    }

    enum Action: Equatable, IndexedRouterAction {
        case routeAction(Int, action: ScreenAction)
        case updateRoutes([Route<ScreenState>])
    }

    struct Environment { }
}


typealias LoginCoordinatorReducer = Reducer<
    LoginCoordinator.State, LoginCoordinator.Action, LoginCoordinator.Environment
>

let loginCoordinatorReducer: LoginCoordinatorReducer = screenReducer
    .forEachIndexedRoute(environment: { _ in ScreenEnvironment() })
    .withRouteReducer(
        Reducer { state, action, environment in
            switch action {
            case .routeAction(_, .onboarding(.startMessaging)):
                state.routes.push(.enterPhone(.init(phoneNumber: "+380")))

//            case .routeAction(_, .numbersList(.numberSelected(let number))):
//                state.routes.push(.numberDetail(.init(number: number)))
//
//            case .routeAction(_, .numberDetail(.showDouble(let number))):
//                state.routes.presentSheet(.numberDetail(.init(number: number * 2)))
//
//            case .routeAction(_, .numberDetail(.goBackTapped)):
//                state.routes.goBack()
//
//            case .routeAction(_, .numberDetail(.goBackToNumbersList)):
//                return .routeWithDelaysIfUnsupported(state.routes) {
//                    $0.goBackTo(/ScreenState.numbersList)
//                }
//
//            case .routeAction(_, .numberDetail(.goBackToRootTapped)):
//                return .routeWithDelaysIfUnsupported(state.routes) {
//                    $0.goBackToRoot()
//                }

            default:
                break
            }
            return .none
        }
    )


struct LoginCoordinatorView: View {

    let store: Store<LoginCoordinator.State, LoginCoordinator.Action>

    var body: some View {
        TCARouter(store) { screen in
            SwitchStore(screen) {
                CaseLet(
                    state: /ScreenState.onboarding,
                    action: ScreenAction.onboarding,
                    then: OnboardingView.init
                )
                CaseLet(
                    state: /ScreenState.enterPhone,
                    action: ScreenAction.enterPhone,
                    then: EnterPhoneView.init
                )
            }
        }
    }
}
