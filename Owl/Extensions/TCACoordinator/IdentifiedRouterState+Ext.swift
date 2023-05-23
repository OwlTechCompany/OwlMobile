//
//  IdentifiedRouterState+Ext.swift
//  Owl
//
//  Created by Denys Danyliuk on 12.04.2022.
//

//import TCACoordinators
//
//extension IdentifiedRouterState {
//
//    func subState<R: Routable, T>(routePath: R.Type) -> T?
//    where R.RouteState == T, R.ScreenProvider == Screen, Screen.ID == R.ID {
//        if let screenProviderState = routes[id: R.id]?.screen {
//            let casePath = R.statePath
//            return casePath.extract(from: screenProviderState)
//        } else {
//            return nil
//        }
//    }
//}
