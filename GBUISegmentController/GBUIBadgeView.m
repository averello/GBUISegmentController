/*!
 *  @file GBUIBadgeView.m
 *  @brief Medocs
 *
 *  Created by @author George Boumis
 *  @date 19/5/13.
 *  @copyright   Copyright (c) 2013 George Boumis <developer.george.boumis@gmail.com>. All rights reserved.
 */

#import "GBUIBadgeView.h"
#import <QuartzCore/QuartzCore.h>

#include <mach/mach_time.h>

@interface GBUIBadgeView () {
	@protected
	struct {
		CGFloat minHeight;
		CGFloat capHeightFactor;
	} _options;
}
@end

@implementation GBUIBadgeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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
	@autoreleasepool {
		_options.minHeight = 15.0f;
		_options.capHeightFactor = 1.5f;
		
		self.backgroundColor = UIColor.clearColor;
		_fillColor = [UIColor colorWithRed:(0xB2/255.0f) green:(0x38/255.0f) blue:(0x2A/255.0f) alpha:1.0f];
		_strokeColor = [UIColor colorWithRed:(0x11/255.0f) green:(0x19/255.0f) blue:(0x17/255.0f) alpha:1.0f];
		_decorationColor = [UIColor colorWithRed:(0xB8/255.0f) green:(0x45/255.0f) blue:(0x40/255.0f) alpha:1.0f];
		_strokeSize = 1.0f;
		
		self.textColor = [UIColor colorWithRed:(0xFF/255.0f) green:(0xFE/255.0f) blue:(0xFE/255.0f) alpha:1.0f];
		self.textAlignment = NSTextAlignmentCenter;
		self.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		self.shadowOffset = CGSizeMake(0.0f, -1.0f);
		self.shadowColor = UIColor.blackColor;
		
		self.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:9.0f];
		self.layer.contentsScale = UIScreen.mainScreen.scale;
	}
}

//*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	mach_timebase_info_data_t info;
	mach_timebase_info(&info);
	uint64_t drawStart = mach_absolute_time(), drawEnd;
	
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetFillColorWithColor(context, _fillColor.CGColor);
	CGContextSetStrokeColorWithColor(context, _strokeColor.CGColor);
	
	CGContextSetLineWidth(context, _strokeSize);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGFloat inset = _strokeSize;
	CGRect insetedRect = CGRectInset(rect, inset, inset);
	CGRect insetedRect2 = CGRectInset(insetedRect, inset, inset);
	
	@autoreleasepool {
		UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:insetedRect cornerRadius:CGRectGetHeight(insetedRect)/2.0f];
		path.lineCapStyle = kCGLineCapRound;
		path.lineJoinStyle = kCGLineJoinRound;
		path.lineWidth = _strokeSize;
		[path stroke];
		[path fill];
		path = nil;

		path = [UIBezierPath bezierPathWithRoundedRect:insetedRect2 cornerRadius:CGRectGetHeight(insetedRect2)/2.0f];
		path.lineCapStyle = kCGLineCapRound;
		path.lineJoinStyle = kCGLineJoinRound;
		path.lineWidth = _strokeSize;
		CGContextSetStrokeColorWithColor(context, _decorationColor.CGColor);
		[path stroke];
		path = nil;
	}
		
	CGContextSetFillColorWithColor(context, self.textColor.CGColor);
	[self drawTextInRect:insetedRect];
	
	drawEnd = mach_absolute_time();
	
	long double elapsed = drawEnd - drawStart;
	elapsed *= info.numer;
	elapsed /= info.denom;
	elapsed /= 1000000.0F;
	NSLog(@"%@ %Lf miliseconds", NSStringFromSelector(_cmd), elapsed);
}
//*/

- (CGSize)intrinsicContentSize {
	CGSize textSize = CGSizeMake(0.0f, 0.0f);
	NSUInteger length = self.text.length;
	textSize.width = self.font.pointSize * length;
	textSize.height = floor(self.font.capHeight * _options.capHeightFactor);
	if (textSize.height < _options.minHeight)
		textSize.height = _options.minHeight;
	if ( textSize.width < textSize.height)
		textSize.width = textSize.height;
	else if (((NSInteger)textSize.width % 2) != 0)
		textSize.width = floor(textSize.width + 1);
//	NSLog(@"text size:%@ point size:%f cap height:%f", NSStringFromCGSize(textSize), self.font.pointSize, self.font.capHeight);
	return textSize;
}

@end
