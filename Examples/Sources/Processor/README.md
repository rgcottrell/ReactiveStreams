# Publisher

This example shows a simple publisher that can be created using factory
methods on the type erased AnyPublisher.

This technique could be extended to create an implementation of Reactive
Streams with an API similar to RxSwift.

## Notes

### Backpressure

In this example, the subscriber only requests a single element when it
subscribes. After each element is processed, the subscriber asks for one
more. This effectively converts the stream into a pull based stream.

### Memory Management

The publisher does not hold on to a reference to either the subscription or
the subscriber. Neither the subscription nor the subscriber hold on to a
reference to the publisher. The publisher is free to dealloc when there are
no external references to it.

While subscribing, the subscription is created with a reference to the
subscriber. The publisher immediately calls the subscriber's onNext method,
which retains a reference to the subscription.

As a result, the subscription and subscriber maintain strong references to
each other, creating a retain cycle that allows both to exist while the stream
is being processed. When the stream terminates, the subscriber releases its
reference to the subscription, breaking the retain cycle and allowing both
entitites to be deallocated.

## LICENSE

Copyright 2016 Robert Cottrell

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.