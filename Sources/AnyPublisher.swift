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

/// A type-erased `Publisher` type.
///
/// Forwards operations to an arbitrary underlying publisher with the same
/// `PublishType` type, hiding the specifics of the underlying publisher.
public struct AnyPublisher<Element> : Publisher {
    /// The type of elements to be published.
    public typealias PublishType = Element
    
    /// The boxed publisher which will receive forwarded calls.
    private let _box: _AnyPublisherBox<PublishType>
    
    /// Create a type erased wrapper around a publisher.
    ///
    /// - parameter box: The publisher to receive operations.
    public init<P: Publisher where P.PublishType == PublishType>(_ base: P) {
        _box = _PublisherBox(base)
    }
    
    /// Forward `subscribe(subscriber:)` to the boxed publisher.
    public func subscribe<S : Subscriber where S.SubscribeType == PublishType>(subscriber: S) {
        _box.subscribe(subscriber: subscriber)
    }
}

internal final class _PublisherBox<P : Publisher> : _AnyPublisherBox<P.PublishType> {
    private let _base: P
    
    internal init(_ base: P) {
        self._base = base
    }
    
    internal override func subscribe<S : Subscriber where S.SubscribeType == P.PublishType>(subscriber: S) {
        _base.subscribe(subscriber: subscriber)
    }
}

internal class _AnyPublisherBox<Element> {    
    internal func subscribe<S : Subscriber where S.SubscribeType == Element>(subscriber: S) {
        _abstract()
    }
}