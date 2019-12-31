//
//  UIButton+KJCountDown.m
//  KJEmitterView
//
//  Created by 杨科军 on 2019/12/31.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "UIButton+KJCountDown.h"
#import <objc/runtime.h>
@implementation UIButton (KJCountDown)
- (dispatch_source_t)timer{
    return objc_getAssociatedObject(self, @selector(timer));
}
- (void)setTimer:(dispatch_source_t)timer{
    objc_setAssociatedObject(self, @selector(timer), timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString*)xxtitle{
    return objc_getAssociatedObject(self, @selector(xxtitle));
}
- (void)setXxtitle:(NSString*)xxtitle{
    objc_setAssociatedObject(self, @selector(xxtitle), xxtitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)setKButtonCountDownStop:(void(^)(void))kButtonCountDownStop {
    objc_setAssociatedObject(self, @selector(kButtonCountDownStop), kButtonCountDownStop, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void(^)(void))kButtonCountDownStop {
    return objc_getAssociatedObject(self, @selector(kButtonCountDownStop));
}

- (void)kj_startTime:(NSInteger)timeout CountDownFormat:(NSString*)format{
    [self kj_cancelTimer];
    __block NSInteger timeOut = timeout; //倒计时时间
    __block NSString *countDownFormat = format ?: @"%zd秒";
    self.xxtitle = self.titleLabel.text;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t __timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    self.timer = __timer;
    dispatch_source_set_timer(__timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(__timer, ^{
        if(timeOut <= 0){ //倒计时结束，关闭
            [self kj_cancelTimer];
        }else{
            int seconds = timeOut % 60;
            NSString *strTime = [NSString stringWithFormat:countDownFormat,seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setTitle:strTime forState:UIControlStateNormal];
                self.userInteractionEnabled = NO;
            });
            timeOut--;
        }
    });
    dispatch_resume(__timer);
}
/// 取消倒计时
- (void)kj_cancelTimer{
    if (self.timer == nil) return;
    dispatch_source_cancel(self.timer);
    self.timer = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setTitle:self.xxtitle forState:UIControlStateNormal];
        self.userInteractionEnabled = YES;
        if (self.kButtonCountDownStop) { self.kButtonCountDownStop(); }
    });
}
@end
