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

/// Errors due to failure to comply with the Reactive Streams specification.
public enum ReactiveStreamsError : ErrorProtocol {
    case IllegalStateException(String)
}

/// Signals that the method is an abstract method that must be overriden
/// in a subclass.
@noreturn @inline(never)
internal func _abstract(file: StaticString = #file, line: UInt = #line) {
    fatalError("Method must be overriden", file: file, line: line)
}