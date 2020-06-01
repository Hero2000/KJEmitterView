//
//  KJInteriorSuperclassView.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/28.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJInteriorSuperclassView.h"
@implementation KJInteriorSuperclassView

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    /// 如果不能接收触摸事件，直接返回nil
    if (self.userInteractionEnabled == NO || self.hidden == YES || self.alpha < 0.01) return nil;
    /// 如果触摸点不在自己上面，直接返回nil
    if (![self pointInside:point withEvent:event]) return nil;
    /// 特殊子类处理
    NSString *classString = NSStringFromClass([self class]);
    if ([classString isEqualToString:@"KJMuralView"] ||
        [classString isEqualToString:@"KJSkirtingLineView"] ||
        [classString isEqualToString:@"KJDecorateBoxView"]) {
        if (![self kj_callChildDelGestureMethodWithPoint:point]) return nil;
    }
    ///
    NSInteger count = self.subviews.count;
    for (NSInteger i=count-1; i>=0; i--) {
        UIView *childView = self.subviews[i];
        CGPoint childPoint = [self convertPoint:point toView:childView];
        UIView *view = [childView hitTest:childPoint withEvent:event];
        if (view) return view;
    }
    return self;
}
/// 调用子类处理手势区域方法返回的结果
- (bool)kj_callChildDelGestureMethodWithPoint:(CGPoint)point{
    SEL selector = NSSelectorFromString(@"kj_delGestureWithPoint:");
    IMP imp = [self methodForSelector:selector];
    bool (*func)(id, SEL, CGPoint) = (void *)imp;
    return func(self, selector, point);
}
/// 子类需要实现方法
- (bool)kj_delGestureWithPoint:(CGPoint)point{
    return false;
}
//#pragma mark - 绘制壁画相关
//- (bool)kj_getMuralViewAreaWithPoint:(CGPoint)point{
//    SEL selector = NSSelectorFromString(@"kj_getKnownPoints");
//    IMP imp = [self methodForSelector:selector];
//    KJKnownPoints (*func)(id, SEL) = (void *)imp;
//    KJKnownPoints knownPoints = func(self, selector);
//    return [_KJIFinishTools kj_confirmCurrentPointWithPoint:point KnownPoints:knownPoints];
////    unsigned int outCount;
////    bool boo = true;
////    Class class = NSClassFromString(@"KJMuralView");
////    objc_property_t *properties = class_copyPropertyList(class, &outCount);/// 属性的链表
////    for (int i = 0; i<outCount; i++){
////        objc_property_t property = properties[i];
////        const char *propertyName = property_getName(property);/// 获取属性字符串
////        NSString *key = [NSString stringWithUTF8String:propertyName];
////        id value = [self valueForKey:key];/// 获取属性对应的value
////        if ([key isEqualToString:@"topPoints"] && value) {
////            NSLog(@"---%@,%@",key,value);
////            KJKnownPoints knownPoints;
////            [value getValue:&knownPoints];
////            boo = [_KJIFinishTools kj_confirmCurrentPointWithPoint:point KnownPoints:knownPoints];
////        }
////    }
////    free(properties);/// 释放结构体数组内存
////    return boo;
//}

@end
