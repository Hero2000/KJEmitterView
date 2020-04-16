//
//  UIView+KJShadow.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/4/13.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "UIView+KJShadow.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

@interface KJShadowLayer : CALayer<NSCopying>
/* 内阴影的生成路径,默认为nil */
@property (nonatomic, strong) UIBezierPath *innerShadowPath;
/* 内阴影的颜色,默认为100%透明的黑色 */
@property (nonatomic, strong) UIColor *innerShadowColor;
/*内阴影的位置,默认为(0,-3) */
@property (nonatomic, assign) CGSize innerShadowOffset;
/* 内阴影的扩散量,默认为5 */
@property (nonatomic, assign) CGFloat innerShadowRadius;
/* 内阴影的透明度,默认为0 */
@property (nonatomic, assign) CGFloat innerShadowOpacity;

@end

@implementation KJShadowLayer

/// 具有拷贝效果
- (id)copyWithZone:(NSZone *)zone {
    KJShadowLayer *layer = [[KJShadowLayer allocWithZone:zone] init];
    layer.innerShadowPath = self.innerShadowPath;
    layer.innerShadowColor = self.innerShadowColor;
    layer.innerShadowOffset = self.innerShadowOffset;
    layer.innerShadowRadius = self.innerShadowRadius;
    layer.innerShadowOpacity = self.innerShadowOpacity;
    return layer;
}

- (instancetype)init {
    if (self == [super init]) {
        [self initDefault];
    }
    return self;
}
- (void)layoutSublayers {
    [super layoutSublayers];
    [self setNeedsDisplay];
}
#pragma mark - 初始化参数
- (void)initDefault {
    self.drawsAsynchronously = YES;// 进行异步绘制
    self.contentsScale       = [UIScreen mainScreen].scale;
    self.innerShadowPath     = NULL;
    self.innerShadowColor    = UIColor.blackColor;
    self.innerShadowOffset   = CGSizeMake(0, 3);
    self.innerShadowRadius   = 5;
    self.innerShadowOpacity  = 0;
}

#pragma mark - 绘制内阴影
- (void)drawInContext:(CGContextRef)context {
    // 初始设置
    CGContextSetAllowsAntialiasing(context, YES);// 反锯齿
    CGContextSetShouldAntialias(context, YES);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);// 画面质量
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();// 获取当前设备色彩空间
    
    // 设置内阴影路径
    CGRect rect = self.bounds;
    if (self.borderWidth != 0) {
        rect = CGRectInset(rect, self.borderWidth, self.borderWidth);
    }
    
    CGContextAddPath(context, self.innerShadowPath.CGPath);
    CGContextClip(context);
    CGMutablePathRef outer = CGPathCreateMutable();
    CGPathAddRect(outer, NULL, CGRectInset(rect, -1 * rect.size.width, -1 * rect.size.height));
    CGPathAddPath(outer, NULL, self.innerShadowPath.CGPath);
    CGPathCloseSubpath(outer);
    
    // 开始绘制内阴影
    const CGFloat *oldComponents = CGColorGetComponents(self.innerShadowColor.CGColor);
    UIColor *newColor = [UIColor colorWithRed:0 green:0 blue:0 alpha: 0];
    NSInteger numberOfComponents = CGColorGetNumberOfComponents(self.innerShadowColor.CGColor);
    switch (numberOfComponents) {
        case 2:{
            newColor = [UIColor colorWithRed:oldComponents[0] green:oldComponents[0] blue:oldComponents[0] alpha: oldComponents[1] * self.innerShadowOpacity];
        }break;
        case 4:{
            newColor = [UIColor colorWithRed:oldComponents[0] green:oldComponents[1] blue:oldComponents[2] alpha: oldComponents[3] * self.innerShadowOpacity];
        }break;
    }
    
    CGColorRef ref = CGColorCreate(colorspace, CGColorGetComponents(newColor.CGColor));
    CGColorSpaceRelease(colorspace);
    CGContextSetFillColorWithColor(context, ref);
    CGContextSetShadowWithColor(context, self.innerShadowOffset, self.innerShadowRadius, ref);
    CGContextAddPath(context, outer);
    CGContextEOFillPath(context);
    CGPathRelease(outer);
    CGColorRelease(ref);
}

@end

