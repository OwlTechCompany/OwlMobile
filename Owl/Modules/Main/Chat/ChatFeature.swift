//
//  ChatFeature.swift
//  Owl
//
//  Created by Anastasia Holovash on 16.04.2022.
//

import ComposableArchitecture
import Firebase
import IdentifiedCollections

struct ChatFeature: Reducer {

    struct State: Equatable {
        var chatID: String
        var companion: User
        var navigation: ChatNavigationFeature.State
        var newMessages: [ChatMessageFeature.State]
        var oldMessages: [ChatMessageFeature.State]
        var isLoading: Bool = false
        var lastDocumentSnapshot: DocumentSnapshot?
        var messages: IdentifiedArrayOf<ChatMessageFeature.State> {
            IdentifiedArrayOf(uniqueElements: newMessages + oldMessages)
        }

        var model: ChatsListPrivateItem
        
        @BindingState var newMessage: String = ""
    }

    enum Action: Equatable, BindableAction {
        case navigation(ChatNavigationFeature.Action)
        case messages(id: ChatMessageFeature.State.ID, action: ChatMessageFeature.Action)

        case binding(BindingAction<State>)
        case onAppear

        case sendMessage
        case sendMessageResult(Result<Bool, NSError>)

        case getMessages(Result<[MessageResponse], NSError>)
        case getLastMessages(Result<GetLastMessagesResponse, NSError>)
        case getPaginatedMessages(Result<GetPaginatedMessagesResponse, NSError>)
    }
    
    @Dependency(\.firestoreChatsClient) var chatsClient

    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Scope(state: \.navigation, action: /Action.navigation) {
            ChatNavigationFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .navigation:
                return .none

            case let .messages(id, .onAppear):
                guard
                    id == state.messages.last?.id && !state.isLoading,
                    let lastDocumentSnapshot = state.lastDocumentSnapshot
                else {
                    return .none
                }

                state.isLoading = true
                return chatsClient.getPaginatedMessages(lastDocumentSnapshot)
                    .catchToEffect(Action.getPaginatedMessages)

            case .binding(\.$newMessage):
                return .none

            case .binding:
                return .none

            case .onAppear:
                chatsClient.openedChatId.send(state.chatID)
                return chatsClient.getLastMessages()
                    .catchToEffect(Action.getLastMessages)
                    .cancellable(id: Main.ListenersId())

            case .sendMessage:
                let newMessage = NewMessage(
                    chatId: state.model.id,
                    message: MessageRequest(
                        messageText: state.newMessage,
                        sentBy: state.model.me.uid
                    )
                )
                state.newMessage = ""
                return chatsClient.sendMessage(newMessage)
                    .catchToEffect(Action.sendMessageResult)

            case .sendMessageResult:
                // Subscribe for updates if it is fist message in chat
                guard !state.oldMessages.isEmpty else {
                    return chatsClient.getLastMessages()
                        .catchToEffect(Action.getLastMessages)
                        .cancellable(id: Main.ListenersId())
                }
                return .none

            case let .getMessages(.success(messages)):
                state.newMessages = messages.map { ChatMessageFeature.State(message: $0, companion: state.companion) }
                return .none

            case let .getMessages(.failure(error)):
                return .none

            case let .getLastMessages(.success(response)):
                state.oldMessages = response.messageResponse.map { ChatMessageFeature.State(message: $0, companion: state.companion) }
                state.lastDocumentSnapshot = response.lastDocumentSnapshot
                return chatsClient.subscribeForNewMessages(response.subscribeForNewMessagesSnapshot)
                    .catchToEffect(Action.getMessages)

            case let .getLastMessages(.failure(error)):
                return .none

            case let .getPaginatedMessages(.success(response)):
                let update = response.messageResponse.map { ChatMessageFeature.State(message: $0, companion: state.companion) }
                state.oldMessages.append(contentsOf: update)
                state.lastDocumentSnapshot = response.lastDocumentSnapshot
                state.isLoading = false
                return .none

            case let .getPaginatedMessages(.failure(error)):
                state.isLoading = false
                return .none
            }
        }
    }

}

extension ChatFeature.State {

    init(model: ChatsListPrivateItem) {
        self.chatID = model.id
        self.companion = model.companion
        self.navigation = .init(model: model)
        self.model = model
        self.newMessages = []
        self.oldMessages = []
    }

}
