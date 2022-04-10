//
//  RoutingExtensions.swift
//  Owl
//
//  Created by Denys Danyliuk on 10.04.2022.
//

import ComposableArchitecture
import SwiftUI

public protocol RoutableState {
    typealias Action = RoutingAction<Route>
    associatedtype Route: Hashable
    var currentRoute: Route { get set }
}

extension Reducer where State: Hashable, Action == RoutingAction<State>{
    public static func router() -> Reducer {
        Reducer { currentRoute, action, environment in
            switch action {
            case let .navigate(to: newRoute):
                currentRoute = newRoute
                return .none
            }
        }
    }
}

extension Reducer {
    public func routing<Route: Hashable>(
        state toLocalState: WritableKeyPath<State, Route>,
        action toLocalAction: CasePath<Action, RoutingAction<Route>>
    ) -> Reducer {
        .combine(
            self,
            Reducer<Route, RoutingAction<Route>, Void>.router()
                .pullback(
                    state: toLocalState,
                    action: toLocalAction,
                    environment: { _ in }
                )
        )
    }
}

extension Reducer where State: RoutableState {
    public func routing(
        action: CasePath<Action, State.Action>
    ) -> Reducer {
        return routing(state: \.currentRoute, action: action)
    }
}


extension Reducer where State: RoutableState, Action: RoutableAction, State.Route == Action.Route {
    public func routing() -> Reducer {
        return routing(
            state: \State.currentRoute,
            action: /Action.router
        )
    }
}

public protocol RoutableAction {
    associatedtype Route: Hashable
    static func router(_: RoutingAction<Route>) -> Self
}

extension RoutableAction {
    public static func navigate(to route: Route) -> Self {
        return .router(.navigate(to: route))
    }
}

public enum RoutingAction<Route: Hashable>: Equatable {
    case navigate(to: Route)
    public var route: Route {
        switch self {
        case let .navigate(to: route):
            return route
        }
    }
}

extension RoutingAction where Route: ExpressibleByNilLiteral {
    public static var dismiss: RoutingAction { .navigate(to: nil) }
}

extension NavigationLink {

    public init<
        Store: ViewStore<State, Action>,
        State: RoutableState,
        Action: RoutableAction,
        Case,
        WrappedDestination
    >(
        with viewStore: Store,
        case casePath: CasePath<State.Route, Case>,
        @ViewBuilder destination: @escaping (Binding<Case>) -> WrappedDestination,
        @ViewBuilder label: @escaping () -> Label
    ) where
        Destination == WrappedDestination?,
        State.Route: ExpressibleByNilLiteral,
        State.Route == Action.Route {

        // TODO: Check if onNavigate needed
        let routeBinding: Binding<State.Route?> = viewStore.binding(
            get: { $0.currentRoute },
            send: { Action.router(.navigate(to: $0 ?? nil)) }
        )
        self.init(
            unwrapping: routeBinding.case(casePath),
            destination: destination,
            onNavigate: { _ in },
            label: label
        )
    }

}