@implementation UIView (KJShadow)
- (UIBezierPath *)innerShadowPath {
    return objc_getAssociatedObject(self, @selector(innerShadowPath));
}
- (void)setInnerShadowPath:(UIBezierPath *)innerShadowPath {
    objc_setAssociatedObject(self, @selector(innerShadowPath), innerShadowPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.innerShadowLayer.innerShadowPath = innerShadowPath;
    [self.innerShadowLayer setNeedsDisplay];
    if (around) {
        self.innerShadowLayer2.innerShadowPath = innerShadowPath;
        [self.innerShadowLayer2 setNeedsDisplay];
    }
}

- (UIColor *)innerShadowColor {
    return objc_getAssociatedObject(self, @selector(innerShadowColor));
}
- (void)setInnerShadowColor:(UIColor *)innerShadowColor {
    objc_setAssociatedObject(self, @selector(innerShadowColor), innerShadowColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.innerShadowLayer.innerShadowColor = innerShadowColor;
    [self.innerShadowLayer setNeedsDisplay];
    if (around) {
        self.innerShadowLayer2.innerShadowColor = innerShadowColor;
        [self.innerShadowLayer2 setNeedsDisplay];
    }
}

- (CGSize)innerShadowOffset {
    return [objc_getAssociatedObject(self, @selector(innerShadowOffset)) CGSizeValue];
}
- (void)setInnerShadowOffset:(CGSize)innerShadowOffset {
    objc_setAssociatedObject(self, @selector(innerShadowOffset), [NSValue valueWithCGSize:innerShadowOffset], OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.innerShadowLayer.innerShadowOffset = innerShadowOffset;
    [self.innerShadowLayer setNeedsDisplay];
    if (around) {
        self.innerShadowLayer2.innerShadowOffset = CGSizeMake(-innerShadowOffset.width, -innerShadowOffset.height);;
        [self.innerShadowLayer2 setNeedsDisplay];
    }
}

- (CGFloat)innerShadowRadius {
    return [objc_getAssociatedObject(self, @selector(innerShadowRadius)) doubleValue];
}
- (void)setInnerShadowRadius:(CGFloat)innerShadowRadius {
    objc_setAssociatedObject(self, @selector(innerShadowRadius), @(innerShadowRadius), OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.innerShadowLayer.innerShadowRadius = innerShadowRadius;
    [self.innerShadowLayer setNeedsDisplay];
    if (around) {
        self.innerShadowLayer2.innerShadowRadius = innerShadowRadius;
        [self.innerShadowLayer2 setNeedsDisplay];
    }
}

- (CGFloat)innerShadowOpacity {
    return [objc_getAssociatedObject(self, @selector(innerShadowOpacity)) doubleValue];
}
- (void)setInnerShadowOpacity:(CGFloat)innerShadowOpacity {
    objc_setAssociatedObject(self, @selector(innerShadowOpacity), @(innerShadowOpacity), OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.innerShadowLayer.innerShadowOpacity = innerShadowOpacity;
    [self.innerShadowLayer setNeedsDisplay];
    if (around) {
        self.innerShadowLayer2.innerShadowOpacity = innerShadowOpacity;
        [self.innerShadowLayer2 setNeedsDisplay];
    }
}

- (KJShadowLayer*)innerShadowLayer {
    return objc_getAssociatedObject(self, @selector(innerShadowLayer));
}
- (void)setInnerShadowLayer:(KJShadowLayer*)innerShadowLayer {
    objc_setAssociatedObject(self, @selector(innerShadowLayer), innerShadowLayer, OBJC_ASSOCIATION_ASSIGN);
}
- (KJShadowLayer*)innerShadowLayer2 {
    return objc_getAssociatedObject(self, @selector(innerShadowLayer2));
}
- (void)setInnerShadowLayer2:(KJShadowLayer*)innerShadowLayer2 {
    objc_setAssociatedObject(self, @selector(innerShadowLayer2), innerShadowLayer2, OBJC_ASSOCIATION_ASSIGN);
}

// 添加内阴影
- (void)kj_addInnerShadow {
    around = false;
    KJShadowLayer *innerShadowLayer = [KJShadowLayer layer];
    innerShadowLayer.frame = self.bounds;
    innerShadowLayer.innerShadowPath = self.innerShadowPath;
    innerShadowLayer.innerShadowColor = self.innerShadowColor;
    innerShadowLayer.innerShadowOffset = self.innerShadowOffset;
    innerShadowLayer.innerShadowRadius = self.innerShadowRadius;
    innerShadowLayer.innerShadowOpacity = self.innerShadowOpacity;
    [self.layer addSublayer:innerShadowLayer];
    self.innerShadowLayer = innerShadowLayer;
}
// 移出阴影
- (void)kj_removeInnerShadow {
    around = false;
    for (CALayer *subLayer in self.layer.sublayers) {
        if ([subLayer isKindOfClass:[KJShadowLayer class]]) {
            [subLayer removeFromSuperlayer];
        }
    }
}
static bool around = false;
// 四周环绕内发光处理
- (void)kj_aroundInnerShine{
    around = true;
    self.innerShadowLayer = [KJShadowLayer layer];
    self.innerShadowLayer.frame = self.bounds;
    self.innerShadowLayer.innerShadowPath = self.innerShadowPath;
    self.innerShadowLayer.innerShadowColor = self.innerShadowColor;
    self.innerShadowLayer.innerShadowOffset = self.innerShadowOffset;
    self.innerShadowLayer.innerShadowRadius = self.innerShadowRadius;
    self.innerShadowLayer.innerShadowOpacity = self.innerShadowOpacity;
    [self.layer addSublayer:self.innerShadowLayer];
    
    self.innerShadowLayer2 = [self.innerShadowLayer copy];
    self.innerShadowLayer2.frame = self.bounds;
    self.innerShadowLayer2.innerShadowOffset = CGSizeMake(-self.innerShadowOffset.width, -self.innerShadowOffset.height);
    [self.layer addSublayer:self.innerShadowLayer2];
}
// 提供一套阴影角度算法 angele:范围（0-360）distance:距离
- (void)kj_innerShadowAngle:(CGFloat)angle Distance:(CGFloat)distance{
    double z = distance;
    double x = 0,y = 0;
    angle = angle>=360?angle-360:angle;
    if (0<=angle&&angle<90) {
        double t = tan(M_PI/(180.0/angle));
        x = -z/(t+1.0);
        y = (z*t)/(t+1.0);
    }else if (90<=angle&&angle<180) {
        double t = tan(M_PI/(180.0/(angle-90)));
        x = (z-z/(t+1.0));
        y = z-(z*t)/(t+1.0);
    }else if (180<=angle&&angle<270) {
        double t = tan(M_PI/(180.0/(angle-180)));
        x = z/(t+1.0);
        y = -(z*t)/(t+1.0);
    }else if (270<=angle&&angle<360) {
        double t = tan(M_PI/(180.0/(angle-270)));
        x = -(z-z/(t+1.0));
        y = -(z-(z*t)/(t+1.0));
    }
    self.innerShadowOffset = CGSizeMake(x, y);
}

@end
