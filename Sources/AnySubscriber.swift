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

/// A type-erased `Subscriber` type.
///
/// Forwards operations to an arbitrary underlying subscriber with the same
/// `SubscribeTrype` type, hiding the specifics of the underlying subscriber.
public struct AnySubscriber<Subscribe>: Subscriber {
    /// The type of elements to be received.
    public typealias SubscribeType = Subscribe
     
    /// The boxed processor which will receive forwarded calls.
    private let box: _AnySubscriberBoxBase<SubscribeType>
    
    /// Create a type erased wrapper around a subscriber.
    ///
    /// - parameter box: The subscriber to receive operations.
    public init<S: Subscriber where S.SubscribeType == SubscribeType>(_ box: S) {
        self.box = _AnySubscriberBox(box)
    }
    
    /// Forward `onSubscribe(subscription:)` to the boxed subscriber.
    public func onSubscribe(subscription: Subscription) {
        box.onSubscribe(subscription: subscription)
    }
    
    /// Forward `onNext` to the boxed subscriber.
    public func onNext(element: SubscribeType) {
        box.onNext(element: element)
    }
    
    /// Forward `onError(error:)` to the boxed subscriber.
    public func onError(error: ErrorProtocol) {
        box.onError(error: error)
    }
    
    /// Forward `onComplete()` to the boxed subscriber.
    public func onComplete() {
        box.onComplete()
    }

    /// Erases type of the subscriber and returns the canonical subscriber.
    ///
    /// - returns: type erased subscriber.
    public func asSubscriber() -> AnySubscriber<SubscribeType> {
        return self
    }
}

public extension Subscriber {
    /// Erases type of the subscriber and returns the canonical processor.
    ///
    /// - returns: type erased subscriber.
    public func asSubscriber() -> AnySubscriber<SubscribeType> {
        return AnySubscriber(self)
    }  
}

private class _AnySubscriberBox<S: Subscriber>: _AnySubscriberBoxBase<S.SubscribeType> {
    let box: S
    
    init(_ box: S) {
        self.box = box
    }
    
    override func onSubscribe(subscription: Subscription) {
        box.onSubscribe(subscription: subscription)
    }
    
    override func onNext(element: SubscribeType) {
        box.onNext(element: element)
    }
    
    override func onError(error: ErrorProtocol) {
        box.onError(error: error)
    }
    
    override func onComplete() {
        box.onComplete()
    }
}

private class _AnySubscriberBoxBase<Subscribe>: Subscriber {
    typealias SubscribeType = Subscribe
    
    func onSubscribe(subscription: Subscription) {
        fatalError()
    }
    
    func onNext(element: SubscribeType) {
        fatalError()
    }
    
    func onError(error: ErrorProtocol) {
        fatalError()
    }
    
    func onComplete() {
        fatalError()
    }
}