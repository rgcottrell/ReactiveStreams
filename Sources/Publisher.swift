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

/// A `Publisher` is a provider of a potentially unbounded number of
/// sequenced elemments, publishing them according to the demand received
/// from its `Subscriber`s.
///
/// A `Publisher` can serve multiple `Subscriber`s subscribed with
/// `subscribe(subscriber:)` dynamically at various points in time.
public protocol Publisher {
    /// The type of element to be published.
    associatedtype PublishType
    
    /// Request `Publisher` to start streaming data.
    ///
    /// This is a "factory method" and can be called multiple times, each
    /// time starting a new `Subscription`.
    ///
    /// Each `Subscription` will work for only a single `Subscriber`.
    ///
    /// A `Subscriber` should only subscribe once to a single `Publisher`.
    ///
    /// If the `Publisher` rejects the subscription attempt or oetherwise
    /// fails it will signal the error via `Subscriber.onError(error:)`.
    ///
    /// - parameter subscriber: The `Subscriber` that will consume signals
    ///   from this `Publisher`.
    func subscribe<S : Subscriber where S.SubscribeType == PublishType>(subscriber: S)
}

public extension Publisher {
    /// Erases type of the publisher and returns the canonical publisher.
    ///
    /// - returns: type erased publisher.
    public func asPublisher() -> AnyPublisher<PublishType> {
        if let publisher = self as? AnyPublisher<PublishType> {
            return publisher
        }
        return AnyPublisher(self)
    }  
}