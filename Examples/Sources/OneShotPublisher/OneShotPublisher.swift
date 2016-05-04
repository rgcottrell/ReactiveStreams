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

// MARK: - Errors

/// Possible error conditions.
public enum Error: ErrorProtocol {
    case OnlyOneSubscriberAllowed
}

// MARK: - Publisher

/// A simple `Publisher` that only issues, when requested, a single element
/// a single `Subscriber`.
public final class OneShotPublisher<Element> : Publisher {
    /// The type of element signaled.
    public typealias PublishType = Element
        
    /// The element to signal the subscriber.
    private let element: PublishType
    
    /// The queue on which the subscriber will be signaled.
    private let queue = dispatch_queue_create("OneShotPublisher.Queue", DISPATCH_QUEUE_SERIAL)
    
    /// Lock to synchronize access to internal state.
    private let lock = NSLock()
    
    /// True after a subscriber has subscribed/
    private var subscribed = false
    
    public init(element: PublishType) {
        self.element = element
    }
    
    public func subscribe<S: Subscriber where S.SubscribeType == PublishType>(subscriber: S) {
        lock.lock(); defer { lock.unlock() }
        
        if subscribed {
            dispatch_async(queue) {
                subscriber.onError(error: Error.OnlyOneSubscriberAllowed)
            }
        } else {
            subscribed = true
            dispatch_async(queue) {
                subscriber.onSubscribe(subscription: OneShotSubscription(subscriber: subscriber, element: self.element, queue: self.queue))
            }
        }
    }
}

// MARK: - Subscription

internal final class OneShotSubscription<Element> : Subscription {
    /// The subscriber to signal.
    private let subscriber: AnySubscriber<Element>

    /// The element to signal the subscriber.
    private let element: Element

    /// The queue on which the subscriber will be signaled.
    private let queue: dispatch_queue_t

    internal init<S: Subscriber where S.SubscribeType == Element>(subscriber: S, element: Element, queue: dispatch_queue_t) {
        self.subscriber = AnySubscriber(subscriber)
        self.element = element
        self.queue = queue
    }

    internal func request(count: Int) {
        dispatch_async(queue) {
            self.subscriber.onNext(element: self.element)
            self.subscriber.onComplete()
        }
    }

    internal func cancel() {
    }
}