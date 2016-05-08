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

/// A type-erased `Processor` type.
///
/// Forwards operations to an arbitrary underlying processor with the same
/// `SubscribeTrype` and `PublishType` types, hiding the specifics of the
/// underlying processor.
public final class AnyProcessor<ElementIn, ElementOut> : Processor {
    /// The type of elements to be received.
    public typealias SubscribeType = ElementIn
     
    /// The type of elements to be published.
    public typealias PublishType = ElementOut
    
    /// The boxed processor which will receive forwarded calls.
    private let _box: _AnyProcessorBox<SubscribeType, PublishType>
    
    /// Create a type erased wrapper around a processor.
    ///
    /// - parameter base: The processor to receive operations.
    public init<P: Processor where P.SubscribeType == SubscribeType, P.PublishType == PublishType>(_ base: P) {
        _box = _ProcessorBox(base)
    }
    
    /// Forward `onSubscribe(subscription:)` to the boxed processor.
    public func onSubscribe(subscription: Subscription) {
        _box.onSubscribe(subscription: subscription)
    }
    
    /// Forward `onNext()` to the boxed processor.
    public func onNext(element: SubscribeType) {
        _box.onNext(element: element)
    }
    
    /// Forward `onError(error:)` to the boxed processor.
    public func onError(error: ErrorProtocol) {
        _box.onError(error: error)
    }
    
    /// Forward `onComplete()` to the boxed processor.
    public func onComplete() {
        _box.onComplete()
    }
    
    /// Forward `subscribe(subscriber:)` to the boxed processor.
    public func subscribe<S : Subscriber where S.SubscribeType == PublishType>(subscriber: S) {
        _box.subscribe(subscriber: subscriber)
    }
}

internal final class _ProcessorBox<P : Processor> : _AnyProcessorBox<P.SubscribeType, P.PublishType> {
    private let _base: P
    
    internal init(_ base: P) {
        self._base = base
    }
    
    internal override func onSubscribe(subscription: Subscription) {
        _base.onSubscribe(subscription: subscription)
    }
    
    internal override func onNext(element: P.SubscribeType) {
        _base.onNext(element: element)
    }
    
    internal override func onError(error: ErrorProtocol) {
        _base.onError(error: error)
    }
    
    internal override func onComplete() {
        _base.onComplete()
    }
    
    internal override func subscribe<S : Subscriber where S.SubscribeType == P.PublishType>(subscriber: S) {
        _base.subscribe(subscriber: subscriber)
    }
}

internal class _AnyProcessorBox<ElementIn, ElementOut> {    
    internal func onSubscribe(subscription: Subscription) {
        _abstract()
    }
    
    internal func onNext(element: ElementIn) {
        _abstract()
    }
    
    internal func onError(error: ErrorProtocol) {
        _abstract()
    }
    
    internal func onComplete() {
        _abstract()
    }
    
    internal func subscribe<S : Subscriber where S.SubscribeType == ElementOut>(subscriber: S) {
        _abstract()
    }
}