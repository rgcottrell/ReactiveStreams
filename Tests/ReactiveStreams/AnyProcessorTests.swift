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
import XCTest

@testable import ReactiveStreams

class TestProcessor : Processor {
    typealias SubscribeType = Void
    typealias PublishType = Void

    func onSubscribe(subscription: Subscription) {
        _abstract()
    }
    
    func onNext(element: SubscribeType) {
        _abstract()
    }
    
    func onError(error: ErrorProtocol) {
        _abstract()
    }
    
    func onComplete() {
        _abstract()
    }
    
    func subscribe<S : Subscriber where S.SubscribeType == PublishType>(subscriber: S) {
        _abstract()
    }
}

class AnyProcessorTests : XCTestCase {
    static let allTests: [(String, AnyProcessorTests -> () throws -> Void)] = [
        ("testAnyProcessor", testAnyProcessor),
        ("testAsProcessor1", testAsProcessor1),
        ("testAsProcessor2", testAsProcessor2)        
    ]
    
    func testAnyProcessor() {
        let anyProcessor1 = TestProcessor().asProcessor()
        let anyProcessor2 = AnyProcessor(anyProcessor1)
        XCTAssert(anyProcessor1._box === anyProcessor2._box, "AnyProcessor boxed values should match")
    }

    func testAsProcessor1() {
        let processor = TestProcessor()
        let asProcessor1 = processor.asProcessor()
        let asProcessor2 = asProcessor1.asProcessor()
        XCTAssertTrue(asProcessor1 === asProcessor2, "asProcessor is a no-op when applied to AnyProcessor")
    }

    func testAsProcessor2() {
        func box<P : Processor, ElementIn, ElementOut where P.SubscribeType == ElementIn, P.PublishType == ElementOut>(processor: P) -> AnyProcessor<ElementIn, ElementOut> {
            return processor.asProcessor()
        }
        
        let processor = TestProcessor()
        let asProcessor1 = processor.asProcessor()
        let asProcessor2 = box(processor: asProcessor1)
        XCTAssertTrue(asProcessor1 === asProcessor2, "asProcessor is a no-op when applied to AnyProcessor")
    }
}