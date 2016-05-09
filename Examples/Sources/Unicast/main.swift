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

// Create a publisher to signal a single item to and subscribe to it with a
// custom onNext handler.
let publisher = AsyncSequencePublisher(elements: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15])

// Create a subscriber to log published elements.
let subscriber = SyncSubscriber<Int>(whenNext: {
    print("ELEMENT: \($0)")
    return true
})   

publisher.subscribe(subscriber: subscriber)

// Sleep to allow time for asynchronous streams to complete.
NSThread.sleep(forTimeInterval: 1.0)