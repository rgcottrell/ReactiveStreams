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
    public func subscribeOnNext(_ onNextBlock: (Element) -> Void) {
        let subscriber = OnNextSubscriber(onNextBlock: onNextBlock).asSubscriber()
        self.subscribe(subscriber: subscriber)
    }
}

// MARK: - Subscriber

/// A simple subscriber that that executes a user provided closure each time
/// the upstream publisher publishes an event.
internal final class OnNextSubscriber<Element> : Subscriber {
    internal typealias SubscribeType = Element

    private let onNextBlock: (Element) -> Void
    
    private var subscription: Subscription?
    
    internal init(onNextBlock: (Element -> Void)) {
        self.onNextBlock = onNextBlock
    }

    internal func onSubscribe(subscription: Subscription) {        
        self.subscription = subscription
        subscription.request(count: 1)
    }
    
    internal func onNext(element: SubscribeType) {
        onNextBlock(element)
        subscription?.request(count: 1)
    }
    
    internal func onError(error: ErrorProtocol) {
        subscription = nil
    }
    
    internal func onComplete() {
        subscription = nil
    }
}