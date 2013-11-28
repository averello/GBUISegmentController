/*
 *  @file GBUISegmentController.m
 *  @brief Medocs
 *
 *  Created by @author George Boumis
 *  @date 2013/5/19.
 *  @copyright   Copyright (c) 2013 George Boumis <developer.george.boumis@gmail.com>. All rights reserved.
 */

#import "GBUISegmentController.h"
#import "GBUISegmentController_Private.h"
#import "GBUIBadgeView.h"
#import <objc/runtime.h>

#define kBadgeViewKey @"kBadgeViewKey"
#define kBadgeViewHorizontalConstraintKey @"kBadgeViewHorizontalConstraintKey"
#define kBadgeViewVerticalConstraintKey @"kBadgeViewVerticalConstraintKey"

@interface UIViewController ()
@property (nonatomic, strong) GBUISegmentController *segmentController;
@end

@interface GBUISegmentController () {
	@protected
	struct {
		CGFloat toolbarHeight;
		CGFloat horizontalSegmentedControlMargin;
		CGFloat verticalSegmentedControlMargin;
		CGFloat transitionDuration;
		CGFloat transitionDelay;
		CGFloat segmentedControlHeight;
		CGFloat badgeTopOffset;
		UIViewAnimationOptions transitionAnimationOptions;
	} _options;
	
	struct {
		unsigned int animating:1;
	} _flags;
}

@property (nonatomic, strong) UIView *containerView;


@property (nonatomic, readonly, copy) NSArray *constrainsForSubviews;
@property (nonatomic, readonly, copy) NSArray *selectedViewControllerConstraints;

@property (nonatomic, strong) void(^didSelectViewControllerDelagateBlock)(BOOL finished, UIViewController *destinationViewController);
@property (nonatomic, strong) void(^willSelectViewControllerDelagateBlock)(UIViewController *destinationViewController);
@property (nonatomic, strong) BOOL(^shouldSelectViewControllerDelagateBlock)(UIViewController *destinationViewController);

@property (nonatomic, strong) NSMutableArray *badgeViews;
@end

@implementation GBUISegmentController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		[self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self _init];
	}
	return self;
}

- (id)init {
	self = [super init];
	if (self) {
		[self _init];
	}
	return self;
}

- (void)_init {
	_viewControllers = nil;
	_badgeViews = nil;
	_selectedIndex = NSNotFound;
	
	_options.horizontalSegmentedControlMargin = 7.0f;
	_options.verticalSegmentedControlMargin = 7.0f;
	_options.toolbarHeight = 42.0f;
	_options.segmentedControlHeight = 25.0f;
	_options.transitionDuration = 0.45f;
	_options.badgeTopOffset = -5.0f;
	
	_options.transitionAnimationOptions = UIViewAnimationOptionTransitionCrossDissolve;
	
	__weak typeof(self) weakSelf = self;
	_shouldSelectViewControllerDelagateBlock = ^BOOL(UIViewController *destinationViewController) {
		if ([weakSelf.delegate respondsToSelector:@selector(segmentViewController:shouldSelectViewController:)])
			return [weakSelf.delegate segmentViewController:weakSelf shouldSelectViewController:destinationViewController];
		return YES;
	};
	_didSelectViewControllerDelagateBlock = ^(BOOL finished, UIViewController *destinationViewController) {
		if ([weakSelf.delegate respondsToSelector:@selector(segmentViewController:didSelectViewController:)])
			[weakSelf.delegate segmentViewController:weakSelf didSelectViewController:destinationViewController];
	};
	_willSelectViewControllerDelagateBlock = ^(UIViewController *destinationViewController) {
		if ([weakSelf.delegate respondsToSelector:@selector(segmentViewController:willSelectViewController:)])
			[weakSelf.delegate segmentViewController:weakSelf didSelectViewController:destinationViewController];
	};
}

