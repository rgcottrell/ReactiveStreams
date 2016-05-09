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

/// This is an implementation of Reactive Streams `Subscriber`. It runs
/// synchronously (on the publisher's thread) and requests one element
/// at a time and invokes a user defined method to process each element.
public class SyncSubscriber<Element> : Subscriber {
    public typealias SubscribeType = Element
    
    /// The subscription returned when subscribing to the publisher.
    /// Obeying rule 3.1, we make this private.
    private var subscription: Subscription?
    
    /// Indicates whether we are done processing elements.
    private var done = false
    
    /// This will be called for each element emitted by the processor.
    /// - parameter element: The element emitted by the publisher.
    /// - returns: Whether more elements are desired or not.
    private let whenNext: (Element) throws -> Bool
    
    /// Create a new instance of `SyncSubscriber`.
    ///
    /// - parameter whenNext: The function to process each element received
    ///   from the publisher and to indicate whether more elements are
    ///   desired.
    public init(whenNext: (Element) throws -> Bool) {
        self.whenNext = whenNext
    }
    
    public func onSubscribe(subscription: Subscription) {
        // If someone has made a mistake and added this Subscriber multiple
        // times, let's handle it gracefully.
        guard self.subscription == nil else {
            subscription.cancel()
            return
        }
        
        // We have to assign it locally before we used it, if we want to be a
        // synchronous `Subscriber`. According to rule 3.10, the subscription
        // is allowed to call `onNext(element:)` synchronously from within
        // `request(count:)`.
        self.subscription = subscription
        
        // If we want elements, according to rule 2.1 we need to call
        // `request(count:)`. And, according to rule 3.2 we are allowed to
        // call this synchronously from within the `onSubscribe(subscription:)`
        // method.
        subscription.request(count: 1)
    }
    
    public func onNext(element: Element) {
        assert(subscription != nil, "Publisher violated the Reactive Streams rule 1.09 by signaling onNext prior to onSubscribe")
        
        guard !done else {
            return
        }

        do {
            if try whenNext(element) {
                subscription?.request(count: 1)
            } else {
                finish()
            }
        } catch {
            finish()
            onError(error: error)
        }
    }
    
    public func onError(error: ErrorProtocol) {
        assert(subscription != nil, "Publisher violated the Reactive Streams rule 1.09 by signaling onComplete prior to onSubscribe")
        
        // As per rule 2.3, we are not allowed to call any methods on the
        // `Subscription` or `Publisher`.
        //
        // As per rule 2.4, the `Subscription` should be considered canceled
        // if this method is called.
        subscription = nil
    }
    
    public func onComplete() {
        assert(subscription != nil, "Publisher violated the Reactive Streams rule 1.09 by signaling onComplete prior to onSubscribe")

        // As per rule 2.3, we are not allowed to call any methods on the
        // `Subscription` or `Publisher`.
        //
        // As per rule 2.4, the `Subscription` should be considered canceled
        // if this method is called.
        subscription = nil
    }
    
    /// Showcases a convenience method to idempotently mark the `Subscriber`
    /// as "done" so no more elements are processed. This also cancels the
    /// subscription.
    private func finish() {
        // As per rule 3.7, calls to `Subscription.cancel()` are idempotent,
        // so the guard is not needed.
        guard !done else {
            return
        }
        done = true
        subscription?.cancel()
        
        // The `Subscription` is no longer needed.
        subscription = nil
    }
}