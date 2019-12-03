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

// TODO replace Starscream with Apple's `URLSessionWebSocketTask` introduced in iOS 13: https://developer.apple.com/documentation/foundation/urlsessionwebSockettask
import Starscream

import Combine
import Entwine

// swiftlint:disable colon opening_brace

public final class WebSocketToNode:
    FullDuplexCommunicationChannel,
    WebSocketDelegate,
    WebSocketPongDelegate
{
    // swiftlint:enable colon opening_brace
    
    // MARK: Primary Properties
    
    /// The Radix Node of the webSocket
    internal let node: Node
    
    /// The pending webSocket to the `node`
    private var socket: WebSocket?

    // MARK: Private Properties
    private let webSocketStatusSubject: CurrentValueSubject<WebSocketStatus, Never>
    
    private var listeners = [ListenerKey: Listener]()
    
    private var cancellables = Set<AnyCancellable>()
    
    // `internal` only for test purposes, otherwise `private`
    internal init(node: Node, webSocketStatusSubject: CurrentValueSubject<WebSocketStatus, Never>) {
        
        webSocketStatusSubject.filter { $0 == .failed }
            .debounce(for: 60, scheduler: RadixSchedulers.mainThreadScheduler)
            .sink(
                receiveCompletion: { _ in webSocketStatusSubject.send(.disconnected) },
                receiveValue: { _ in webSocketStatusSubject.send(.disconnected) }
            ).store(in: &cancellables)
         
        self.webSocketStatusSubject = webSocketStatusSubject
        self.node = node
        
//        webSocketStatusSubject.sink(
//            receiveValue: { Swift.print("verbose: WS status -> `\($0)`") }
//        ).store(in: &cancellables)
    }
    
    deinit {
        closeDisregardingListeners()
    }
}

public extension WebSocketToNode {
    convenience init(node: Node) {
        self.init(node: node, webSocketStatusSubject: .init(.disconnected))
    }
}

public enum WebSocketClosingStrategy: Int, Equatable {
    case ifInUseSkipClosing
    case closeDisregardingIfSocketHasListeners
}

// MARK: Public
public extension WebSocketToNode {
    
    var webSocketStatus: AnyPublisher<WebSocketStatus, Never> {
        webSocketStatusSubject.eraseToAnyPublisher()
    }
    
    @discardableResult
    func close(strategy: WebSocketClosingStrategy = .ifInUseSkipClosing) -> CloseWebSocketResult {
        if strategy == .ifInUseSkipClosing && listeners.count > 0 {
            return .didNotClose(reason: .isInUse)
        }
        closeDisregardingListeners()
        return .closed
    }
    
    @discardableResult
    func connectAndNotifyWhenConnected() -> Future<WebSocketToNode, Never> {
        switch webSocketStatusSubject.value {
        case .disconnected, .failed:
            webSocketStatusSubject.send(.connecting)
            socket = createAndConnectToSocket()
        case .closing, .connecting, .connected: break
        }
        
        return Future<WebSocketToNode, Never> { [weak self] promise in
            guard let self = self else {
                // TODO Combine replace fatalError with error
                fatalError("Self nil, replace this fatalError with an Error")
            }
            self.webSocketStatus.filter { $0.isConnected }
                .first()
                .ignoreOutput()
                .sink { promise(.success(self)) }
                .store(in: &self.cancellables)
        }
    }
}

// MARK: FullDuplexCommunicationChannel
public extension WebSocketToNode {
    
    func sendMessage(_ message: String) {
        guard isConnected else {
            fatalError("Should not send message before we are connected...")
        }
//        Swift.print("verbose: Sending message of length: #\(message.count) chars")
//        Swift.print("verbose: Sending message:\n<\(message)>")
        socket?.write(string: message)
    }
    
    func addListener(_ listener: Listener, forKey key: ListenerKey) -> RemoveListener {
        assert(listeners[key] == nil)
        listeners[key] = listener
        return { [weak self] in
            self?.listeners.removeValue(forKey: key)
        }
    }
}

// MARK: WebSocketDelegate
// It is unfortunate that StarScream decided to spell out `webSocket` like `websocket` in their prefix of their delegate methods.
public extension WebSocketToNode {
    func websocketDidConnect(socket: WebSocketClient) {
        webSocketStatusSubject.send(.connected)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Swift.Error?) {
        Swift.print("debug: Websocket closed")
        guard !isClosing else {
            self.socket = nil
            return webSocketStatusSubject.send(.disconnected)
        }
        if error != nil {
            self.socket = nil
            webSocketStatusSubject.send(.failed)
        } else {
            webSocketStatusSubject.send(.disconnected)
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        listeners.values.forEach { listener in
            listener.send(text)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
//        Swift.print("info: Socket did receive data.")
    }
    
    func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
//        Swift.print("info: Socket got pong")
    }
}

// MARK: - Private

// MARK: Status
private extension WebSocketToNode {
    
    var isDisconnected: Bool {
        return hasStatus(.disconnected)
    }
    
    var isClosing: Bool {
        return hasStatus(.closing)
    }
    
    var isConnected: Bool {
        return hasStatus(.connected)
    }
    
    func hasStatus(_ status: WebSocketStatus) -> Bool {
        webSocketStatusSubject.value == status
    }
}

// MARK: Helpers
private extension WebSocketToNode {

    func closeDisregardingListeners() {
        webSocketStatusSubject.send(.closing)
        socket?.disconnect()
    }
    
    func createAndConnectToSocket() -> WebSocket {
        let newSocket = WebSocket(url: node.webSocketsUrl.url)
        newSocket.delegate = self
        newSocket.connect()
        return newSocket
    }
}
