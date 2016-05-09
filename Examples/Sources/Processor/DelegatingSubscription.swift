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

/// The `DelegatingSubscriptionDelegate` protocol describes the methds that
/// `DelegatingSubscription` subscriptions call on their delegates to handle
/// calls made to the subscription.
public protocol DelegatingSubscriptionDelegate : class {
    /// Signals the delegate that the subscriber has requested additional
    /// elements. The subscription will only notify the delegate if the
    /// subscription has not yet been canceled.
    ///
    /// - parameter subscription: The subscription requesting items.
    ///
    /// - parameter count: The number of items requested.
    func subscription(_ subscription: Subscription, didRequestCount count: Int)
    
    /// Signals the delegate that the subscriber has requested to cancel the
    /// subscription. The subscription will only notify the delegate if the
    /// subscription has not yet been canceled.
    ///
    /// - parameter subscription: The subscription being canceled.
    func subscriptionDidCancel(_ subscription: Subscription)
}

/// A simple `Subscription` that delegates subscription calls. The delegate
/// is responsible for ensuring that all of the requirements of a subscription
/// are maintained.
///
/// Because the subscription takes an unowned reference to its delegate, the
/// delegate is required to outlive the subscription.
public final class DelegatingSubscription : Subscription {
    private unowned let delegate: DelegatingSubscriptionDelegate
    
    private let lock = NSLock()
    private var canceled = false
    
    public var isCanceled: Bool {
        lock.lock(); defer { lock.unlock() }
        return canceled
    }
    
    public init(delegate: DelegatingSubscriptionDelegate) {
        self.delegate = delegate
    }
    
    public func request(count: Int) {
        lock.lock()
        if canceled {
            lock.unlock()
            return
        }
        lock.unlock()
        
        delegate.subscription(self, didRequestCount: count)
    }
    
    public func cancel() {
        lock.lock()
        if canceled {
            lock.unlock()
            return
        }
        canceled = true
        lock.unlock()
        
        delegate.subscriptionDidCancel(self)
    }
}