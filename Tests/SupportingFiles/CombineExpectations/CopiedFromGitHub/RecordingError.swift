// Copyright (C) 2019 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// Manually copied from: https://github.com/groue/CombineExpectations
// awaiting possible Carthage support when issue is fix: https://github.com/groue/CombineExpectations/issues/1

import Foundation

/// An error that may be thrown when waiting for publisher expectations.
public enum RecordingError: Error {
    /// Can be thrown when the publisher does not complete in time.
    case notCompleted
    
    /// Can be thrown when waiting for `recorder.single`, when the publisher
    /// does not publish any element.
    case noElements
    
    /// Can be thrown when waiting for `recorder.prefixedOrError`, when the publisher
    /// does not publish enough elements.
    case notEnoughElements
    
    /// Can be thrown when waiting for `recorder.single`, when the publisher
    /// publishes more than one element.
    case moreThanOneElement
    
    // Can be thrown when expecting the publisher to complete with an error, but it completed with the wrong kind of error
    case failedToMapErrorFromFailureToExpectedErrorType(expectedErrorType: Swift.Error.Type, butGotFailure: Swift.Error)

    // Can be thrown when expecting the publisher to complete with an error, but it completed with a finish instead.
    case expectedPublisherToFailButGotFinish(expectedErrorType: Swift.Error.Type)
}

extension RecordingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notCompleted:
            return "RecordingError.notCompleted"
        case .noElements:
            return "RecordingError.noElements"
        case .notEnoughElements:
            return "RecordingError.notEnoughElements"
        case .moreThanOneElement:
            return "RecordingError.moreThanOneElement"
        case .failedToMapErrorFromFailureToExpectedErrorType(let expectedErrorType, let butGotFailure):
            return "RecordingError.failedToMapErrorFromFailureToExpectedErrorType(from: '\(butGotFailure))', to expected type: '\(nameOf(type: expectedErrorType))')"
        case .expectedPublisherToFailButGotFinish(let expectedErrorType):
              return "RecordingError.expectedPublisherToFailButGotFinish(expectedErrorType: '\(nameOf(type: expectedErrorType))')"
        }
    }
}

private func nameOf<T>(type: T) -> String {
    "\(Mirror(reflecting: type).subjectType)"
}
