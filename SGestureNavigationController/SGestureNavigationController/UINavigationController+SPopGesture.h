//
//  UINavigationController+SPopGesture.h
//  SGestureNavigationController
//
//  Created by dufei on 16/6/1.
//  Copyright © 2016年 dufei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (SPopGesture)

/**
 *  是否显示手势
 */
@property (nonatomic, assign) BOOL s_interactivePopDisabled;

/**
 *  手势滑动距左边最大的距离
 */
@property (nonatomic, assign) CGFloat s_interactivePopMaxAllowedInitialDistanceToLeftEdge;

@end



@interface UINavigationController (SPopGesture)

@property (nonatomic, strong, readonly) UIPanGestureRecognizer * s_popGestureRecognizer;

@end


