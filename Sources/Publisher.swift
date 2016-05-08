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
///
/// RULES
/// -----
///
/// 01. The total number of `onNext(element:)` signals sent by a `Publisher`
///     MUST be less than or equal to the total number of elements requested
///     by that `Subscriber`'s `Subscription` at all times.
///
/// 02. A `Publisher` MAY signal less `onNext(element:)` than requested and
///     terminate the `Subscription` by calling `onComplete()` or
///    `onError(error:)`.
///
/// 03. Any `onSubscribe(subscription:)`, `onNext(element:)`, `onError(error:)`,
///     and`onComplete()` events signaled to a `Subscriber` MUST be signaled
///    sequentially (no concurrent notifications).
///
/// 04. If a `Publisher` failes, it MUST signal an `onError(error:)`.
///
/// 05. If a `Publisher` terminates successfully (finit stream), it MUST
///     signal an `onComplete()`.
///
/// 06. If a `Publisher` signals either `onError(error:)` or `onComplete()`
///     on a `Subscriber`, that `Subscriber`'s `Subscription` MUST be
///     considered canceled.
///
/// 07. Once a terminal state has been signaled (`onError(error:)`,
///     `onComplete()`), it is REQUIRED that no further signals occur.
///
/// 08. If a `Subscription` is canceled, its `Subscriber` MUST eventually
///     stop being signaled.
///
/// 09. `Publisher.subscribe(subscriber:)` MUST call `onSubscribe(subscription:)`
///     on the provided `Subscriber` prior to any other signals to that
///     `Subscriber`. The only legal way to signal failure (or reject the
///     `Subscriber`) is by calling `onError(error:)` (after calling
///     `onSubscribe(subscription:)`).
///
/// 10. `Publisher.subscribe(subscriber:)` MAY be called as many times as
///     wanted byt MUST be with a different `Subscriber` each time.
///
/// 11. A `Publisher` MAY support multiple `Subscriber`s and decides whether
///     each `Subscription` is unicast or multicast.
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