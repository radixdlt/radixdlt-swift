//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
import Combine

public final class ConnectWebSocketEpic: RadixNetworkWebSocketsEpic {
    
    private let webSocketConnector: WebSocketConnector
    private let webSocketCloser: WebSocketCloser
    
    public init(
        webSocketConnector: WebSocketConnector,
        webSocketCloser: WebSocketCloser
    ) {
        self.webSocketConnector = webSocketConnector
        self.webSocketCloser = webSocketCloser
    }
}

public extension ConnectWebSocketEpic {
    convenience init(webSockets webSocketsManager: WebSocketsManager) {
        self.init(
            webSocketConnector: .byWebSockets(manager: webSocketsManager),
            webSocketCloser: .byWebSockets(manager: webSocketsManager)
        )
    }
}

public extension ConnectWebSocketEpic {
    
    func handle(
        actions nodeActionPublisher: AnyPublisher<NodeAction, Never>,
        networkState _: AnyPublisher<RadixNetworkState, Never>
    ) -> AnyPublisher<NodeAction, Never> {
        
        let onConnect: AnyPublisher<NodeAction, Never> = nodeActionPublisher
            .filter { $0 is ConnectWebSocketAction }
            // TODO Combine investigate if we really should use `handleEvents` instead of `flatMap`?
            .handleEvents(
                receiveOutput: { [weak self] connectWebSocketAction in
                    self?.webSocketConnector
                        .newClosedWebSocketConnectionToNode(connectWebSocketAction.node)
                        .connectAndNotifyWhenConnected()
                }
            )
            .dropAll()
            .eraseToAnyPublisher()

        let onClose: AnyPublisher<NodeAction, Never> = nodeActionPublisher
            .filter { $0 is CloseWebSocketAction }
            .handleEvents(
                receiveOutput: { [weak self] closeWebSocketAction in
                    self?.webSocketCloser.closeWebSocketToNode(closeWebSocketAction.node)
                }
            )
            .dropAll()
            .eraseToAnyPublisher()

        return onConnect.merge(with: onClose).eraseToAnyPublisher()
    }
}
