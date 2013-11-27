//
//  GBUISegmentControllerTests.m
//  GBUISegmentControllerTests
//
//  Created by George Boumis on 27/11/13.
//  Copyright (c) 2013 George Boumis <developer.george.boumis@gmail.com>. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GBUISegmentController.h"

@interface UIColor (Random)
+ (UIColor *)randomColor;
@end

@implementation UIColor (Random)
+ (UIColor *)randomColor {
	u_int32_t redValue = arc4random() % 256, greenValue = arc4random() % 256, blueValue = arc4random() % 256;
	return [UIColor colorWithRed:(redValue/255.0f) green:(greenValue/255.0f) blue:(blueValue/255.0f) alpha:1.0f];
}
@end

@interface GBUISegmentControllerTests : XCTestCase
@property (nonatomic, strong) GBUISegmentController *controller;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@end

@implementation GBUISegmentControllerTests

#define CONTROLLERS 3

- (void)setUp {
	[super setUp];
	
	self.controller = [[GBUISegmentController alloc] init];
	UIWindow *window = [UIApplication.sharedApplication.delegate window];
	window.rootViewController = self.controller;
	[window makeKeyAndVisible];
	
	self.viewControllers = [[NSMutableArray alloc] initWithCapacity:CONTROLLERS];
	UIViewController *controller = nil;
	for (NSInteger i=0; i<CONTROLLERS && (controller = [[UIViewController alloc] init]); i++, controller = nil) {
		controller.view.backgroundColor = [UIColor randomColor];
		[self.viewControllers addObject:controller];
	}
}

- (void)tearDown {
	[UIApplication.sharedApplication.delegate window].rootViewController = nil;
	self.controller = nil;
	self.viewControllers = nil;
	[super tearDown];
}

- (void)test1controller {
	XCTAssertNotNil(self.controller, @"The segment controller is 'nil'");
	XCTAssertNotNil([UIApplication.sharedApplication.delegate window].rootViewController, @"The segment controller is 'nil'");
	XCTAssertTrue(self.controller.selectedIndex == NSNotFound, @"The selected index is positioned with no viewControllers");
	XCTAssertNil(self.controller.viewControllers, @"The view controllers are not 'nil'");
	XCTAssertNil(self.controller.selectedViewController, @"The selected view controller is NOT 'nil'");
}

- (void)test2setViewControllers {
	self.controller.viewControllers = self.viewControllers;
	NSArray *viewControllers = self.controller.viewControllers;
	XCTAssertTrue(viewControllers.count==CONTROLLERS, @"The controllers do not correspond to the correct value");
	XCTAssertNotNil(self.controller.selectedViewController, @"The selected view controller is 'nil'");
	XCTAssertEqualObjects(self.controller.selectedViewController, self.viewControllers[0], @"The selected view controller differs");
	XCTAssertTrue(self.controller.selectedIndex == 0, @"The selected index is NOT '0'");
	
	[viewControllers enumerateObjectsUsingBlock:^(UIViewController *controller, NSUInteger idx, BOOL *stop) {
		XCTAssertEqualObjects(controller, self.viewControllers[idx], @"The view controllers are not in the same order");
	}];
}

- (void)test3changeSelection {
	self.controller.viewControllers = self.viewControllers;
	self.controller.selectedIndex = self.controller.selectedIndex+1;
	XCTAssertTrue(self.controller.selectedIndex == 1, @"The selected index is NOT '1'");
	
	//	self.controller.selectedIndex = self.controller.selectedIndex+1;
	//	XCTAssertTrue(self.controller.selectedIndex == 2, @"The selected index is NOT '2'");
	//	XCTAssertThrows(self.controller.selectedIndex = self.controller.selectedIndex+1, @"The selected index IS '3'");
}

@end
