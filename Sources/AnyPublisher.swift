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
public struct AnyPublisher<Publish>: Publisher {
    /// The type of elements to be published.
    public typealias PublishType = Publish
    
    /// The boxed publisher which will receive forwarded calls.
    private let box: _AnyPublisherBoxBase<PublishType>
    
    /// Create a type erased wrapper around a publisher.
    ///
    /// - parameter box: The publisher to receive operations.
    public init<P: Publisher where P.PublishType == PublishType>(_ box: P) {
        self.box = _AnyPublisherBox(box)
    }
    
    /// Forward `subscribe(subscriber:)` to the boxed publisher.
    public func subscribe<S: Subscriber where S.SubscribeType == PublishType>(subscriber: S) {
        box.subscribe(subscriber: subscriber)
    }
    
    /// Erases type of the publisher and returns the canonical publisher.
    ///
    /// - returns: type erased publisher.
    public func asPublisher() -> AnyPublisher<PublishType> {
        return self
    }
}

public extension Publisher {
    /// Erases type of the publisher and returns the canonical publisher.
    ///
    /// - returns: type erased publisher.
    public func asPublisher() -> AnyPublisher<PublishType> {
        return AnyPublisher(self)
    }  
}

private class _AnyPublisherBox<P: Publisher>: _AnyPublisherBoxBase<P.PublishType> {
    let box: P
    
    init(_ box: P) {
        self.box = box
    }
    
    override func subscribe<S: Subscriber where S.SubscribeType == PublishType>(subscriber: S) {
        box.subscribe(subscriber: subscriber)
    }
}

private class _AnyPublisherBoxBase<Publish>: Publisher {
    typealias PublishType = Publish
    
    func subscribe<S: Subscriber where S.SubscribeType == PublishType>(subscriber: S) {
        fatalError()
    }
}