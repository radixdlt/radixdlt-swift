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

import XCTest
@testable import RadixSDK
import Combine


class SubmitAtomEpicTests: NetworkEpicTestCase {
    
    func test_that_atom_submission_without_specifying_originnode_completes_when_atom_gets_stored() {
        let atom = SignedAtom.irrelevant
        let submitAtomActionRequest = SubmitAtomActionRequest(atom: atom, completeOnAtomStoredOnly: true)
        
        doTestSubmitAtomEpic(
            submitAtomAction: submitAtomActionRequest,
            expectedNumberOfOutput: 3,
            
            input: { node, actionsSubject, _ in
                actionsSubject.send(FindANodeResultAction(node: node, request: submitAtomActionRequest))
            },
            
            emulateRadixNetworkController: { outputtedNodeAction, nodeActionsSubject, atomStatusNotificationSubject in
                if let submitAtomActionSend = outputtedNodeAction as? SubmitAtomActionSend {
                    nodeActionsSubject.send(submitAtomActionSend)
                    atomStatusNotificationSubject.send(.stored)
                }
                
                if let submitAtomActionStatus = outputtedNodeAction as? SubmitAtomActionStatus {
                    nodeActionsSubject.send(submitAtomActionStatus)
                }
            },
            
            outputtedSubmitAtomAction: { submitAtomActions in
                XCTAssertType(of: submitAtomActions[0], is: SubmitAtomActionSend.self)
                let submitAtomActionStatus: SubmitAtomActionStatus! = XCTAssertType(of: submitAtomActions[1])
                XCTAssertEqual(submitAtomActionStatus.statusEvent, .stored)
                XCTAssertType(of: submitAtomActions[2], is: SubmitAtomActionCompleted.self)
            }
        )
        
    }
    
    func test_that_atom_submission_when_specifying_origin_node_completes_when_atom_gets_stored() {
        let atom = SignedAtom.irrelevant
        let originNode: Node = makeNode()
        let submitAtomActionSend = SubmitAtomActionSend(atom: atom, node: originNode, completeOnAtomStoredOnly: true)
        
        doTestSubmitAtomEpic(
            submitAtomAction: submitAtomActionSend,
            expectedNumberOfOutput: 2,
            node: originNode,
            
            input: { _, actionsSubject, atomStatusNotificationSubject in
                actionsSubject.send(submitAtomActionSend)
                atomStatusNotificationSubject.send(.stored)
            },
            
            outputtedSubmitAtomAction: { submitAtomActions in
                let submitAtomActionStatus: SubmitAtomActionStatus! = XCTAssertType(of: submitAtomActions[0])
                XCTAssertEqual(submitAtomActionStatus.statusEvent, .stored)
                XCTAssertType(of: submitAtomActions[1], is: SubmitAtomActionCompleted.self)
            }
        )
    }
    
    func test_that_atom_submission_when_specifying_origin_node_and_never_getting_stored_completes_when___isCompletingOnStoreOnly___is___false() {
        let atom = SignedAtom.irrelevant
        let originNode: Node = makeNode(index: 8)
        let submitAtomActionSend = SubmitAtomActionSend(atom: atom, node: originNode, completeOnAtomStoredOnly: false)
        
        let atomStatusNotStoredPendingVerification = AtomStatusEvent.notStored(reason: .init(atomStatus: .pendingDependencyVerification, dataAsJsonString: ""))
        
        doTestSubmitAtomEpic(
            submitAtomAction: submitAtomActionSend,
            expectedNumberOfOutput: 2,
            node: originNode,
            
            input: { _, actionsSubject, atomStatusNotificationSubject in
                actionsSubject.send(submitAtomActionSend)
                
                atomStatusNotificationSubject.send(atomStatusNotStoredPendingVerification)
        },
            
            outputtedSubmitAtomAction: { submitAtomActions in
                let submitAtomActionStatus: SubmitAtomActionStatus! = XCTAssertType(of: submitAtomActions[0])
                XCTAssertEqual(submitAtomActionStatus.statusEvent, atomStatusNotStoredPendingVerification)
                
                XCTAssertType(of: submitAtomActions[1], is: SubmitAtomActionCompleted.self)
        }
        )
    }
    
    func test_timeout() {
        
        let atom = SignedAtom.irrelevant
        let originNode: Node = makeNode()
        let submitAtomActionSend = SubmitAtomActionSend(atom: atom, node: originNode, completeOnAtomStoredOnly: true)
        
        doTestSubmitAtomEpic(
            submitAtomAction: submitAtomActionSend,
            expectedNumberOfOutput: 1,
            node: originNode,
            epicSubmissionMaxDuration: 1,
            
            input: { _, actionsSubject, atomStatusNotificationSubject in
                actionsSubject.send(submitAtomActionSend)
            },
            
            outputtedSubmitAtomAction: { submitAtomActions in
                XCTAssertType(of: submitAtomActions[0], is: SubmitAtomActionCompleted.self)
                let completed = castOrKill(instance: submitAtomActions[0], toType: SubmitAtomActionCompleted.self)
                XCTAssertEqual(completed.result, .failure(.timeout))
            }
        )
    }
    
