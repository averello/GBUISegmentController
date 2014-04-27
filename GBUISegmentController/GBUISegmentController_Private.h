/*
 *  @file GBUISegmentController_Private.h
 *  @brief A segmented control based container controller.
 *	@private
 *
 *  Created by @author George Boumis
 *  @date 2013/5/26.
 *  @copyright   Copyright (c) 2013 George Boumis <developer.george.boumis@gmail.com>. All rights reserved.
 */

#import "GBUISegmentController/GBUISegmentController.h"

@interface GBUISegmentController ()
@property (nonatomic, strong) UIToolbar *topToolbar;

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIBarButtonItem *segmentedControlBarButtonItem;
@end
