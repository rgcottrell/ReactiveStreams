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
public struct AnyProcessor<Subscribe, Publish>: Processor {
    /// The type of elements to be received.
    public typealias SubscribeType = Subscribe
     
    /// The type of elements to be published.
    public typealias PublishType = Publish
    
    /// The boxed processor which will receive forwarded calls.
    private let box: _AnyProcessorBoxBase<SubscribeType, PublishType>
    
    /// Create a type erased wrapper around a processor.
    ///
    /// - parameter box: The processor to receive operations.
    public init<P: Processor where P.SubscribeType == SubscribeType, P.PublishType == PublishType>(_ box: P) {
        self.box = _AnyProcessorBox(box)
    }
    
    /// Forward `onSubscribe(subscription:)` to the boxed processor.
    public func onSubscribe(subscription: Subscription) {
        box.onSubscribe(subscription: subscription)
    }
    
    /// Forward `onNext` to the boxed processor.
    public func onNext(element: SubscribeType) {
        box.onNext(element: element)
    }
    
    /// Forward `onError(error:)` to the boxed processor.
    public func onError(error: ErrorProtocol) {
        box.onError(error: error)
    }
    
    /// Forward `onComplete()` to the boxed processor.
    public func onComplete() {
        box.onComplete()
    }
    
    /// Forward `subscribe(subscriber:)` to the boxed processor.
    public func subscribe<S: Subscriber where S.SubscribeType == PublishType>(subscriber: S) {
        box.subscribe(subscriber: subscriber)
    }
    
    /// Erases type of the processor and returns the canonical processor.
    ///
    /// - returns: type erased processor.
    public func asProcessor() -> AnyProcessor<SubscribeType, PublishType> {
        return self
    }
}

public extension Processor {
    /// Erases type of the processor and returns the canonical processor.
    ///
    /// - returns: type erased processor.
    public func asProcessor() -> AnyProcessor<SubscribeType, PublishType> {
        return AnyProcessor(self)
    }  
}

private class _AnyProcessorBox<P: Processor>: _AnyProcessorBoxBase<P.SubscribeType, P.PublishType> {
    let box: P
    
    init(_ box: P) {
        self.box = box
    }
    
    override func onSubscribe(subscription: Subscription) {
        box.onSubscribe(subscription: subscription)
    }
    
    override func onNext(element: SubscribeType) {
        box.onNext(element: element)
    }
    
    override func onError(error: ErrorProtocol) {
        box.onError(error: error)
    }
    
    override func onComplete() {
        box.onComplete()
    }
    
    override func subscribe<S: Subscriber where S.SubscribeType == PublishType>(subscriber: S) {
        box.subscribe(subscriber: subscriber)
    }
}

private class _AnyProcessorBoxBase<Subscribe, Publish>: Processor {
    typealias SubscribeType = Subscribe
    typealias PublishType = Publish
    
    func onSubscribe(subscription: Subscription) {
        fatalError()
    }
    
    func onNext(element: SubscribeType) {
        fatalError()
    }
    
    func onError(error: ErrorProtocol) {
        fatalError()
    }
    
    func onComplete() {
        fatalError()
    }
    
    func subscribe<S: Subscriber where S.SubscribeType == PublishType>(subscriber: S) {
        fatalError()
    }
}