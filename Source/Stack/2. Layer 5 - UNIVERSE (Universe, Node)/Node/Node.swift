//
//  Node.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

// swiftlint:disable colon opening_brace

/// Unique network node endpoint.
public struct Node:
    Hashable,
    Equatable,
    CustomDebugStringConvertible
{
    // swiftlint:enable colon opening_brace
    
    public let websocketsUrl: FormattedURL
    
    public let isUsingSSL: Bool
    public let host: Host
    
    public init(host: Host, isUsingSSL: Bool) throws {
        self.host = host
        self.isUsingSSL = isUsingSSL
        self.websocketsUrl = try URLFormatter.format(host: host, protocol: .websockets, useSSL: isUsingSSL)
    }
}

// MARK: - CustomDebugStringConvertible
public extension Node {
    var debugDescription: String {
        return """
        Node(\(websocketsUrl.domain))
        """
    }
}

public extension Node {
    init(domain: String, port: Port, isUsingSSL: Bool) throws {
        let host = try Host(domain: domain, port: port)
        try self.init(host: host, isUsingSSL: isUsingSSL)
    }
    
    init(ensureDomainNotNil maybeDomain: String?, port: Port, isUsingSSL: Bool) throws {
        guard let domain = maybeDomain else { throw Error.domainCannotBeNil }
        try self.init(domain: domain, port: port, isUsingSSL: isUsingSSL)
    }
    
    enum Error: Swift.Error, Equatable {
        case domainCannotBeNil
    }
}