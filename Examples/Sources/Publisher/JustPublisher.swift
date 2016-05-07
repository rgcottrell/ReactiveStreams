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

public extension AnyPublisher {
    @warn_unused_result(message: "Unused publisher")
    public static func just(_ element: Element) -> AnyPublisher<Element> {
        return JustPublisher(element: element).asPublisher()
    }
}

// MARK: - Publisher

internal final class JustPublisher<Element> : Publisher {
    internal typealias PublishType = Element
    
    internal let element: Element
    
    internal init(element: Element) {
        self.element = element
    }
    
    internal func subscribe<S : Subscriber where S.SubscribeType == PublishType>(subscriber: S) {
        subscriber.onSubscribe(subscription: JustSubscription(subscriber: subscriber, element: self.element))
    }
}

// MARK: - Subscription

internal final class JustSubscription<Element> : Subscription {
    /// The subscriber to signal.
    private let subscriber: AnySubscriber<Element>

    /// The element to signal the subscriber.
    private let element: Element

    /// The queue on which the subscriber will be signaled.
    private let queue: dispatch_queue_t = dispatch_queue_create("JustSubscription.Queue", DISPATCH_QUEUE_SERIAL)

    /// True if the subscriptio has terminated or been canceled.
    private var done = false

    internal init<S: Subscriber where S.SubscribeType == Element>(subscriber: S, element: Element) {
        self.subscriber = AnySubscriber(subscriber)
        self.element = element
    }

    internal func request(count: Int) {
        dispatch_async(queue) {
            guard !self.done else {
                return
            }
            self.subscriber.onNext(element: self.element)
            self.subscriber.onComplete()
            self.done = true
        }
    }

    internal func cancel() {
        dispatch_async(queue) {
            self.done = true
        }
    }
}