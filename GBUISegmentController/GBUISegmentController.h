/*!
 *  @file GBUISegmentController.h
 *  @brief A segmented control based container controller.
 *
 *  Created by @author George Boumis
 *  @date 2013/5/26.
 *  @version 1.0
 *  @copyright   Copyright (c) 2013 George Boumis <developer.george.boumis@gmail.com>. All rights reserved.
 *  @defgroup sc
 */

@import UIKit;

@class GBUISegmentController;
/*!
 @protocol GBUISegmentControllerDelegate
 @related sc
 @public
 @brief The protocol a segment controller delegate should respect.
 @details You use the @a GBUISegmentControllerDelegate protocol when you want to augment the behavior of a segment controller. In particular, you can use it to determine whether specific segmnets should be selected or to perform actions after a segment is selected. After implementing these methods in your custom object, you should then assign that object to the delegate property of the corresponding @ref GBUISegmentController object.
 All of the methods in this protocol are optional.
 */
@protocol GBUISegmentControllerDelegate <NSObject>
@optional
/*
 @public
 @related sc
 @brief Asks the delegate for the title the specified view controller should have.
 @details The segment controller calls this method 
 */
//- (NSString *)segmentViewController:(GBUISegmentController *)segmentController titleForViewControllerAtIndex:(NSUInteger)index;
/*!
 @public
 @related sc
 @brief Asks the delegate whether the specified view controller should be made active.
 @details The segment controller calls this method in response to the user tapping a segmented control item. You can use this method to dynamically decide whether a given segment should be made the active segment.
 @param[in] segmentController The segment controller containing @a viewController.
 @param[in] viewController The view controller belonging to the segment that was tapped by the user.
 @returns @a YES if the view controller’s segment should be selected or @a NO if the current segment should remain active.
 */
- (BOOL)segmentViewController:(GBUISegmentController *)segmentController shouldSelectViewController:(UIViewController *)viewController;
/*!
 @public
 @related sc
 @brief Tells the delegate that the user selected item will be selected in the semgented control.
 @details The segment controller calls this method in response to user taps in the segmented control and is **also** called when your code changes the selected controller programmatically. This method is *not* called if the selected controller changes either by your code or by the user re-selecting the same segment. The segment controller calls this after invoking `segmentViewController:shouldSelectViewController`.
 @param[in] segmentController The segment controller containing @a viewController.
 @param[in] viewController The view controller that the user selected.
 */
- (void)segmentViewController:(GBUISegmentController *)segmentController willSelectViewController:(UIViewController *)viewController;
/*!
 @public
 @related sc
 @brief Tells the delegate that the user selected an item in the semgented control.
 @details The segment controller calls this method in response to user taps in the segmented control and is **also** called when your code changes the selected controller programmatically. This method is not called if the selected controller changes either by your code or by the user re-selecting the same segment.
 @param[in] segmentController The segment controller containing @a viewController.
 @param[in] viewController The view controller that the user selected.
 */
- (void)segmentViewController:(GBUISegmentController *)segmentController didSelectViewController:(UIViewController *)viewController;
@end

/*!
 @public
 @enum GBUISegmentControllerTransitionDirection
 @related sc
 @brief The enumeration indicating the direction of a transition.
 
 */
typedef NS_ENUM(NSInteger, GBUISegmentControllerTransitionDirection) {
	GBUISegmentControllerTransitionDirectionLeft = -1, /*!< This option indicates that the transition is happening with a direction from right to left. */
	GBUISegmentControllerTransitionDirectionRight = 1, /*!< This option indicates that the transition is happening with a direction from left to right. */
};

/*!
 @public
 @related nru
 @brief The custom animation block to be called when a transition should occur.
 @details If you provide a block then the segment control will call this block when the user selects a segment or your code changes the selected controller. This block is a way to create your custom transition/animation by calling for example `transitionFromViewController:toViewController:duration:options:animations:completion:`. See alse @ref transitionAnimationOptions.
 @param[in] sourceViewController the view controller that was previously selected.
 @param[in] destinationViewController the view controller that the user or your code selected.
 @param[in] direction the direction of the transition. It's is just an indication.
 @param[in] completion a block to be called imperatively after finishing the transition.
 @warning Not calling the completion block leads to unexpected behaviour.
 */
