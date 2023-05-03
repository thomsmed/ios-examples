# Interactive Animations with UIViewPropertyAnimator

This sample app showcase how to use the awesome UIViewPropertyAnimator to drive interactive animations.
The UIViewPropertyAnimator can be started, paused, stopped, and manually progressed.

A few things to note about UIViewPropertyAnimator:
- [How to use gesture velocity together with spring timing parameters](https://developer.apple.com/documentation/uikit/uispringtimingparameters/1649909-initialvelocity).
- Having multiple active/running UIViewPropertyAnimators animating the same properties on the same UIView might cause unknown/unwanted behaviour. Therefore - if possible - either try group animations together in the same UIViewPropertyAnimator or create new animators when animating each animation (and throw away the old UIViewPropertyAnimator).
- The same can happen if having multiple animators with different timing parameters. A way to handle this might be to use UIViewPropertyAnimator together with keyframe-base animations. You can do that by calling UIView.animateKeyframes(withDuration:delay:options:animations:completion:), where the duration is set to 0 to inherit the timing parameters from the UIViewPropertyAnimator.
- I recommend checking out this awesome WWDC 2017 session on [Advanced Animations with UIKit](https://devstreaming-cdn.apple.com/videos/wwdc/2017/230lc4n1loob9/230/230_advanced_animations_with_uikit.pdf).
