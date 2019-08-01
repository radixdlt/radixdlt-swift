//
//  RPCResposeResultConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol PotentiallyRequestIdentifiable {
    var requestIdIfPresent: String? { get }
}

public extension PotentiallyRequestIdentifiable {
    var requestIdIfPresent: String? { return nil }
}

public protocol BaseRPCResposeResult {}

public protocol RPCResposeResultConvertible: Decodable, BaseRPCResposeResult {
    associatedtype Model: Decodable
    var model: Model { get }
}