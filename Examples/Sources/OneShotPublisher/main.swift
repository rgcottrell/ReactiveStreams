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

// Create a publisher to signal a single item to a single subscriber.
print("Creating publisher...")
let publisher = OneShotPublisher(element: 42)

// Create a subscriber and subscribe to the publisher. The subscriber should
// receive one element from the publisher and finish successfully.
print("\nCreating first subscriber and subscribing to publisher...")
let subscriber1 = SampleSubscriber<Int>(name: "FIRST")
publisher.subscribe(subscriber: subscriber1)

// Sleep to allow time for asynchronous streams to complete.
NSThread.sleep(forTimeInterval: 1.0)

// Create a second subscriber and subscribe to the publisher. The subscriber
// should receive an error result.
print("\nCreating second subscriber and subscribing to publisher...")
let subscriber2 = SampleSubscriber<Int>(name: "SECOND")
publisher.subscribe(subscriber: subscriber2)

// Sleep to allow time for asynchronous streams to complete.
NSThread.sleep(forTimeInterval: 1.0)