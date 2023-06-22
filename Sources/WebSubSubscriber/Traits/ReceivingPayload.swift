//
//  ReceivingPayload.swift
//
//  Copyright (c) 2023 WebSubKit Contributors
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Vapor


public protocol ReceivingPayload {
    
    func receiving(_ payload: Request, from subscription: SubscriptionModel) async throws -> Response
    
    func payload(_ payload: Request, from subscription: SubscriptionModel) async throws -> Response
    
}


public extension ReceivingPayload {
    
    func receiving(_ payload: Request, from subscription: SubscriptionModel) async throws -> Response {
        guard let parsed = self.parseTopicHub(from: payload) else {
            return Response(status: .notFound)
        }
        payload.logger.debug(
            """
            Payload      -> topic: \(parsed.topic)
            Payload      -> hub  : \(parsed.hub)
            Subscription -> topic: \(subscription.topic)
            Subscription -> hub  : \(subscription.hub)
            """
        )
        if !(parsed.topic == subscription.topic && parsed.hub == subscription.hub) {
            return Response(status: .notFound)
        }
        return try await self.payload(payload, from: subscription)
    }
    
}


fileprivate extension ReceivingPayload {
    
    func parseTopicHub(from payload: Request) -> (topic: String, hub: String)? {
        return payload.headers.extractWebSubLinks() ?? payload.body.string?.extractWebSubLinks()
    }
    
}
