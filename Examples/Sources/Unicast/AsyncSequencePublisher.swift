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

// MARK: - Publisher

/// This is an implementation of a Reactive Streams `Publisher` which
/// executes asynchronously, using an internal dispatch queue, and produces
/// elements from a given `Sequence` in a "unicast" configuration to its
/// `Subscriber`s.
public class AsyncSequencePublisher<Element> : Publisher {
    public typealias PublishType = Element
    
    /// This is the data source.
    private let elements: AnySequence<Element>
    
    public init<
        S : Sequence
        where
        S.Iterator.Element == Element,
        S.SubSequence : Sequence,
        S.SubSequence.Iterator.Element == Element,
        S.SubSequence.SubSequence == S.SubSequence
    >(elements: S) {
        self.elements = AnySequence(elements)
    }
    
    public func subscribe<S : Subscriber where S.SubscribeType == PublishType>(subscriber: S) {
        // As per rule 1.11, we have decided to support multiple subscribers
        // in a unicast configuration for this `Publisher` implementation.
        let subscription = AsyncSequenceSubscription(subscriber: subscriber, iterator: elements.makeIterator())
        subscriber.onSubscribe(subscription: subscription)
    }
}

// MARK: - Subscription

/// This is an implementation of the Reactive Streams `Subscription`, which
/// represents the association between a `Publisher` and a `Subscriber`.
internal class AsyncSequenceSubscription<Element> : Subscription {
    private let subscriber: AnySubscriber<Element>
    private var iterator: AnyIterator<Element>
    private let batchSize = 10
    private var demand = 0
    private var canceled = false
    
    /// The queue on which to execute work.
    private let queue = dispatch_queue_create("AsyncSequenceSubscription.Queue", DISPATCH_QUEUE_SERIAL)
    
    internal init<S : Subscriber where S.SubscribeType == Element>(subscriber: S, iterator: AnyIterator<Element>) {
        self.subscriber = AnySubscriber(subscriber)
        self.iterator = iterator
    }
    
    internal func request(count: Int) {
        dispatch_async(queue) {
            [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.doRequest(count: count)
        }
    }
    
    internal func cancel() {
        dispatch_async(queue) {
            [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.doCancel()
        }
    }
    
    private func doRequest(count: Int) {
        // This method will register inbound demand from our `Subscriber`
        // and validate it against rule 3.9 and rule 3.17
        if count < 1 {
            let error = ReactiveStreamsError.IllegalStateException("Subscriber violated the Reactive Streams rule 3.9 by requesting a non-positive number of elements.")
            terminateDueToError(error: error)
        } else if count > Int.max - demand {
            // As governed by rule 3.17, when demand overflows `Int.max` we
            // treat the signaled demand as "effectively unbounded".
            demand = Int.max
            // Then we proceed with sending data downstream.
            doSend()
        } else {
            // Here we record the downstream demand
            demand += count
            // Then we proceed with sending data downstream.
            doSend()
        }
    }
    
    private func doSend() {        
        // In order to play nice with the dispatch queue, we will only send
        // at most `batchSize` elements before rescheduling ourselves and
        // relinquishing the current thread.
        var leftInBatch = batchSize
        
        // Loop through demand and signal the `Subscriber`.
        while !canceled && demand > 0 && leftInBatch > 0 {
            guard let element = iterator.next() else {
                // If we are at the end of stream, we need to consider the
                // `Subscription` as cenceled per rule 1.6
                doCancel()
                // Then we signal `onComplete()` as per rule 1.2 and 1.5.
                subscriber.onComplete()
                // Break out of the sending loop.
                return 
            }
    
            // Then we signal the next element downstream to the `Subscriber`.
            subscriber.onNext(element: element)
    
            // Update remaining demand and batch size.
            demand -= 1
            leftInBatch -= 1
        }
        
        // Return unless there is remaining demand.
        guard !canceled && demand > 0 else {
            return
        }
        
        // Schedule another batch.
        dispatch_async(queue) {
            [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.doSend()
        }
    }
    
    private func doCancel() {
        // This handles cancellation requests, and is idempotent, thread-safe
        // and not synchronously performing heavy computations as specified
        // in rule 3.5
        canceled = true
    }
    
    /// This is a helper method to ensure that we always `cancel` when we
    /// signal `onError` as per rule 1.6
    private func terminateDueToError(error: ErrorProtocol) {
        // When we signal onError, the subscription must be considered as
        // canceled, as per rule 1.6.
        doCancel()
        // Then we signal the error downstream, to the `Subscriber`.
        subscriber.onError(error: error)
    }
}