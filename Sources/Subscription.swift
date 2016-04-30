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

/// A `Subscription` represents a one-to-one lifecycle of a `Subscriber`
/// subscribing to a `Publisher`.
///
/// It can only be used once by a single `Subscriber`.
///
/// It is used to both signal desire for data and canel demand (and allow
/// resource cleanup).
public protocol Subscription {
    /// No events will be sent by a `Publisher` until demand is signaled via
    /// this method.
    ///
    /// It can be called however often and whenever needed, but the
    /// outstanding cumulative demand must never exceed `Int.max`.
    /// An outstanding cumulative demad of `Int.max` may be treated by the
    /// `Publisher` as effectively unbounded.
    ///
    /// Whatever has been requested can be sent by the `Publisher` so only
    /// signal demand for what can safely be handled.
    ///
    /// A `Publisher` can send less than is requested if the stream ends, but
    /// then must emit either `Subscriber.onError(error:)` or
    /// `Subscriber.onComplete()`.
    ///
    /// - parameter count: The strictly positive number of elements to request
    ///   from the upstream `Publisher`.
    func request(count: Int)
    
    /// Request the `Publisher` to stop sending data and clean up resources.
    ///
    /// Data may still be sent to meet previously signaled demand after
    /// calling `cancel()` as this request is asynchronous.
    func cancel()
}