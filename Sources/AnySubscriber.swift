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
public final class AnySubscriber<Element> : Subscriber {
    /// The type of elements to be received.
    public typealias SubscribeType = Element
     
    /// The boxed processor which will receive forwarded calls.
    internal let _box: _AnySubscriberBox<SubscribeType>
    
    /// Create a type erased wrapper around a subscriber.
    ///
    /// - parameter base: The subscriber to receive operations.
    public init<S : Subscriber where S.SubscribeType == SubscribeType>(_ base: S) {
        _box = _SubscriberBox(base)
    }
    
    /// Create a type erased wrapper having the same underlying `Subscriber`
    /// as `other`.
    ///
    /// - parameter other: The other `AnySubscriber` instance.
    public init(_ other: AnySubscriber<Element>) {
        _box = other._box
    }
    
    /// Forward `onSubscribe(subscription:)` to the boxed subscriber.
    public func onSubscribe(subscription: Subscription) {
        _box.onSubscribe(subscription: subscription)
    }
    
    /// Forward `onNext` to the boxed subscriber.
    public func onNext(element: SubscribeType) {
        _box.onNext(element: element)
    }
    
    /// Forward `onError(error:)` to the boxed subscriber.
    public func onError(error: ErrorProtocol) {
        _box.onError(error: error)
    }
    
    /// Forward `onComplete()` to the boxed subscriber.
    public func onComplete() {
        _box.onComplete()
    }
}

internal final class _SubscriberBox<S : Subscriber> : _AnySubscriberBox<S.SubscribeType> {
    private let _base: S
    
    internal init(_ base: S) {
        self._base = base
    }
    
    internal override func onSubscribe(subscription: Subscription) {
        _base.onSubscribe(subscription: subscription)
    }
    
    internal override func onNext(element: S.SubscribeType) {
        _base.onNext(element: element)
    }
    
    internal override func onError(error: ErrorProtocol) {
        _base.onError(error: error)
    }
    
    internal override func onComplete() {
        _base.onComplete()
    }
}

internal class _AnySubscriberBox<Element> {
    internal func onSubscribe(subscription: Subscription) {
        _abstract()
    }
    
    internal func onNext(element: Element) {
        _abstract()
    }
    
    internal func onError(error: ErrorProtocol) {
        _abstract()
    }
    
    internal func onComplete() {
        _abstract()
    }
}