    func test_that_atom_submission_when_specifying_origin_node_and_never_getting_stored_timesout_when___isCompletingOnStoreOnly___is___true() {
        let atom = SignedAtom.irrelevant
        let originNode: Node = makeNode()
        let submitAtomActionSend = SubmitAtomActionSend(atom: atom, node: originNode, completeOnAtomStoredOnly: true)
        
        let atomStatusNotStoredPendingVerification = AtomStatusEvent.notStored(reason: .init(atomStatus: .pendingDependencyVerification, dataAsJsonString: ""))
        
        doTestSubmitAtomEpic(
            submitAtomAction: submitAtomActionSend,
            expectedNumberOfOutput: 2,
            node: originNode,
            epicSubmissionMaxDuration: 1,
            
            input: { _, actionsSubject, atomStatusNotificationSubject in
                actionsSubject.send(submitAtomActionSend)
                
                atomStatusNotificationSubject.send(atomStatusNotStoredPendingVerification)
        },
            
            outputtedSubmitAtomAction: { submitAtomActions in
                let submitAtomActionStatus: SubmitAtomActionStatus! = XCTAssertType(of: submitAtomActions[0])
                XCTAssertEqual(submitAtomActionStatus.statusEvent, atomStatusNotStoredPendingVerification)
                let completed: SubmitAtomActionCompleted! = XCTAssertType(of: submitAtomActions[1])
                XCTAssertEqual(completed.result, .failure(.timeout))
        }
        )
    }
}

private extension SubmitAtomEpicTests {
    func doTestSubmitAtomEpic(
        submitAtomAction submitAtomActionInitial: SubmitAtomAction,
        expectedNumberOfOutput: Int,
        node specifiedNode: Node? = nil,
        epicSubmissionMaxDuration: Int? = nil,
        
        line: UInt = #line,
        
        input: @escaping (
        _ node: Node,
        _ nodeActionsSubject: PassthroughSubject<NodeAction, Never>,
         _ atomStatusNotificationSubject: PassthroughSubject<AtomStatusEvent, Never>
        ) -> Void,
        
        emulateRadixNetworkController: ((
        _ reactingToOutputtedNodeAction: NodeAction,
        _ nodeActionsSubject: PassthroughSubject<NodeAction, Never>,
        _ atomStatusNotificationSubject: PassthroughSubject<AtomStatusEvent, Never>
        ) -> Void)? = nil,
        
        outputtedSubmitAtomAction: ([SubmitAtomAction]) -> Void
        
    ) {
        
        let node: Node = specifiedNode ?? makeNode()
        
        let webSocketStatusSubject = CurrentValueSubject<WebSocketStatus, Never>(.connected)
        
        let atomStatusNotificationSubject = PassthroughSubject<AtomStatusEvent, Never>()
        
        let atomStatusObserving = AtomStatusObserver(subject: atomStatusNotificationSubject)
        let atomStatusObservationRequesting = AtomStatusObservationRequester()
        let atomStatusObservationCanceller = AtomStatusObservationCanceller()
        let atomSubmitter = AtomSubmitter()
        
        var retainSocket: WebSocketToNode?
        
        var nodeForWhichWebSocketConnectionWasClosed: Node?
        
        let epic = SubmitAtomEpic(
            webSocketConnector: .new(webSocketStatusSubject: webSocketStatusSubject, retain: { retainSocket = $0 }),
            webSocketCloser: .onClose { nodeForWhichWebSocketConnectionWasClosed = $0 },
            makeAtomStatusObserving: { _ in atomStatusObserving },
            makeAtomStatusObservationRequesting: { _ in atomStatusObservationRequesting },
            makeAtomSubmitting: { _ in atomSubmitter },
            makeAtomStatusObservationCanceller: { _ in atomStatusObservationCanceller },
            submissionTimeoutInSeconds: epicSubmissionMaxDuration
        )
        
        XCTAssertEqual(atomStatusObservationRequesting.sendGetAtomStatusNotifications_method_call_count, 0, line: line)
        XCTAssertEqual(atomStatusObservationCanceller.closeAtomStatusNotifications_method_call_count, 0, line: line)
        XCTAssertEqual(atomStatusObserving.observeAtomStatusNotifications_method_call_count, 0, line: line)
        XCTAssertEqual(atomSubmitter.pushAtom_method_call_count, 0, line: line)
        
        XCTAssertNil(retainSocket, line: line)
        XCTAssertNil(nodeForWhichWebSocketConnectionWasClosed, line: line)
        
        let overridingTimeoutIfPresent: TimeInterval = epicSubmissionMaxDuration.map { TimeInterval.init($0 * 2) } ?? TimeInterval.defaultNetworkEpicTimeout
        
        if let epicSubmissionMaxDuration = epicSubmissionMaxDuration {
            XCTAssertEqual(overridingTimeoutIfPresent, TimeInterval(2*epicSubmissionMaxDuration))
        }
        
        doTest(
            epic: epic,
            line: line,
            timeout: overridingTimeoutIfPresent,
            resultingPublisherTransformation: { actionSubject, _, output in
                output
                    .receive(on: RadixSchedulers.mainThreadScheduler)
                    .handleEvents(
                        receiveOutput: {
                            emulateRadixNetworkController?($0, actionSubject, atomStatusNotificationSubject)
                    }
                )
                    .prefix(expectedNumberOfOutput).eraseToAnyPublisher()
        },
            input: { actionSubject, _ in input(node, actionSubject, atomStatusNotificationSubject) },
            
            outputtedNodeActionsHandler: { producedActions in
                let submitAtomActions = producedActions.compactMap { $0 as? SubmitAtomAction }
                XCTAssertEqual(submitAtomActions.count, expectedNumberOfOutput, line: line)
                
                let atom = submitAtomActionInitial.atom.wrappedAtom.wrappedAtom
                
                for submitAtomAction in submitAtomActions {
                    XCTAssertEqual(submitAtomAction.atom.wrappedAtom.wrappedAtom, atom, line: line)
                    XCTAssertEqual(submitAtomAction.node, node, line: line)
                    XCTAssertEqual(submitAtomAction.uuid, submitAtomActionInitial.uuid, line: line)
                }
                
                outputtedSubmitAtomAction(submitAtomActions)
                
                // Assure correctness of "inner" functions/publishers
                XCTAssertEqual(
                    atomStatusObservationCanceller.closeAtomStatusNotifications_method_call_count,
                    1,
                    "Expected method 'closeAtomStatusNotifications' to be called once, but was called: \(atomStatusObservationCanceller.closeAtomStatusNotifications_method_call_count)",
                    line: line
                )
                
                XCTAssertEqual(
                    atomStatusObserving.observeAtomStatusNotifications_method_call_count,
                    1,
                    "Expected method 'observeAtomStatusNotifications' to be called once, but was called: \(atomStatusObserving.observeAtomStatusNotifications_method_call_count)",
                    line: line
                )
                XCTAssertEqual(
                    atomStatusObservationRequesting.sendGetAtomStatusNotifications_method_call_count,
                    1,
                    "Expected method 'sendGetAtomStatusNotifications' to be called once, but was called: \(atomStatusObservationRequesting.sendGetAtomStatusNotifications_method_call_count)",
                    line: line
                )
                
                XCTAssertEqual(
                    atomSubmitter.pushAtom_method_call_count,
                    1,
                    "Expected method 'pushAtom' to be called once, but was called: \(atomSubmitter.pushAtom_method_call_count)",
                    line: line
                )
                
                do {
                    let webSocketToNode = try XCTUnwrap(retainSocket)
                    XCTAssertEqual(webSocketToNode.node, node, line: line)
                    
                    let closedWSNode = try XCTUnwrap(nodeForWhichWebSocketConnectionWasClosed)
                    XCTAssertEqual(closedWSNode, node, line: line)
                } catch { return XCTFail("Expected not nil") }
                
        }
        )
    }
}

