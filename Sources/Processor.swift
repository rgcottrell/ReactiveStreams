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

/// A `Processor` represents a processing stage which is both a `Subscriber`
/// and a `Publisher` and obeys the contracts of both.
public protocol Processor : Subscriber, Publisher {
}

public extension Processor {
    /// Erases type of the processor and returns the canonical processor.
    ///
    /// - returns: type erased publisher.
    public func asProcessor() -> AnyProcessor<SubscribeType, PublishType> {
        if let processor = self as? AnyProcessor<SubscribeType, PublishType> {
            return processor
        }
        return AnyProcessor(self)
    }  
}