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

@interface KJShadowLayer : CALayer

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

- (instancetype)init {
    if (self == [super init]) {
        [self initDefault];
    }
    return self;
}

- (instancetype)initWithLayer:(id)layer {
    if (self == [super initWithLayer:layer]) {
        [self initDefault];
        if ([layer isKindOfClass:[KJShadowLayer class]]) {
            KJShadowLayer *other = (KJShadowLayer *)layer;
            self.innerShadowPath = other.innerShadowPath;
            self.innerShadowColor = other.innerShadowColor;
            self.innerShadowOffset = other.innerShadowOffset;
            self.innerShadowRadius = other.innerShadowRadius;
            self.innerShadowOpacity = other.innerShadowOpacity;
        }
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

#pragma mark - 重写刷新方法
+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"innerShadowPath"] ||
        [key isEqualToString:@"innerShadowColor"] ||
        [key isEqualToString:@"innerShadowOffset"] ||
        [key isEqualToString:@"innerShadowRadius"] ||
        [key isEqualToString:@"innerShadowOpacity"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}
- (id)actionForKey:(NSString*)key {
    if ([key isEqualToString:@"innerShadowPath"] ||
        [key isEqualToString:@"innerShadowColor"] ||
        [key isEqualToString:@"innerShadowOffset"] ||
        [key isEqualToString:@"innerShadowRadius"] ||
        [key isEqualToString:@"innerShadowOpacity"]) {
        CABasicAnimation *animate = [CABasicAnimation animationWithKeyPath:key];
        animate.fromValue = [self.presentationLayer valueForKey:key];
        return animate;
    }
    return [super actionForKey:key];
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
    CGFloat *oldComponents = (CGFloat *)CGColorGetComponents(self.innerShadowColor.CGColor);
    CGFloat newComponents[4];
    NSInteger numberOfComponents = CGColorGetNumberOfComponents(self.innerShadowColor.CGColor);
    
    switch (numberOfComponents) {
        case 2: { //grayscale
            newComponents[0] = oldComponents[0];
            newComponents[1] = oldComponents[0];
            newComponents[2] = oldComponents[0];
            newComponents[3] = oldComponents[1] * self.innerShadowOpacity;
        } break;
        case 4: { //RGBA
            newComponents[0] = oldComponents[0];
            newComponents[1] = oldComponents[1];
            newComponents[2] = oldComponents[2];
            newComponents[3] = oldComponents[3] * self.innerShadowOpacity;
        } break;
    }
    
    CGColorRef ref = CGColorCreate(colorspace, newComponents);
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
}

- (UIColor *)innerShadowColor {
    return objc_getAssociatedObject(self, @selector(innerShadowColor));
}
- (void)setInnerShadowColor:(UIColor *)innerShadowColor {
    objc_setAssociatedObject(self, @selector(innerShadowColor), innerShadowColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.innerShadowLayer.innerShadowColor = innerShadowColor;
    [self.innerShadowLayer setNeedsDisplay];
}

- (CGSize)innerShadowOffset {
    return [objc_getAssociatedObject(self, @selector(innerShadowOffset)) CGSizeValue];
}
- (void)setInnerShadowOffset:(CGSize)innerShadowOffset {
    objc_setAssociatedObject(self, @selector(innerShadowOffset), [NSValue valueWithCGSize:innerShadowOffset], OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.innerShadowLayer.innerShadowOffset = innerShadowOffset;
    [self.innerShadowLayer setNeedsDisplay];
}

- (CGFloat)innerShadowRadius {
    return [objc_getAssociatedObject(self, @selector(innerShadowRadius)) doubleValue];
}
- (void)setInnerShadowRadius:(CGFloat)innerShadowRadius {
    objc_setAssociatedObject(self, @selector(innerShadowRadius), @(innerShadowRadius), OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.innerShadowLayer.innerShadowRadius = innerShadowRadius;
    [self.innerShadowLayer setNeedsDisplay];
}

- (CGFloat)innerShadowOpacity {
    return [objc_getAssociatedObject(self, @selector(innerShadowOpacity)) doubleValue];
}
- (void)setInnerShadowOpacity:(CGFloat)innerShadowOpacity {
    objc_setAssociatedObject(self, @selector(innerShadowOpacity), @(innerShadowOpacity), OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.innerShadowLayer.innerShadowOpacity = innerShadowOpacity;
    [self.innerShadowLayer setNeedsDisplay];
}

- (KJShadowLayer*)innerShadowLayer {
    return objc_getAssociatedObject(self, @selector(innerShadowLayer));
}
- (void)setInnerShadowLayer:(KJShadowLayer*)innerShadowLayer {
    objc_setAssociatedObject(self, @selector(innerShadowLayer), innerShadowLayer, OBJC_ASSOCIATION_ASSIGN);
}

// 添加内阴影
- (void)addInnerShadow {
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

- (void)removeInnerShadow {
    for (CALayer *subLayer in self.layer.sublayers) {
        if ([subLayer isKindOfClass:[KJShadowLayer class]]) {
            [subLayer removeFromSuperlayer];
        }
    }
}

@end
