//
//  UIButton+KJBlock.m
//  KJEmitterView
//
//  Created by 杨科军 on 2019/4/4.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "UIButton+KJBlock.h"
#import <objc/runtime.h>

@implementation UIButton (KJBlock)

/*********************** Block ************************/
static char ActionTag;
/** button 添加点击事件 默认点击方式UIControlEventTouchUpInside */
- (void)kj_addAction:(KJButtonBlock)block {
    objc_setAssociatedObject(self, &ActionTag, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
}

/** button 添加事件 controlEvents 点击的方式 */
- (void)kj_addAction:(KJButtonBlock)block forControlEvents:(UIControlEvents)controlEvents {
    objc_setAssociatedObject(self, &ActionTag, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(action:) forControlEvents:controlEvents];
}

/** button 事件的响应方法 */
- (void)action:(id)sender {
    KJButtonBlock blockAction = (KJButtonBlock)objc_getAssociatedObject(self, &ActionTag);
    if (blockAction) blockAction(self);
}


+ (void)load {
    SEL originalSelector = @selector(sendAction:to:forEvent:);
    SEL swizzledSelector = @selector(kj_sendAction:to:forEvent:);
    Method originalMethod = class_getInstanceMethod([self class], originalSelector);
    Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (NSTimeInterval)kj_AcceptEventTime{
    return [objc_getAssociatedObject(self, @selector(kj_AcceptEventTime)) doubleValue];
}
- (void)setKj_AcceptEventTime:(NSTimeInterval)kj_AcceptEventTime{
    objc_setAssociatedObject(self, @selector(kj_AcceptEventTime), @(kj_AcceptEventTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
///** 同步sett gett 方法 */
//KJ_SYNTHESIZE_CATEGORY_OBJ_PROPERTY(kAcceptEventInterval, setKAcceptEventInterval:)

/** 上一次接受事件的时候 */
- (NSTimeInterval)kAcceptEventTime{
    return [objc_getAssociatedObject(self, @selector(kAcceptEventTime)) doubleValue];
}
- (void)setKAcceptEventTime:(NSTimeInterval)kAcceptEventTime{
    objc_setAssociatedObject(self, @selector(kAcceptEventTime), @(kAcceptEventTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
/// 交换方法后实现
- (void)kj_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
    if (self.kj_AcceptEventTime <= 0) {
        [self kj_sendAction:action to:target forEvent:event];
        return;
    }
    // 是否小于于设定的时间间隔
    BOOL boo = (NSDate.date.timeIntervalSince1970 - self.kAcceptEventTime >= self.kj_AcceptEventTime);
    // 更新上一次点击时间戳
    if (self.kj_AcceptEventTime > 0) self.kAcceptEventTime = NSDate.date.timeIntervalSince1970;
    // 两次点击的时间间隔小于设定的时间间隔时，才执行响应事件
    if (boo) [self kj_sendAction:action to:target forEvent:event];
}


@end