- (void)loadView {
	@autoreleasepool {
		UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
		if (self.parentViewController==nil)
			view.translatesAutoresizingMaskIntoConstraints = NO;
				
		_topToolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
		_segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectZero];
//		_segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
		[_segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:(UIControlEventValueChanged)];
		
		_containerView = [[UIView alloc] initWithFrame:CGRectZero];
		_segmentedControlBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_segmentedControl];
		
		
		_topToolbar.translatesAutoresizingMaskIntoConstraints = NO;
		_segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
		_containerView.translatesAutoresizingMaskIntoConstraints = NO;
		
		_segmentedControl.apportionsSegmentWidthsByContent = YES;
				
		_topToolbar.items = @[_segmentedControlBarButtonItem];

		[view addSubview:_topToolbar];
		[view addSubview:_containerView];
		self.view = view;
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view addConstraints:self.constrainsForSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateViewConstraints {
	[super updateViewConstraints];
	@autoreleasepool {
		[self.view removeConstraints:self.view.constraints];
		[self.view addConstraints:self.constrainsForSubviews];
	}
}

#pragma mark - constrains

- (NSArray *)constrainsForSubviews  {
	@autoreleasepool {
		NSDictionary *bindings = NSDictionaryOfVariableBindings(/*_segmentsScrollView*/ _topToolbar, _containerView, _segmentedControl);
		NSDictionary *metrics = @{ @"height" : @(_options.toolbarHeight), @"Hmargin" : @(_options.horizontalSegmentedControlMargin), @"Vmargin" : @(_options.verticalSegmentedControlMargin), @"segmentHeight" : @(_options.segmentedControlHeight) };
		NSArray *toolbarHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topToolbar]|" options:(0) metrics:nil views:bindings];
		NSArray *viewVerticalContraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topToolbar(height)][_containerView]|" options:(0) metrics:metrics views:bindings];
		NSArray *containerViewHorizontalContraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_containerView]|" options:(0) metrics:nil views:bindings];
		NSArray *segmentedControlHorizontalConstrains = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(Hmargin)-[_segmentedControl]-(Hmargin)-|" options:(NSLayoutFormatAlignAllCenterY) metrics:metrics views:bindings];
		NSArray *segmentedControlVerticalConstrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(Vmargin)-[_segmentedControl(>=segmentHeight)]-(Vmargin)-|" options:(NSLayoutFormatAlignAllCenterY) metrics:metrics views:bindings];
		
		NSMutableArray *constraints = [[NSMutableArray alloc] initWithCapacity:0
									   + toolbarHorizontalConstraints.count
									   + viewVerticalContraints.count
									   + containerViewHorizontalContraints.count
									   + segmentedControlHorizontalConstrains.count
									   + segmentedControlVerticalConstrains.count
									   ];
		[constraints addObjectsFromArray:viewVerticalContraints];
		[constraints addObjectsFromArray:containerViewHorizontalContraints];
		[constraints addObjectsFromArray:toolbarHorizontalConstraints];
		[constraints addObjectsFromArray:segmentedControlHorizontalConstrains];
		[constraints addObjectsFromArray:segmentedControlVerticalConstrains];
		return constraints.copy;
	}
}

- (NSArray *)selectedViewControllerConstraints {
	@autoreleasepool {
		NSDictionary *bindings = @{ @"_selectedViewControllerView" : _selectedViewController.view };
		
		NSArray *horizontalContraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_selectedViewControllerView]|" options:(0) metrics:nil views:bindings];
		NSArray *verticalContraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_selectedViewControllerView]|" options:(0) metrics:nil views:bindings];
		
		NSMutableArray *constraints = [[NSMutableArray alloc] initWithCapacity:horizontalContraints.count + verticalContraints.count];
		[constraints addObjectsFromArray:horizontalContraints];
		[constraints addObjectsFromArray:verticalContraints];
		return constraints.copy;
	}
}

#pragma mark - segmented control

- (void)segmentedControlValueChanged:(UISegmentedControl *)segmentedControl {
	if (_selectedIndex == segmentedControl.selectedSegmentIndex)
		return;
	if (_flags.animating) {
		segmentedControl.selectedSegmentIndex = _selectedIndex;
		return;
	}
	self.selectedIndex = segmentedControl.selectedSegmentIndex;
}

#pragma mark -