final class AtomStatusObserver: AtomStatusObserving {
    
    var observeAtomStatusNotifications_method_call_count = 0
    let atomStatusNotificationSubject: PassthroughSubject<AtomStatusEvent, Never>
    
    init(subject atomStatusNotificationSubject: PassthroughSubject<AtomStatusEvent, Never>) {
        self.atomStatusNotificationSubject = atomStatusNotificationSubject
    }
    
    func observeAtomStatusNotifications(subscriberId: SubscriberId) -> AnyPublisher<AtomStatusEvent, Never> {
        observeAtomStatusNotifications_method_call_count += 1
        return atomStatusNotificationSubject.eraseToAnyPublisher()
    }
}

final class AtomStatusObservationRequester: AtomStatusObservationRequesting {
    
    var sendGetAtomStatusNotifications_method_call_count = 0
    
    func sendGetAtomStatusNotifications(atomIdentifier: AtomIdentifier, subscriberId: SubscriberId) -> AnyPublisher<Never, Never> {
        sendGetAtomStatusNotifications_method_call_count += 1
        return Empty<Never, Never>(completeImmediately: true).eraseToAnyPublisher()
    }
}

final class AtomSubmitter: AtomSubmitting {
    
    var pushAtom_method_call_count = 0
    
    func pushAtom(_ atom: SignedAtom) -> AnyPublisher<Never, SubmitAtomError> {
        pushAtom_method_call_count += 1
        return Empty<Never, SubmitAtomError>(completeImmediately: false).eraseToAnyPublisher()
    }
}

final class AtomStatusObservationCanceller: AtomStatusObservationCancelling {
    
    var closeAtomStatusNotifications_method_call_count = 0
    
    func closeAtomStatusNotifications(subscriberId: SubscriberId) -> AnyPublisher<Never, Never> {
        closeAtomStatusNotifications_method_call_count += 1
        return Empty<Never, Never>(completeImmediately: true).eraseToAnyPublisher()
    }
    
}
