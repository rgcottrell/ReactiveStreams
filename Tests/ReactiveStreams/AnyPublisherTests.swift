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

class TestPublisher<Element> : Publisher {
    typealias PublishType = Element
    
    func subscribe<S : Subscriber where S.SubscribeType == PublishType>(subscriber: S) {
        _abstract()
    }
}

class AnyPublisherTests : XCTestCase {
    static let allTests: [(String, AnyPublisherTests -> () throws -> Void)] = [
        ("testAsPublisher1", testAsPublisher1),
        ("testAsPublisher2", testAsPublisher2)        
    ]

    func testAsPublisher1() {
        let publisher = TestPublisher<Int>()
        let asPublisher1 = publisher.asPublisher()
        let asPublisher2 = asPublisher1.asPublisher()
        XCTAssertTrue(asPublisher1 === asPublisher2, "asPublisher is a no-op when applied to AnyPublisher")
    }

    func testAsPublisher2() {
        func box<P : Publisher, Element where P.PublishType == Element>(publisher: P) -> AnyPublisher<Element> {
            return publisher.asPublisher()
        }
        
        let publisher = TestPublisher<Int>()
        let asPublisher1 = publisher.asPublisher()
        let asPublisher2 = box(publisher: asPublisher1)
        XCTAssertTrue(asPublisher1 === asPublisher2, "asPublisher is a no-op when applied to AnyPublisher")
    }
}
