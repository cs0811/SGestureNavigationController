//
//  UINavigationController+SPopGesture.m
//  SGestureNavigationController
//
//  Created by dufei on 16/6/1.
//  Copyright © 2016年 dufei. All rights reserved.
//

#import "UINavigationController+SPopGesture.h"
#import <objc/runtime.h>

#pragma mark - SFullscreenPopGestureRecognizerDelegate
@interface SFullscreenPopGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation SFullscreenPopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    // 当为根控制器时，手势不执行。
    if (self.navigationController.viewControllers.count <= 1) {
        return NO;
    }
    
    // 设置一个页面是否显示此手势，默认为NO 显示。
    UIViewController *topViewController = self.navigationController.viewControllers.lastObject;
    if (topViewController.s_interactivePopDisabled) {
        return NO;
    }
    
    //  手势滑动距左边框的距离超过maxAllowedInitialDistance 手势不执行。
    CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGFloat maxAllowedInitialDistance = topViewController.s_interactivePopMaxAllowedInitialDistanceToLeftEdge;
    if (maxAllowedInitialDistance > 0 && beginningLocation.x > maxAllowedInitialDistance) {
        return NO;
    }
    
    // 当push、pop动画正在执行时，手势不执行。
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    
    //  向左边(反方向)拖动，手势不执行。
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    if (translation.x <= 0) {
        return NO;
    }
    
    return YES;
}

@end

#pragma mark - UIViewController + SPopGesture
@implementation UIViewController (SPopGesture)

- (BOOL)s_interactivePopDisabled {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (CGFloat)s_interactivePopMaxAllowedInitialDistanceToLeftEdge {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setS_interactivePopDisabled:(BOOL)s_interactivePopDisabled {
    objc_setAssociatedObject(self, _cmd, @(s_interactivePopDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setS_interactivePopMaxAllowedInitialDistanceToLeftEdge:(CGFloat)s_interactivePopMaxAllowedInitialDistanceToLeftEdge {
    objc_setAssociatedObject(self, _cmd, @(s_interactivePopMaxAllowedInitialDistanceToLeftEdge), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark - UINavigationController + SPopGesture
@implementation UINavigationController (SPopGesture)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(pushViewController:animated:);
        SEL swizzledSelector = @selector(s_pushViewController:animated:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)s_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.s_popGestureRecognizer])
    {
        //  添加我们自己的侧滑返回手势
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.s_popGestureRecognizer];
        /*
         新建一个UIPanGestureRecognizer，让它的触发和系统的这个手势相同，
         这就需要利用runtime获取系统手势的target和action。
         */
        //  用KVC取出target和action
        NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        
        //  将自定义的代理（手势执行条件）传给手势的delegate
        self.s_popGestureRecognizer.delegate = self.s_popGestureRecognizerDelegate;
        //  将target和action传给手势
        [self.s_popGestureRecognizer addTarget:internalTarget action:internalAction];
        
        //  设置系统的为NO
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    //  执行原本的方法
    if (![self.viewControllers containsObject:viewController]) {
        [self s_pushViewController:viewController animated:animated];
    }
}

- (SFullscreenPopGestureRecognizerDelegate *)s_popGestureRecognizerDelegate
{
    SFullscreenPopGestureRecognizerDelegate *delegate = objc_getAssociatedObject(self, _cmd);
    if (!delegate) {
        delegate = [[SFullscreenPopGestureRecognizerDelegate alloc] init];
        delegate.navigationController = self;
        objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}

- (UIPanGestureRecognizer *)s_popGestureRecognizer
{
    UIPanGestureRecognizer *panGestureRecognizer = objc_getAssociatedObject(self, _cmd);
    if (!panGestureRecognizer) {
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        objc_setAssociatedObject(self, _cmd, panGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGestureRecognizer;
}
@end