typedef void (^GBUISegmentControllerTransitionAnimationBlock)(UIViewController *sourceViewController, UIViewController *destinationViewController, GBUISegmentControllerTransitionDirection direction, void (^completion)(BOOL finished));

/*!
 */
NS_CLASS_AVAILABLE_IOS(6_0) @interface GBUISegmentController : UIViewController

/*!
 @public
 @related sc
 @brief An array of the root view controllers displayed by the segmented control interface.
 @details If you change the value of this property at runtime, the segment controller removes all of the old view controllers before installing the new ones. The segmented control items for the new view controllers are displayed immediately and are not animated into position. When changing the view controllers, the segment controller remembers the view controller object that was previously selected and attempts to reselect it. If the selected view controller is no longer present, it attempts to select the view controller at the same index in the array as the previous selection. If that index is invalid, it selects the view controller at index 0.
 */
@property (nonatomic, copy) IBOutletCollection(UIViewController) NSArray *viewControllers;
/*!
 @public
 @related sc
 @brief The view controller associated with the currently selected segmented control item.
 @details This view controller is the one whose custom view is currently displayed by the segmented control interface. The specified view controller must be in the @ref viewControllers array. Assigning a new view controller to this property changes the currently displayed view and also selects an appropriate segment in the segmented control. Changing the view controller also updates the @ref selectedIndex property accordingly. The default value of this property is nil.
 */
@property (nonatomic, assign) UIViewController *selectedViewController;
/*!
 @public
 @related sc
 @brief The index of the view controller associated with the currently selected segment item.
 @details This property nominally represents an index into the array of the @ref viewControllers property. However, if the selected view controller is nil or the @ref viewController the value is NSNotFound. Setting this property changes the selected view controller to the one at the designated index in the viewControllers array.
 */
@property (nonatomic) NSUInteger selectedIndex;
/*!
 @public
 @related sc
 @brief The segment controller's delegate object.
 @details You can use the delegate object to track changes to the items in the segement controller and to monitor the selection of segments. The delegate object you provide should conform to the @ref GBUISegmentControllerDelegate protocol. The default value for this property is nil.
 */
@property (nonatomic, weak) id<GBUISegmentControllerDelegate> delegate;
/*!
 @public
 @related sc
 @brief The segment controller's animation options.
 @details You can use the the animation options so you can specify the default animation when transition controllers either programmatically or when the user taps the semgent item.
 */
@property (nonatomic, readwrite) UIViewAnimationOptions transitionAnimationOptions;
/*!
 @public
 @related sc
 @brief The segment controller's custom animation block.
 @details You can use the the transition animation block so you can specify provide your custom animation of the transition.
 */
@property (nonatomic, copy) GBUISegmentControllerTransitionAnimationBlock transitionAnimationBlock;

/*!
 @public
 @related sc
 @brief Sets the badge value for a specific view controller.
 @details
 @param[in] badgeValue The badge value.
 @param[in] index The index of the view controller.
 */
- (void)setBadgeValue:(NSInteger)badgeValue forViewControllerAtIndex:(NSUInteger)index;
/*!
 @public
 @related sc
 @brief Sets the root view controllers of the segment controller.
 @details When you assign a new set of view controllers at runtime, the segment controller removes all of the old view controllers before installing the new ones. When changing the view controllers, the segment controller remembers the view controller object that was previously selected and attempts to reselect it. If the selected view controller is no longer present, it attempts to select the view controller at the same index in the array as the previous selection. If that index is invalid, it selects the view controller at index 0.
 @param[in] viewControllers The array of custom view controllers to display in the segmented control interface. The order of the view controllers in this array corresponds to the display order in the segmented control, with the controller at index 0 representing the left-most item, the controller at index 1 the next item to the right, and so on.
 @param[in] animated If @a YES, the segmnted control items for the view controllers are animated into position. If @a NO, changes to the segmented control items are reflected immediately.
 */
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

@end

@interface UIViewController (GBUISegmentController)
@property (nonatomic, readonly, strong) GBUISegmentController *segmentController;
@property (nonatomic, readonly, strong) UISegmentedControl *segmentControl;
@property (nonatomic, copy) NSString *segmentedTitle;
@end