-(void)setViewControllers:(NSArray *)viewControllers {
	[self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
	@autoreleasepool {
		/* If the view is not loaded, then proceed with loading */
		if (!self.isViewLoaded)
			[self loadView];
		
		UIViewController *previouslySelectedViewController = _selectedViewController;
		NSInteger previouslySelectedViewControllerIndex = _selectedIndex;
		/* We are setting all the controllers so remove the selected one */
		[self removeSelectedViewController];
		
		[_viewControllers makeObjectsPerformSelector:@selector(setSegmentController:) withObject:nil];
		
		/* Remove all segments */
		[_segmentedControl removeAllSegments];
		for (NSMutableDictionary *badgeAttributes in _badgeViews)
			[badgeAttributes[kBadgeViewKey] removeFromSuperview];
		_badgeViews = nil;
		
		/* Copy the array */
		_viewControllers = viewControllers.copy;
		
		/* If the array is empty then return */
		if ( _viewControllers.count == 0) {
			_selectedIndex = NSNotFound;
			_selectedViewController = nil;
			_viewControllers = nil;
			return;
		}
		
		if (nil==_badgeViews)
			_badgeViews = [[NSMutableArray alloc] initWithCapacity:_viewControllers.count];
		
		/* Add all segments */
		NSInteger i=0;
		for (UIViewController *controller in _viewControllers) {
			GBUIBadgeView *badgeView = [[GBUIBadgeView alloc] initWithFrame:CGRectZero];
			badgeView.translatesAutoresizingMaskIntoConstraints = NO;
			NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
			dictionary[kBadgeViewKey] = badgeView;
			[_badgeViews addObject:dictionary];
			
			NSString *title = @"";//[self.delegate segmentViewController:self titleForViewControllerAtIndex:i];
			[_segmentedControl insertSegmentWithTitle:title atIndex:i++ animated:animated];
			controller.segmentController = self;
		}
		
		/* Selected index by default 0 */
		_selectedIndex = 0;
		
		/* Re-select the last selected controller if present in the current view controllers array or the same index */
		if (nil!=previouslySelectedViewController) {
			NSInteger previouslySelectedViewControllerCurrentIndex = [_viewControllers indexOfObject:previouslySelectedViewController];
			if (previouslySelectedViewControllerCurrentIndex!=NSNotFound)
				_selectedIndex = previouslySelectedViewControllerCurrentIndex;
			else if (previouslySelectedViewControllerIndex < _viewControllers.count)
				_selectedIndex = previouslySelectedViewControllerIndex;
		}
		
		_segmentedControl.selectedSegmentIndex = _selectedIndex;
		_selectedViewController = _viewControllers[_selectedIndex];
		
		
		/* Add the child view controller */
		[self addChildViewController:_selectedViewController];
		_selectedViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
		if (animated) {
			[UIView animateWithDuration:_options.transitionDuration delay:_options.transitionDelay options:(_options.transitionAnimationOptions) animations:^{
				[self.view addSubview:_selectedViewController.view];
			} completion:^(BOOL finished) {
				if (finished) {
					[_selectedViewController didMoveToParentViewController:self];
					[_containerView addConstraints:self.selectedViewControllerConstraints];
				}
			}];
		}
		else {
			[_containerView addSubview:_selectedViewController.view];
			[_selectedViewController didMoveToParentViewController:self];
			
			/* Add the constraints */
			[_containerView addConstraints:self.selectedViewControllerConstraints];
		}
	}
}

- (void)removeSelectedViewController {
	if (_selectedViewController) {
		/* Remove the child */
		[_selectedViewController willMoveToParentViewController:nil];
		[_selectedViewController.view removeFromSuperview];
		[_selectedViewController removeFromParentViewController];
		_selectedViewController = nil;
		_selectedIndex = NSNotFound;
	}
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
	if (_flags.animating)
		return;
	
	if (nil==_viewControllers)
		return;
	NSUInteger count = _viewControllers.count;
	if (_selectedIndex==selectedIndex)
		return;
	if (count==0)
		return;
	NSAssert(selectedIndex<count, @"The selected index is out of bounds");
	if (selectedIndex >= count)
		return;
	
	/* Find the source and the destination controllers */
	UIViewController *sourceViewController = _selectedViewController;
	UIViewController *destinationViewController = _viewControllers[selectedIndex];
	
	/* Ask the delegate if the selection is permitted */
	if (!_shouldSelectViewControllerDelagateBlock(destinationViewController)) {
		_segmentedControl.selectedSegmentIndex = _selectedIndex;
		return;
	}
	
	/* Indicate animations to prevent problems with very rapid selection */
	_flags.animating = 1;
	
	/* Find the direction of the transition */
	GBUISegmentControllerTransitionDirection direction;
	if (_selectedIndex<selectedIndex)
		direction = GBUISegmentControllerTransitionDirectionRight;
	else
		direction = GBUISegmentControllerTransitionDirectionLeft;
	
	_willSelectViewControllerDelagateBlock(destinationViewController);
	
	_selectedIndex = selectedIndex;
	_selectedViewController = destinationViewController;
	
	_didSelectViewControllerDelagateBlock(nil==_transitionAnimationBlock, destinationViewController);
	
	/* Transition */
	[self performTransitionFromViewController:sourceViewController toViewController:destinationViewController direction:direction completion:_didSelectViewControllerDelagateBlock];
}

- (void)performTransitionFromViewController:(UIViewController *)sourceViewController toViewController:(UIViewController *)destinationViewController direction:(GBUISegmentControllerTransitionDirection)direction completion:(void(^)(BOOL finished, UIViewController *destinationViewController))didSelectViewControllerDelagateBlock {
	
	[sourceViewController willMoveToParentViewController:nil];
	[self addChildViewController:destinationViewController];
	destinationViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
	
	/* If custom animation is provided then used it */
	if (_transitionAnimationBlock) {
		[_containerView insertSubview:destinationViewController.view aboveSubview:sourceViewController.view];
		_transitionAnimationBlock(sourceViewController, destinationViewController, direction, ^(BOOL finished) {
			_flags.animating = 0;
			didSelectViewControllerDelagateBlock(finished, destinationViewController);
		});
		
		[sourceViewController removeFromParentViewController];
		[destinationViewController didMoveToParentViewController:self];
		[_containerView addConstraints:self.selectedViewControllerConstraints];
	}
	else {
		/* If no custom animation provided then animate according to the options */
		[self transitionFromViewController:sourceViewController toViewController:destinationViewController duration:_options.transitionDuration options:(_options.transitionAnimationOptions) animations:^{
			[_containerView addConstraints:self.selectedViewControllerConstraints];
			[_containerView bringSubviewToFront:destinationViewController.view];
		} completion:^(BOOL finished) {
			[sourceViewController removeFromParentViewController];
			[destinationViewController didMoveToParentViewController:self];
			[self.view bringSubviewToFront:_topToolbar];
			_flags.animating = 0;
		}];
		
		//		[UIView transitionFromView:sourceViewController.view toView:destinationViewController.view duration:_options.transitionDuration options:(_options.transitionAnimationOptions) completion:^(BOOL finished) {
		//			if (finished) {
		//				[sourceViewController removeFromParentViewController];
		//				[destinationViewController didMoveToParentViewController:self];
		//				[_containerView addConstraints:self.selectedViewControllerConstraints];
		//			}
		//		}];
	}
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
	if (nil==_viewControllers)
		return;
	NSAssert(selectedViewController != nil, @"The selected view controller should not be 'nil'");
	if (nil==selectedViewController) return;
	
	if (![_viewControllers containsObject:selectedViewController]) {
		NSAssert(NO, @"The selected view controller does not exist");
		[NSException raise:NSInvalidArgumentException format:@"-[%@ %@] only a view controller in the segment controller's list of view controllers can be selected.", self.class, NSStringFromSelector(_cmd)];
		return;
	}
	
	self.selectedIndex = [_viewControllers indexOfObject:selectedViewController];
	_segmentedControl.selectedSegmentIndex = _selectedIndex;
}

- (void)setBadgeValue:(NSInteger)badgeValue forViewControllerAtIndex:(NSUInteger)index {
	@autoreleasepool {
		if (nil==_viewControllers)
			return;
		NSAssert(index<_viewControllers.count, @"The controller index should be in bounds");
		if (nil==_badgeViews)
			return;
		
		NSMutableDictionary *attributes = _badgeViews[index];
		GBUIBadgeView *badgeView = attributes[kBadgeViewKey];
		badgeView.text = @(badgeValue).stringValue;
		
		NSLayoutConstraint *horizontalPlacementConstraint = nil;
		NSLayoutConstraint *verticalPlacementConstraint = nil;
		
		CGFloat segmentedControlWidth = CGRectGetWidth(_topToolbar.bounds) - (_options.horizontalSegmentedControlMargin * 2);
		CGSize badgeSize = badgeView.intrinsicContentSize;
		CGFloat individualSegmentWidth = segmentedControlWidth / _segmentedControl.numberOfSegments;
		CGFloat leftX = _options.horizontalSegmentedControlMargin + ((index+1) * individualSegmentWidth) - badgeSize.width;

		if (nil==badgeView.superview) {
			[_topToolbar addSubview:badgeView];

			horizontalPlacementConstraint = [NSLayoutConstraint constraintWithItem:badgeView attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:_topToolbar attribute:(NSLayoutAttributeLeft) multiplier:1.0f constant:leftX];
			verticalPlacementConstraint = [NSLayoutConstraint constraintWithItem:badgeView attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:_segmentedControl attribute:(NSLayoutAttributeTop) multiplier:1.0f constant:_options.badgeTopOffset];
			
			attributes[kBadgeViewHorizontalConstraintKey] = horizontalPlacementConstraint;
			attributes[kBadgeViewVerticalConstraintKey] = verticalPlacementConstraint;
			
			[_topToolbar addConstraint:horizontalPlacementConstraint];
			[_topToolbar addConstraint:verticalPlacementConstraint];
		}
		else {
			horizontalPlacementConstraint = attributes[kBadgeViewHorizontalConstraintKey];
			horizontalPlacementConstraint.constant = leftX;
		}
	}
}

- (UIViewAnimationOptions)transitionAnimationOptions {
	return _options.transitionAnimationOptions;
}

- (void)setTransitionAnimationOptions:(UIViewAnimationOptions)transitionAnimationOptions {
	_options.transitionAnimationOptions = transitionAnimationOptions;
	if (transitionAnimationOptions == UIViewAnimationTransitionNone)
		_options.transitionDuration = 0.0f, _options.transitionDelay = 0.0f;
	else
		_options.transitionDuration = 0.45f, _options.transitionDelay = 0.0f;
}

@end

#undef kBadgeViewKey
#undef kBadgeViewHorizontalConstraintKey
#undef kBadgeViewVerticalConstraintKey

static NSString const * const GBUISegmentControllerProperty = @"kGBUISegmentControllerProperty";

@implementation UIViewController (GBUISegmentController)
@dynamic segmentController;
@dynamic segmentControl;
@dynamic segmentedTitle;

- (GBUISegmentController *)segmentController {
	return objc_getAssociatedObject(self, &GBUISegmentControllerProperty);
}

- (void)setSegmentController:(GBUISegmentController *)segmentController {
	objc_setAssociatedObject(self, &GBUISegmentControllerProperty, segmentController, OBJC_ASSOCIATION_RETAIN);
}

- (UISegmentedControl *)segmentControl {
	return self.segmentController.segmentedControl;
}

- (NSString *)segmentedTitle {
	GBUISegmentController *segmentController = self.segmentController;
	if (nil==segmentController)
		return nil;
	
	NSUInteger index = [segmentController.viewControllers indexOfObject:self];
	if (index == NSNotFound)
		return nil;
	return [segmentController.segmentedControl titleForSegmentAtIndex:index];
}

- (void)setSegmentedTitle:(NSString *)segmentedTitle {
	GBUISegmentController *segmentController = self.segmentController;
	if (nil==segmentController)
		return;
	
	NSUInteger index = [segmentController.viewControllers indexOfObject:self];
	if (index == NSNotFound)
		return;
	
	[segmentController.segmentedControl setTitle:segmentedTitle forSegmentAtIndex:index];
}

@end
