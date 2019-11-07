//
//  UIButton+KJEmitter.m
//  KJEmitterView
//
//  Created by 杨科军 on 2019/10/15.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "UIButton+KJEmitter.h"
#import <objc/runtime.h>

@implementation UIButton (KJEmitter)

+ (void)load{
    SEL originalSelector = @selector(setSelected:);
    SEL swizzledSelector = @selector(kj_setSelected:);
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL boo = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (boo) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
- (BOOL)kj_openButtonEmitter{
    return objc_getAssociatedObject(self, @selector(kj_openButtonEmitter));
}
- (void)setKj_openButtonEmitter:(BOOL)kj_openButtonEmitter{
    objc_setAssociatedObject(self, @selector(kj_openButtonEmitter), @(kj_openButtonEmitter), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    ///
    [self setupLayer];
}
- (CAEmitterLayer*)chargeLayer{
    return objc_getAssociatedObject(self, @selector(chargeLayer));
}
- (void)setChargeLayer:(CAEmitterLayer *)chargeLayer{
    objc_setAssociatedObject(self, @selector(chargeLayer), chargeLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CAEmitterLayer*)explosionLayer{
    return objc_getAssociatedObject(self, @selector(explosionLayer));
}
- (void)setExplosionLayer:(CAEmitterLayer *)explosionLayer{
    objc_setAssociatedObject(self, @selector(explosionLayer), explosionLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)kj_setSelected:(BOOL)selected{
    if (self.kj_openButtonEmitter) {
        [self kj_setSelected:selected];
        [self buttonAnimation];
        return;
    }
    [self kj_setSelected:selected];
}

- (void)setupLayer{
    //CAEmitterCell是粒子发射系统里的粒子,可设置粒子的样式，图片，颜色，方向，运动，缩放比例和生命周期等等。
    CAEmitterCell *explosionCell = [CAEmitterCell emitterCell];
    explosionCell.name = @"explosion";
    explosionCell.alphaRange = 0.10;//一个粒子的颜色alpha能改变的范围
    explosionCell.alphaSpeed = -1.0;//粒子透明度在生命周期内的改变速度
    explosionCell.lifetime = 0.7;//生命周期
    explosionCell.lifetimeRange = 0.3;
    explosionCell.birthRate = 0;//每秒发射的粒子数量
    explosionCell.velocity = 40.00;//速度
    explosionCell.velocityRange = 10.00;//速度范围
    explosionCell.scale = 0.04;//缩放比例
    explosionCell.scaleRange = 0.02;//缩放比例范围
    explosionCell.contents = (id)[UIImage imageNamed:@"KJKit.bundle/button_sparkle"].CGImage;//是个CGImageRef的对象,既粒子要展现的图片
    
    /// CAEmitterLayer类提供了一个粒子发射器系统为核心的动画
    /// 这些粒子是由CAEmitterCell组成的实例，它相当于一个管理者，来管理 CAEmitterCell的发射的一些细节，比如发射的位置，发射形状等等。
    self.explosionLayer = [CAEmitterLayer layer];
    self.explosionLayer.name = @"emitterLayer";
    self.explosionLayer.emitterShape = kCAEmitterLayerCircle;//发射源的形状
    self.explosionLayer.emitterMode = kCAEmitterLayerOutline;//发射模式
    self.explosionLayer.emitterSize = CGSizeMake(10, 0);//发射源的大小
    self.explosionLayer.emitterCells = @[explosionCell];//装着CAEmitterCell对象的数组，被用于把粒子投放到layer上
    self.explosionLayer.renderMode = kCAEmitterLayerOldestFirst;//渲染模式
    self.explosionLayer.masksToBounds = NO;
    self.explosionLayer.position = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    self.explosionLayer.zPosition = -1;
    [self.layer addSublayer:self.explosionLayer];
    
    /*
     uiview   clipsToBounds
     是指视图上的子视图,如果超出父视图的部分就截取掉,
     calayer  masksToBounds
     却是指视图的图层上的子图层,如果超出父图层的部分就截取掉
     */
    
    //CALayer中position与anchorPoint详解 http://www.cnblogs.com/AbeDay/p/5026870.html
    CAEmitterCell *chargeCell = [CAEmitterCell emitterCell];
    chargeCell.name = @"charge";
    chargeCell.alphaRange = 0.10;
    chargeCell.alphaSpeed = -1.0;
    chargeCell.lifetime = 0.3;
    chargeCell.lifetimeRange = 0.1;
    chargeCell.birthRate = 0;
    chargeCell.velocity = -40.0;
    chargeCell.velocityRange = 0.00;
    chargeCell.scale = 0.03;
    chargeCell.scaleRange = 0.02;
    chargeCell.contents = (id)[UIImage imageNamed:@"Sparkle"].CGImage;

    self.chargeLayer = [CAEmitterLayer layer];
    self.chargeLayer.name = @"emitterLayer";
    self.chargeLayer.emitterShape = kCAEmitterLayerCircle;
    self.chargeLayer.emitterMode = kCAEmitterLayerOutline;
    self.chargeLayer.emitterSize = CGSizeMake(20, 0);
    self.chargeLayer.emitterCells = @[chargeCell];
    self.chargeLayer.renderMode = kCAEmitterLayerOldestFirst;
    self.chargeLayer.masksToBounds = NO;
    self.chargeLayer.position = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    self.chargeLayer.zPosition = -1;
    
    [self.layer addSublayer:self.chargeLayer];
}


/**开始动画 */
- (void)buttonAnimation{
    //CABasicAnimation只能从一个数值(fromValue)变到另一个数值(toValue)，而CAKeyframeAnimation会使用一个NSArray保存这些数值
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    if (self.selected) {
        animation.values = @[@1.5 ,@0.8, @1.0,@1.2,@1.0];
        animation.duration = 0.5;
        [self startAnimate];
    }else{
        animation.values = @[@0.8, @1.0];
        animation.duration = 0.4;
    }
    animation.calculationMode = kCAAnimationCubic;
    [self.layer addAnimation:animation forKey:@"transform.scale"];
    
    /*
     CAKeyframeAnimation : http://blog.csdn.net/u011700462/article/details/37540709
     cacluationMode:在关键帧动画中还有一个非常重要的参数,那便是calculationMode,计算模式
     其主要针对的是每一帧的内容为一个座标点的情况,也就是对anchorPoint 和 position进行的动画
     当在平面座标系中有多个离散的点的时候,可以是离散的,也可以直线相连后进行插值计算,也可以使用圆滑的曲线将他们相连后进行插值计算
     calculationMode目前提供如下几种模式 kCAAnimationLinear
     */
}

/** 开始喷射 */
- (void)startAnimate {
    //chareLayer开始时间
    self.chargeLayer.beginTime = CACurrentMediaTime();
    //chareLayer每秒喷射的80个
    [self.chargeLayer setValue:@80 forKeyPath:@"emitterCells.charge.birthRate"];
    //进入下一个动作
    [self performSelector:@selector(explode) withObject:nil afterDelay:0.2];
    /// NSDate 或 CFAbsoluteTimeGetCurrent() 返回的时钟时间将会会网络时间同步,从时钟偏移量的角度
    /// mach_absolute_time() 和 CACurrentMediaTime() 是基于内建时钟的,能够更精确更原子化地测量
    /// 并且不会因为外部时间变化而变化（例如时区变化、夏时制、秒突变等）
    /// 但它和系统的uptime有关,系统重启后CACurrentMediaTime()会被重置
}
/** 大量喷射 */
- (void)explode {
    //让chareLayer每秒喷射的个数为0个
    [self.chargeLayer setValue:@0 forKeyPath:@"emitterCells.charge.birthRate"];
    //explosionLayer开始时间
    self.explosionLayer.beginTime = CACurrentMediaTime();
    //explosionLayer每秒喷射的2500个
    [self.explosionLayer setValue:@2500 forKeyPath:@"emitterCells.explosion.birthRate"];
    //停止喷射
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}

/** 停止喷射 */
- (void)stop {
    //让chareLayer每秒喷射的个数为0个
    [self.chargeLayer setValue:@0 forKeyPath:@"emitterCells.charge.birthRate"];
    //explosionLayer每秒喷射的0个
    [self.explosionLayer setValue:@0 forKeyPath:@"emitterCells.explosion.birthRate"];
}

@end
