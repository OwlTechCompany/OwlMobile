//
//  NewPrivateChatView.swift
//  Owl
//
//  Created by Denys Danyliuk on 17.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct NewPrivateChatView: View {
    
    let store: StoreOf<NewPrivateChatFeature>
    // TODO: Maybe use ViewState
    @ObservedObject private var viewStore: ViewStoreOf<NewPrivateChatFeature>
    
    init(store: StoreOf<NewPrivateChatFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack {
            SearchBar(
                searchText: viewStore.binding(\.$searchText),
                placeholder: "Enter phone number",
                onSubmit: {
                    viewStore.send(.search)
                }
            )
            
            List {
                ForEachStore(
                    store.scope(
                        state: \NewPrivateChatFeature.State.cells,
                        action: NewPrivateChatFeature.Action.cells(id:action:)
                    ),
                    content: NewPrivateChatCellView.init(store:)
                )
            }
            .overlay(
                viewStore.cells.isEmpty
                ? emptyView
                    .animation(.easeOut, value: viewStore.cells.isEmpty)
                : nil
            )
            .animation(.default, value: viewStore.cells)
        }
        .disabled(viewStore.isLoading)
        .overlay(
            viewStore.isLoading
            ? Loader()
            : nil
        )
        .alert(
            self.store.scope(state: \.alert),
            dismiss: .dismissAlert
        )
        .background(
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("New private chat")
    }
    
    @ViewBuilder
    var emptyView: some View {
        switch viewStore.emptyViewState {
        case .onAppear:
            VStack(spacing: 20) {
                Image(systemName: "person.3")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Asset.Colors.accentColor.swiftUIColor)
                    .font(.system(size: 50, weight: .regular, design: .monospaced))
                
                Text("For start messaging enter phone number")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .lineSpacing(10)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
        case .notFound:
            VStack(spacing: 20) {
                Image(systemName: "person.fill.xmark")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle( Asset.Colors.accentColor.swiftUIColor)
                    .opacity(0.8)
                    .font(.system(size: 60, weight: .regular, design: .monospaced))
                
                Text("There is no users with this phone number")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .lineSpacing(10)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
        case .hidden:
            EmptyView()
        }
    }
}

// MARK: - Preview

struct NewPrivateChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewPrivateChatView(store: Store(
                initialState: NewPrivateChatFeature.State(),
                reducer: NewPrivateChatFeature()
            ))
        }
    }
}
