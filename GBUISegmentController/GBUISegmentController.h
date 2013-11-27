/*!
 *  @file GBUISegmentController.h
 *  @brief Medocs
 *
 *  Created by @author George Boumis
 *  @date 19/5/13.
 *  @copyright   Copyright (c) 2013 George Boumis <developer.george.boumis@gmail.com>. All rights reserved.
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GBUISegmentControllerTransitionDirection) {
	GBUISegmentControllerTransitionDirectionLeft = -1,
	GBUISegmentControllerTransitionDirectionRight = 1,
};

@class GBUISegmentController;
@protocol GBUISegmentControllerDelegate <NSObject>
@optional
- (NSString *)segmentViewController:(GBUISegmentController *)segmentController titleForViewControllerAtIndex:(NSUInteger)index;
- (BOOL)segmentViewController:(GBUISegmentController *)segmentController shouldSelectViewController:(UIViewController *)viewController;
- (void)segmentViewController:(GBUISegmentController *)segmentController willSelectViewController:(UIViewController *)viewController;
- (void)segmentViewController:(GBUISegmentController *)segmentController didSelectViewController:(UIViewController *)viewController;
@end

NS_CLASS_AVAILABLE_IOS(6_0) @interface GBUISegmentController : UIViewController

//@property (nonatomic, strong, readonly) UISegmentedControl *segmentedControl;
@property (nonatomic, copy) IBOutletCollection(UIViewController) NSArray *viewControllers;
@property (nonatomic, assign) UIViewController *selectedViewController;
@property (nonatomic) NSUInteger selectedIndex;

@property (nonatomic, weak) id<GBUISegmentControllerDelegate> delegate;

@property (nonatomic, readwrite) UIViewAnimationOptions transitionAnimationOptions;
@property (nonatomic, copy) void (^transitionAnimationBlock)(UIViewController *sourceViewController, UIViewController *destinationViewController, GBUISegmentControllerTransitionDirection direction, void (^completion)(BOOL finished));

- (void)setBadgeValue:(NSInteger)badgeValue forViewControllerAtIndex:(NSUInteger)index;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

@end

@interface UIViewController (GBUISegmentController)
@property (nonatomic, readonly, strong) GBUISegmentController *segmentController;
@property (nonatomic, readonly, strong) UISegmentedControl *segmentControl;
@property (nonatomic, copy) NSString *segmentedTitle;
@end


