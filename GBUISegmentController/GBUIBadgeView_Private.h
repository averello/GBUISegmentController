/*!
 *  @file GBUIBadgeView.h
 *  @brief Medocs
 *
 *  Created by @author George Boumis
 *  @date 2013/5/19.
 *  @copyright   Copyright (c) 2013 George Boumis <developer.george.boumis@gmail.com>. All rights reserved.
 */

@import UIKit;

@interface GBUIBadgeView () {
@protected
	struct {
		CGFloat minHeight;
		CGFloat capHeightFactor;
	} _options;
}

- (void)_init;
@end
