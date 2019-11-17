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

public struct DataFetcher {
    
    public typealias DataFromRequest = (URLRequest) -> AnyPublisher<Data, HTTPClientError.NetworkingError>
    let dataFromRequest: DataFromRequest
}

public extension DataFetcher {
    
    static func urlResponse(_ dataAndUrlResponsePublisher: @escaping (URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError>) -> Self {
        Self { request in
            dataAndUrlResponsePublisher(request)
                .mapError { HTTPClientError.NetworkingError.urlError($0) }
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw HTTPClientError.NetworkingError.invalidServerResponse(response)
                    }
                    guard case 200...299 = httpResponse.statusCode else {
                        throw HTTPClientError.NetworkingError.invalidServerStatusCode(httpResponse.statusCode)
                    }
                    return data
            }
            .mapError { castOrKill(instance: $0, toType: HTTPClientError.NetworkingError.self) }
            .eraseToAnyPublisher()
            
        }
    }
    
    static func usingURLSession(_ urlSession: URLSession = .shared) -> Self {
        return Self.urlResponse { urlSession.dataTaskPublisher(for: $0).eraseToAnyPublisher() }
    }
}
