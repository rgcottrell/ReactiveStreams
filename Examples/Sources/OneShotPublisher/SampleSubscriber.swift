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

/// A sample `Subscriber` that requests an unbounded number of items and
/// then logs events to the console.
public final class SampleSubscriber<Element> : Subscriber {
    /// The type of element signaled.
    public typealias SubscribeType = Element
    
    /// A displayable name for the subscriber.
    public let name: String
    
    private var subscription: Subscription?
    
    public init(name: String) {
        self.name = name
    }
    
    public func onSubscribe(subscription: Subscription) {
        logEvent(event: "onSubscribe", description: "subscription has started")
        
        self.subscription = subscription
        subscription.request(count: Int.max)
    }
    
    public func onNext(element: SubscribeType) {
        logEvent(event: "onNext", description: "publisher has signaled element: \(element)")
    }
    
    public func onError(error: ErrorProtocol) {
        logEvent(event: "onError", description: "subscription has terminated with error: \(error)")
    }
    
    public func onComplete() {
        logEvent(event: "onComplete", description: "subscription has terminated normally")
    }
    
    private func logEvent(event: String, description: String) {
        print("[\(name)] \(event): \(description)")
    }
}