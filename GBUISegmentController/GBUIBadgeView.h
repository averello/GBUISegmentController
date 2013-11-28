/*!
 *  @file GBUIBadgeView.h
 *  @brief Medocs
 *
 *  Created by @author George Boumis
 *  @date 2013/5/19.
 *  @copyright   Copyright (c) 2013 George Boumis <developer.george.boumis@gmail.com>. All rights reserved.
 */

#import <UIKit/UIKit.h>

@interface GBUIBadgeView : UILabel
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *decorationColor;
@property (nonatomic) CGFloat strokeSize;
@end
