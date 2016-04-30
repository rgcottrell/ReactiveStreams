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

/// A `Subscriber` is a consumer of a potentially unbounded number of
/// sequenced elements received from a `Publisher`.
///
/// A `Subscriber` will receive a call to `onSubscribe(subscription:)` once
/// after passing an instance of `Subscriber` to `Publisher.subscribe(subscriber:)`.
///
/// No further notification will be received until `Subscription.request(count:)`
/// is called.
///
/// After signalling demand:
///
/// - One or more invocations of `onNext(element:)` up to the maximum defined
///   by `Subscription.request(count:)`.
///
/// - A single invocation of `onError(error:)` or `onComplete()` which signals
///   a terminal state after which no further events will be send.
///
/// Demand can be signaled via `Subscription.request(count:)` whenever the
/// `Subscriber` is capable of handling more.
public protocol Subscriber {
    /// The type of element signaled.
    associatedtype ElementType
    
    /// Invoked after calling `Publisher.subscribe(subscriber:)`.
    /// 
    /// No data will start flowing until `Subscription.request(count:)` is
    /// invoked.
    ///
    /// It is the responsibility of this `Subscriber` instance to call
    /// `Subscription.request(count:)` whenever more data is wanted.
    ///
    /// The `Publisher` will send notifications only in response to
    /// `Subscription.request(count:)`.
    ///
    /// - parameter subscription: The `Subscription` that allows requesting
    ///   data via `Subscription.request(count:)`.
    func onSubscribe(subscription: Subscription)
    
    /// Data notification sent by the `Publisher` in response to requests tp
    /// `Subscription.request(count:)`.
    ///
    /// - parameter element: The element signaled.
    func onNext(element: ElementType)
    
    /// Failed terminal state.
    ///
    /// No further events will be sent even if `Subscription.request(count:)`
    /// is called again.
    ///
    /// - parameter error: The errpr sgnaled.
    func onError(error: ErrorProtocol)
    
    /// Successful terminal state.
    ///
    /// No further events will be sent even if `Subscription.request(count:)`
    /// is called again.
    func onComplete()
}