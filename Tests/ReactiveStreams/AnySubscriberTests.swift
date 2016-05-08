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

class TestSubscriber<Element> : Subscriber {
    typealias SubscribeType = Element

    func onSubscribe(subscription: Subscription) {
        _abstract()
    }
    
    func onNext(element: Element) {
        _abstract()
    }
    
    func onError(error: ErrorProtocol) {
        _abstract()
    }
    
    func onComplete() {
        _abstract()
    }
}

class AnySubscriberTests : XCTestCase {
    static let allTests: [(String, AnySubscriberTests -> () throws -> Void)] = [
        ("testAsSubscriber1", testAsSubscriber1),
        ("testAsSubscriber2", testAsSubscriber2)        
    ]

    func testAsSubscriber1() {
        let subscriber = TestSubscriber<Int>()
        let asSubscriber1 = subscriber.asSubscriber()
        let asSubscriber2 = asSubscriber1.asSubscriber()
        XCTAssertTrue(asSubscriber1 === asSubscriber2, "asSubscriber is a no-op when applied to AnySubscriber")
    }

    func testAsSubscriber2() {
        func box<S : Subscriber, Element where S.SubscribeType == Element>(subscriber: S) -> AnySubscriber<Element> {
            return subscriber.asSubscriber()
        }
        
        let subscriber = TestSubscriber<Int>()
        let asSubscriber1 = subscriber.asSubscriber()
        let asSubscriber2 = box(subscriber: asSubscriber1)
        XCTAssertTrue(asSubscriber1 === asSubscriber2, "asSubscriber is a no-op when applied to AnySubscriber")
    }
}
