/*
 * Copyright 2016 Robert Cottrell
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import ReactiveStreams

public extension Publisher {
    @warn_unused_result(message: "Unused processor")
    public func map<Element>(transform: (PublishType) throws -> Element) -> AnyPublisher<Element> {
        let map = MapProcessor(transform: transform)
        subscribe(subscriber: map)

        return map.asPublisher()
    }
}

// MARK: - Processor

internal final class MapProcessor<ElementIn, ElementOut> : Processor {
    internal typealias SubscribeType = ElementIn
    internal typealias PublishType = ElementOut
    
    private let transform: (SubscribeType) throws -> PublishType
    
    private var done = false
    private var upstreamSubscription: Subscription?
    private var subscriber: AnySubscriber<PublishType>?
    private var subscriberSubscription: Subscription?
    
    internal init(transform: (SubscribeType) throws -> PublishType) {
        self.transform = transform
    }
    
    /// If the processor has already been subscribed to an upstream publisher
    /// then cancel the new subscription. Otherwise, save a reference to the
    /// subscription but do not request any elements yet. The processor will
    /// forward it's downstream subscriber's requests later.
    internal func onSubscribe(subscription: Subscription) {
        guard self.upstreamSubscription == nil else {
            subscription.cancel()
            return
        }
        self.upstreamSubscription = subscription
    }
    
    internal func onNext(element: SubscribeType) {
        guard let subscriber = subscriber else {
            return
        }
        
        do {
            let transformed = try transform(element)
            subscriber.onNext(element: transformed)            
        } catch {
            subscriber.onError(error: error)
        }
    }
    
    internal func onError(error: ErrorProtocol) {
        defer {
            upstreamSubscription = nil
            done = true
        }

        guard let subscriber = subscriber else {
            return
        }
        subscriber.onError(error: error)
        //self.subscriber = nil
    }
    
    internal func onComplete() {
        defer {
            upstreamSubscription = nil
            done = true
        }
        
        guard let subscriber = subscriber else {
            return
        }
        subscriber.onComplete()
        //self.subscriber = nil
    }
    
    internal func subscribe<S : Subscriber where S.SubscribeType == PublishType>(subscriber: S) {
        guard self.subscriber == nil else {
            subscriber.onError(error: MapError.OnlyOneSubscriberAllowed)
            return
        }
        self.subscriber = subscriber.asSubscriber()
        
        let subscription = DelegatingSubscription(delegate: self)
        self.subscriberSubscription = subscription
        
        subscriber.onSubscribe(subscription: subscription)
    }
}

// MARK: - Subscription handlers.

extension MapProcessor : DelegatingSubscriptionDelegate {
    internal func subscription(_ subscription: Subscription, didRequestCount count: Int) {
        upstreamSubscription?.request(count: count)
    }
    
    internal func subscriptionDidCancel(_ subscription: Subscription) {
        upstreamSubscription?.cancel()
    }
}

// MARK: - Errors

public enum MapError : ErrorProtocol {
    case OnlyOneSubscriberAllowed
}