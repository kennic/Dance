// The MIT License (MIT)
//
// Copyright (c) 2017 Saoud Rizwan <hello@saoudmr.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

// MARK: - Dance Implementation

fileprivate class DanceFactory {
    
    static let instance = DanceFactory()
    
    // MARK: UIViewPropertyAnimator Wrapper
    
    var tagCount: Int = 0
    var animators = [Int: UIViewPropertyAnimator]() // [UIView.tag: UIViewPropertyAnimator()]
    
    /// Initialize a UIViewPropertyAnimator with timing parameters.
    func createNewAnimator(tag: Int, duration: TimeInterval, timingParameters: UITimingCurveProvider, animations: @escaping (() -> Void)) {
        let newAnimator = UIViewPropertyAnimator(duration: duration, timingParameters: timingParameters)
        newAnimator.addAnimations(animations)
        newAnimator.addCompletion { (_) in
            self.animators.removeValue(forKey: tag)
        }
        animators[tag] = newAnimator
    }
    
    /// Initialize a UIViewPropertyAnimator with an animation curve.
    func createNewAnimator(tag: Int, duration: TimeInterval, curve: UIViewAnimationCurve, animations: (() -> Void)?) {
        let newAnimator = UIViewPropertyAnimator(duration: duration, curve: curve, animations: animations)
        newAnimator.addCompletion { (_) in
            self.animators.removeValue(forKey: tag)
        }
        animators[tag] = newAnimator
    }
    
    /// Initialize a UIViewPropertyAnimator with custom control points.
    func createNewAnimator(tag: Int, duration: TimeInterval, controlPoint1 point1: CGPoint, controlPoint2 point2: CGPoint, animations: (() -> Void)?) {
        let newAnimator = UIViewPropertyAnimator(duration: duration, controlPoint1: point1, controlPoint2: point2, animations: animations)
        newAnimator.addCompletion { (_) in
            self.animators.removeValue(forKey: tag)
        }
        animators[tag] = newAnimator
    }
    
    /// Initialize a UIViewPropertyAnimator with a damping ratio.
    func createNewAnimator(tag: Int, duration: TimeInterval, dampingRatio: CGFloat, animations: (() -> Void)?) {
        let newAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: dampingRatio, animations: animations)
        newAnimator.addCompletion { (_) in
            self.animators.removeValue(forKey: tag)
        }
        animators[tag] = newAnimator
    }
    
    /// Add a completion block to the current UIViewPropertyAnimator for the UIView.
    func addCompletion(tag: Int, completion: @escaping (UIViewAnimatingPosition) -> Void) {
        if let animator = animators[tag] {
            animator.addCompletion(completion)
        } else {
            handle(error: .noAnimation, forViewWithTag: tag)
        }
    }
    
    /// Start the UIViewPropertyAnimator animation for the UIView immediately.
    func startAnimation(tag: Int) {
        if let animator = animators[tag] {
            animator.startAnimation()
        } else {
            handle(error: .noAnimation, forViewWithTag: tag)
        }
    }
    
    /// Start the UIViewPropertyAnimator animation for the UIView after a delay (in seconds).
    func startAnimation(tag: Int, afterDelay delay: TimeInterval) {
        if let animator = animators[tag] {
            animator.startAnimation(afterDelay: delay)
        } else {
            handle(error: .noAnimation, forViewWithTag: tag)
        }
    }
    
    /// Pause the UIViewPropertyAnimator animation for the UIView immediately.
    func pauseAnimation(tag: Int) {
        if let animator = animators[tag] {
            animator.pauseAnimation()
        } else {
            handle(error: .noAnimation, forViewWithTag: tag)
        }
    }
    
    /// Pause the UIViewPropertyAnimator animation for the UIView after a delay (in seconds).
    func pauseAnimation(tag: Int, afterDelay delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            if let animator = self.animators[tag] {
                animator.pauseAnimation()
            } else {
                self.handle(error: .noAnimation, forViewWithTag: tag)
            }
        })
    }
    
    /// Finish the UIViewPropertyAnimator animation.
    /// Only stopped animations can be finished, and UIViewPropertyAnimator completion blocks are called only once an animation finishes.
    func finishAnimation(tag: Int, at finalPosition: UIViewAnimatingPosition) {
        if let animator = animators[tag] {
            // You can't finish an animation that hasn't been started. So in case it hasn't been started - start it.
            if !animator.isRunning {
                animator.startAnimation()
            }
            animator.stopAnimation(false)
            animator.finishAnimation(at: finalPosition)
        } else {
            handle(error: .noAnimation, forViewWithTag: tag)
        }
        
    }
    
    /// Fraction of completion of a UIViewPropertyAnimator animation.
    func getFractionComplete(tag: Int) -> CGFloat {
        if let animator = animators[tag] {
            return animator.fractionComplete
        } else {
            handle(error: .noAnimation, forViewWithTag: tag)
            return CGFloat(0)
        }
        
    }
    
    /// Updates the UIViewPropertyAnimator's .fractionComplete.
    func setFractionComplete(tag: Int, newFractionComplete: CGFloat) {
        if let animator = animators[tag] {
            // trigger the animator if it exists but hasn't started
            if !animator.isRunning {
                animator.startAnimation()
                animator.pauseAnimation()
            }
            animator.fractionComplete = newFractionComplete
        } else {
            handle(error: .noAnimation, forViewWithTag: tag)
        }
        
    }
    
    /// Returns the view's UIViewPropertyAnimator current state (inactive, active, stopped).
    func getState(tag: Int) -> UIViewAnimatingState {
        if let animator = animators[tag] {
            return animator.state
        } else {
            handle(error: .noAnimation, forViewWithTag: tag)
            return .inactive
        }
    }
    
    /// Returns a boolean value indicating whether the UIView's animation is running (active, started and not paused) or paused/inactive.
    func getIsRunning(tag: Int) -> Bool {
        if let animator = animators[tag] {
            return animator.isRunning
        } else {
            handle(error: .noAnimation, forViewWithTag: tag)
            return false
        }
    }
    
    /// Returns a boolean value indicating whether the UIView's UIViewPropertyAnimator is reversed or not.
    func getIsReversed(tag: Int) -> Bool {
        if let animator = animators[tag] {
            return animator.isReversed
        } else {
            handle(error: .noAnimation, forViewWithTag: tag)
            return false
        }
    }
    
    /// Updates the UIView's UIViewPropertyAnimator's .isReversed property, dynamically reversing the animation in progress.
    func setIsReversed(tag: Int, isReversed: Bool) {
        if let animator = animators[tag] {
            animator.isReversed = isReversed
        } else {
            handle(error: .noAnimation, forViewWithTag: tag)
        }
    }
    
    /// Returns a boolean value inidicating whether the UIView has an active UIViewPropertyAnimator attached to it through Dance.
    func getHasAnimation(tag: Int) -> Bool {
        if let _ = animators[tag] {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Error Handling
    
    enum DanceError {
        case noAnimation
    }
    
    func handle(error: DanceError, forViewWithTag tag: Int) {
        switch error {
        case .noAnimation:
            print("\n** Dance Error: view \(tag) does not have an animation in progress! **\n")
        }
    }
}

// MARK: - Dance (should be accessed through UIView extension variable)

public class Dance {
    
    fileprivate var dancingView: UIView!
    
    fileprivate init(dancingView: UIView) {
        self.dancingView = dancingView
    }
    
    // MARK: Dance - UIViewPropertyAnimator Properties
    
    /// GET: Returns a boolean value of true if the view has an animation attached to it, and false otherwise.
    public var hasAnimation: Bool {
        get {
            return DanceFactory.instance.getHasAnimation(tag: dancingView.tag)
        }
    }
    
    /// GET: Returns a CGFloat value between 0 and 1 that inidicates the fraction value of the completion of the view's animation.
    /// SET: Sets the view's animation's fraction complete. If this is set in the middle of a running animation, the view will jump to it's new fraction complete value seamlessly.
    public var progress: CGFloat {
        get {
            return DanceFactory.instance.getFractionComplete(tag: dancingView.tag)
        }
        set {
            DanceFactory.instance.setFractionComplete(tag: dancingView.tag, newFractionComplete: newValue)
        }
    }
    
    /// GET: Returns the view's current animation state (inactive, active, stopped). Dance ensures that your animation doesn't run into any problems, so you should only ever receive .inactive or .active for any view.
    public var state: UIViewAnimatingState {
        get {
            return DanceFactory.instance.getState(tag: dancingView.tag)
        }
    }
    
    /// GET: Returns a boolean value indicating whether the view's animation is currently running (active and started) or not.
    public var isRunning: Bool {
        get {
            return DanceFactory.instance.getIsRunning(tag: dancingView.tag)
        }
    }
    
    /// GET: Returns a boolean value indicating whether the view's animation is currently reversed or not.
    /// SET: Sets the view's animation to a reversed state. NOTE: you may also call .reverse() on any view to reverse or de-reverse its animation.
    public var isReversed: Bool {
        get {
            return DanceFactory.instance.getIsReversed(tag: dancingView.tag)
        }
        set {
            DanceFactory.instance.setIsReversed(tag: dancingView.tag, isReversed: newValue)
        }
    }
    
    // MARK: Dance - UIViewPropertyAnimator Methods
    
    public typealias make = UIView
    
    /// Initializes a UIViewPropertyAnimator object with a built-in UIKit timing curve for the view.
    ///
    /// - Parameters:
    ///   - duration: The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
    ///   - curve: The UIKit timing curve to apply to the animation.
    ///            * easeInOut (slow at beginning and end)
    ///            * easeIn (slow at beginning)
    ///            * easeOut (slow at end)
    ///            * linear
    ///   - animation: Any changes to commit to the view during the animation (can be any property defined in Table 4-1 in https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/AnimatingViews/AnimatingViews.html)
    @discardableResult public func animate(duration: TimeInterval, curve: UIViewAnimationCurve, _ animation: @escaping (make) -> Void) -> Dance {
        
        if self.hasAnimation {
            DanceFactory.instance.finishAnimation(tag: dancingView.tag, at: .current)
        }
        
        dancingView.tag = DanceFactory.instance.tagCount
        DanceFactory.instance.tagCount += 1
        
        DanceFactory.instance.createNewAnimator(tag: dancingView.tag, duration: duration, curve: curve) {
            animation(self.dancingView)
        }
        
        return dancingView.dance
    }
    
    /// Initializes a UIViewPropertyAnimator object with a custom timing curve object for the view. See UITimingCurveProvider https://developer.apple.com/reference/uikit/uitimingcurveprovider
    ///
    /// - Parameters:
    ///   - duration: The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
    ///   - timingParameters: The object providing the timing information. This object must adopt the UITimingCurveProvider protocol https://developer.apple.com/reference/uikit/uitimingcurveprovider
    ///   - animation: Any changes to commit to the view during the animation (can be any property defined in Table 4-1 in https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/AnimatingViews/AnimatingViews.html)
    @discardableResult public func animate(duration: TimeInterval, timingParameters: UITimingCurveProvider, _ animation: @escaping (make) -> Void) -> Dance {
        
        if self.hasAnimation {
            DanceFactory.instance.finishAnimation(tag: dancingView.tag, at: .current)
        }
        
        dancingView.tag = DanceFactory.instance.tagCount
        DanceFactory.instance.tagCount += 1
        
        DanceFactory.instance.createNewAnimator(tag: dancingView.tag, duration: duration, timingParameters: timingParameters) {
            animation(self.dancingView)
        }
        
        return dancingView.dance
    }
    
    /// Initializes a UIViewPropertyAnimator object with a cubic Bézier timing curve for the view.
    ///
    /// - Parameters:
    ///   - duration: The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
    ///   - point1: The first control point for the cubic Bézier timing curve.
    ///   - point2: The second control point for the cubic Bézier timing curve.
    ///   - animation: Any changes to commit to the view during the animation (can be any property defined in Table 4-1 in https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/AnimatingViews/AnimatingViews.html)
    @discardableResult public func animate(duration: TimeInterval, controlPoint1 point1: CGPoint, controlPoint2 point2: CGPoint, _ animation: @escaping (make) -> Void) -> Dance {
        
        if self.hasAnimation {
            DanceFactory.instance.finishAnimation(tag: dancingView.tag, at: .current)
        }
        
        dancingView.tag = DanceFactory.instance.tagCount
        DanceFactory.instance.tagCount += 1
        
        DanceFactory.instance.createNewAnimator(tag: dancingView.tag, duration: duration, controlPoint1: point1, controlPoint2: point2) {
            animation(self.dancingView)
        }
        
        return dancingView.dance
    }
    
    /// Initializes a UIViewPropertyAnimator object with spring-based timing information for the view.
    ///
    /// - Parameters:
    ///   - duration: The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
    ///   - dampingRatio: The damping ratio for the spring animation as it approaches its quiescent state. To smoothly decelerate the animation without oscillation, use a value of 1. Employ a damping ratio closer to zero to increase oscillation.
    ///   - animation: Any changes to commit to the view during the animation (can be any property defined in Table 4-1 in https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/AnimatingViews/AnimatingViews.html)
    @discardableResult public func animate(duration: TimeInterval, dampingRatio: CGFloat, _ animation: @escaping (make) -> Void) -> Dance {
        
        if self.hasAnimation {
            DanceFactory.instance.finishAnimation(tag: dancingView.tag, at: .current)
        }
        
        dancingView.tag = DanceFactory.instance.tagCount
        DanceFactory.instance.tagCount += 1
        
        DanceFactory.instance.createNewAnimator(tag: dancingView.tag, duration: duration, dampingRatio: dampingRatio) {
            animation(self.dancingView)
        }
        
        return dancingView.dance
    }
    
    /// Adds a completion block to the view's current animation.
    ///
    /// - Parameter completion: closure with a UIViewAnimatingPosition parameter that tells you what position the view's animation is currently at (end, start, current). NOTE: If you reverse an animation, the end position will be the initial starting position before you reversed the animation (and vice versa.)
    @discardableResult public func addCompletion(_ completion: @escaping (UIViewAnimatingPosition) -> Void) -> Dance {
        DanceFactory.instance.addCompletion(tag: dancingView.tag, completion: completion)
        return dancingView.dance
    }
    
    /// Starts the animation for the view (must be called after declaring an animation block.)
    @discardableResult public func start() -> Dance {
        DanceFactory.instance.startAnimation(tag: dancingView.tag)
        return dancingView.dance
    }
    
    /// Starts the animation for the view after a delay (must be called after declaring an animation block.)
    ///
    /// - Parameter delay: The amount of time (measured in seconds) to wait before beginning the animations.
    @discardableResult public func start(after delay: TimeInterval) -> Dance {
        DanceFactory.instance.startAnimation(tag: dancingView.tag, afterDelay: delay)
        return dancingView.dance
    }
    
    /// Pauses the view's animation. The view is not rendered in a paused state, so make sure to call .finish(at:) on the view in order to render it at a desired position.
    @discardableResult public func pause() -> Dance {
        DanceFactory.instance.pauseAnimation(tag: dancingView.tag)
        return dancingView.dance
    }
    
    /// Pauses the view's animation after a delay. The view is not rendered in a paused state, so make sure to call .finish(at:) on the view in order to render it at a desired position.
    ///
    /// - Parameter delay: The amount of time (measured in seconds) to wait before pausing the animations.
    @discardableResult public func pause(after delay: TimeInterval) -> Dance {
        DanceFactory.instance.pauseAnimation(tag: dancingView.tag, afterDelay: delay)
        return dancingView.dance
    }
    
    /// Finished the view's current animation. Triggers the animation's completion blocks to take action immediately.
    ///
    /// - Parameter position: the position (current, start, end) to end the animation at. In other words, the position to render the view at after the animation.
    @discardableResult public func finish(at position: UIViewAnimatingPosition) -> Dance {
        DanceFactory.instance.finishAnimation(tag: dancingView.tag, at: position)
        return dancingView.dance
    }
    
    /// Reverses the animation. Calling .reverse() on an already reversed view animation will make it animate in the initial direction.
    /// Alternative to setting the .isReversed variable.
    @discardableResult public func reverse() -> Dance {
        let reversedState = DanceFactory.instance.getIsReversed(tag: dancingView.tag)
        DanceFactory.instance.setIsReversed(tag: dancingView.tag, isReversed: !reversedState)
        return dancingView.dance
    }
    
    /// Sets the view's animation's fraction complete. If this is set in the middle of a running animation, the view will jump to it's new fraction complete value seamlessly.
    /// Alternative to setting the .progress value.
    @discardableResult public func setProgress(to newProgress: CGFloatConvertable) -> Dance {
        progress = newProgress.convertToCGFloat()
        return dancingView.dance
    }
}



// MARK: - UIView Extension for Dance

@available(iOS 10.0, *)
extension UIView {
    public var dance: Dance {
        get {
            return ExtensionStoredPropertyHandler.associatedObject(base: self, key: &ExtensionStoredPropertyHandler.danceKey) {
                return Dance(dancingView: self)
            }
        }
        set {
            ExtensionStoredPropertyHandler.associateObject(base: self, key: &ExtensionStoredPropertyHandler.danceKey, value: newValue)
        }
    }
}

// MARK: - Boilerplate code to store properties in Extensions using Associated Objects

class ExtensionStoredPropertyHandler {
    static var danceKey: UInt8 = 0
    static func associatedObject<ValueType: AnyObject>(base: AnyObject, key: UnsafePointer<UInt8>, initialiser: () -> ValueType) -> ValueType {
        if let associated = objc_getAssociatedObject(base, key)
            as? ValueType { return associated }
        let associated = initialiser()
        objc_setAssociatedObject(base, key, associated, .OBJC_ASSOCIATION_RETAIN)
        return associated
    }
    static func associateObject<ValueType: AnyObject>(base: AnyObject, key: UnsafePointer<UInt8>, value: ValueType) {
        objc_setAssociatedObject(base, key, value, .OBJC_ASSOCIATION_RETAIN)
    }
}

// MARK: - CGFloatConvertable Extension for Double, Float, CGFloat
// (in order to accept non-CGFloats in setProgress(to:))

public protocol CGFloatConvertable {
    func convertToCGFloat() -> CGFloat
}

extension Double: CGFloatConvertable {
    public func convertToCGFloat() -> CGFloat {
        return CGFloat(self)
    }
}

extension Float: CGFloatConvertable {
    public func convertToCGFloat() -> CGFloat {
        return CGFloat(self)
    }
}

extension CGFloat: CGFloatConvertable {
    public func convertToCGFloat() -> CGFloat {
        return self
    }
}
