//
//  KJShadowLayer.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/4/28.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJShadowLayer.h"

@interface KJShadowLayer ()
@property (nonatomic,strong) UIBezierPath *kj_path;
@property (nonatomic,strong) UIColor *kj_color;
@property (nonatomic,assign) CGFloat kj_radius;
@property (nonatomic,assign) CGFloat kj_opacity;
@property (nonatomic,assign) CGSize kj_offset;
@property (nonatomic,assign) KJShadowType kj_shadowType;
@property (nonatomic,strong) KJShadowLayer *xLayer,*xxLayer,*xxxLayer;
@end
@implementation KJShadowLayer
/// 具有拷贝效果
- (instancetype)copyWithZone:(NSZone *)zone {
    KJShadowLayer *layer = [[KJShadowLayer allocWithZone:zone] init];
    layer.frame      = self.frame;
    layer.kj_path    = self.kj_path;
    layer.kj_color   = self.kj_color;
    layer.kj_offset  = self.kj_offset;
    layer.kj_radius  = self.kj_radius;
    layer.kj_opacity = self.kj_opacity;
    layer.kj_shadowType = self.kj_shadowType;
    return layer;
}
- (instancetype)kj_initWithFrame:(CGRect)frame ShadowType:(KJShadowType)type{
    if (self == [super init]) {
        self.frame = frame;
        self.drawsAsynchronously = YES;// 进行异步绘制
        self.contentsScale = [UIScreen mainScreen].scale;
        self.kj_shadowType = type;
        self.kj_shadowColor = UIColor.blackColor;
        if (type == KJShadowTypeInnerShine) {
            self.xxLayer = [self copy];
            [self addSublayer:_xxLayer];
        }else if (type == KJShadowTypeOuterShine || type == KJShadowTypeOuter) {
            self.xLayer   = [self copy];
            self.xxLayer  = [self copy];
            self.xxxLayer = [self copy];
            [self addSublayer:_xLayer];
            [self addSublayer:_xxLayer];
            [self addSublayer:_xxxLayer];
        }
    }
    return self;
}
- (void)layoutSublayers {
    [super layoutSublayers];
    [self setNeedsDisplay];
}

#pragma mark - 绘制
- (void)drawInContext:(CGContextRef)context {
    CGRect rect = self.bounds;
    if (self.borderWidth != 0) rect = CGRectInset(rect, self.borderWidth, self.borderWidth);
    
    if (self.kj_shadowType == KJShadowTypeInner || self.kj_shadowType == KJShadowTypeInnerShine) { /// 内阴影、内发光
        CGContextAddPath(context, self.kj_path.CGPath);
        CGContextClip(context); // 裁剪路径以外部分
        CGMutablePathRef outer = CGPathCreateMutable();
        CGPathAddRect(outer, NULL, CGRectInset(rect, -1 * rect.size.width, -1 * rect.size.height));
        CGPathAddPath(outer, NULL, self.kj_path.CGPath);
        CGPathCloseSubpath(outer); /// 闭合路径
        CGContextAddPath(context, outer);
        CGPathRelease(outer);
    }else{
        CGContextAddPath(context, self.kj_path.CGPath);// 设置阴影路径
//        CGContextResetClip(context); // 裁剪重复区域
//        CGMutablePathRef path = CGPathCreateMutable();
//        UIBezierPath *bPath = [UIBezierPath bezierPathWithRect:rect];
//        CGPathAddPath(path, NULL, bPath.CGPath);
//        CGContextAddPath(context, path);
//        CFRelease(path);
    }
    
    // 填充颜色
    CGContextSetFillColorWithColor(context, UIColor.blueColor.CGColor);
    // 阴影颜色
    UIColor *color = [self.kj_color colorWithAlphaComponent:self.kj_opacity];
    CGContextSetShadowWithColor(context, self.kj_offset, self.kj_radius, color.CGColor);
//    if (self.kj_shadowType == KJShadowTypeInnerShine) {
//        CGContextSetShadowWithColor(context, self.kj_offset, self.kj_radius, color.CGColor);
//        CGContextSetStrokeColorWithColor(context, color.CGColor);//边线颜色，需要时，与填充颜色一致
//        CGContextSetLineWidth(context, self.kj_shadowDiffuse);// 边框线条宽度
//    }else if (self.kj_shadowType == KJShadowTypeOuterShine || self.kj_shadowType == KJShadowTypeOuter) {
//        CGContextSetFillColorWithColor(context, UIColor.clearColor.CGColor);//设置填充颜色
//        UIColor *colorss = [UIColor kj_gradientFromColor:UIColor.redColor toColor:UIColor.blueColor Height:self.kj_shadowDiffuse];
//        CGContextSetStrokeColorWithColor(context, colorss.CGColor);//边线颜色，需要时，与填充颜色一致
//        CGContextSetLineWidth(context, self.kj_shadowDiffuse);// 边框线条宽度
//        CGContextSetAllowsAntialiasing(context,NO); //
//        CGContextSetLineJoin(context, kCGLineJoinRound); /// 线条拐点处样式
//        CGContextSetShouldAntialias(context, YES); // 不采用抗锯齿
//    }else{
//        CGContextSetShadowWithColor(context, self.kj_offset, self.kj_radius, color.CGColor);
//    }
    
    /* 填充方式,枚举类型
     kCGPathFill:只有填充（非零缠绕数填充），不绘制边框
     kCGPathEOFill:奇偶规则填充（多条路径交叉时，奇数交叉填充，偶交叉不填充）
     kCGPathStroke:只有边框
     kCGPathFillStroke：既有边框又有填充
     kCGPathEOFillStroke：奇偶填充并绘制边框
    */
    if (self.kj_shadowType == KJShadowTypeProjection) {
        CGContextDrawPath(context, kCGPathEOFill); //指定模式下渲染路径
    }else if (self.kj_shadowType == KJShadowTypeOuterShine || self.kj_shadowType == KJShadowTypeOuter) {
//        CGImageRef imgRef = CGImageRetain([UIImage imageNamed:@"xxsf"].CGImage);
//        CGContextDrawImage(context,rect,imgRef);
        CGContextDrawPath(context, kCGPathEOFill);
    }else{
        CGContextDrawPath(context, kCGPathEOFillStroke); //指定模式下渲染路径
    }
}

// 提供一套阴影角度算法 angele:范围（0-360）distance:距离
- (CGSize)kj_innerShadowAngle:(CGFloat)angle Distance:(CGFloat)distance{
    double z = distance;
    double x = 0,y = 0;
    angle = angle>=360?fmodl(angle,360):angle;
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
    return CGSizeMake(x, y);
}
/// 修改属性
- (void)kj_changeShadowLayerValue{
    self.kj_path = self.kj_shadowPath;
    self.kj_color = self.kj_shadowColor;
    self.kj_radius = self.kj_shadowRadius;
    self.kj_opacity = self.kj_shadowOpacity;
    self.kj_offset = CGSizeMake(self.kj_shadowDiffuse, self.kj_shadowDiffuse);
    switch (self.kj_shadowType) {
        case KJShadowTypeInner: /// 内阴影
        case KJShadowTypeProjection: /// 投影
            self.kj_offset = [self kj_innerShadowAngle:self.kj_shadowAngle Distance:self.kj_shadowDiffuse];
            break;
        case KJShadowTypeInnerShine: /// 内发光
            self.xxLayer.kj_path = self.kj_shadowPath;
            self.xxLayer.kj_color = self.kj_shadowColor;
            self.xxLayer.kj_radius = self.kj_shadowRadius;
            self.xxLayer.kj_opacity = self.kj_shadowOpacity;
            self.xxLayer.kj_offset = CGSizeMake(-self.kj_shadowDiffuse, -self.kj_shadowDiffuse);
            [self.xxLayer setNeedsDisplay];
            break;
        case KJShadowTypeOuter: /// 外阴影
        case KJShadowTypeOuterShine: /// 外发光
            self.xLayer.kj_path = self.kj_shadowPath;
            self.xLayer.kj_color = self.kj_shadowColor;
            self.xLayer.kj_radius = self.kj_shadowRadius;
            self.xLayer.kj_opacity = self.kj_shadowOpacity;
            self.xLayer.kj_offset = CGSizeMake(-self.kj_shadowDiffuse, -self.kj_shadowDiffuse);
            [self.xLayer setNeedsDisplay];
            self.xxLayer.kj_path = self.kj_shadowPath;
            self.xxLayer.kj_color = self.kj_shadowColor;
            self.xxLayer.kj_radius = self.kj_shadowRadius;
            self.xxLayer.kj_opacity = self.kj_shadowOpacity;
            self.xxLayer.kj_offset = CGSizeMake(self.kj_shadowDiffuse, -self.kj_shadowDiffuse);
            [self.xxLayer setNeedsDisplay];
            self.xxxLayer.kj_path = self.kj_shadowPath;
            self.xxxLayer.kj_color = self.kj_shadowColor;
            self.xxxLayer.kj_radius = self.kj_shadowRadius;
            self.xxxLayer.kj_opacity = self.kj_shadowOpacity;
            self.xxxLayer.kj_offset = CGSizeMake(-self.kj_shadowDiffuse, self.kj_shadowDiffuse);
            [self.xxxLayer setNeedsDisplay];
            break;
        default:
            break;
    }
    [self setNeedsDisplay];
}

#pragma mark - 属性相关
- (void)setKj_shadowPath:(UIBezierPath*)kj_shadowPath {
    _kj_shadowPath = kj_shadowPath;
    [self kj_changeShadowLayerValue];
}
- (void)setKj_shadowColor:(UIColor*)kj_shadowColor {
    _kj_shadowColor = kj_shadowColor;
    [self kj_changeShadowLayerValue];
}
- (void)setKj_shadowOffset:(CGSize)kj_shadowOffset {
    _kj_shadowOffset = kj_shadowOffset;
    [self kj_changeShadowLayerValue];
}
- (void)setKj_shadowRadius:(CGFloat)kj_shadowRadius {
    _kj_shadowRadius = kj_shadowRadius;
    [self kj_changeShadowLayerValue];
}
- (void)setKj_shadowOpacity:(CGFloat)kj_shadowOpacity {
    _kj_shadowOpacity = kj_shadowOpacity;
    [self kj_changeShadowLayerValue];
}
- (void)setKj_shadowAngle:(CGFloat)kj_shadowAngle {
    _kj_shadowAngle = kj_shadowAngle;
    [self kj_changeShadowLayerValue];
}
- (void)setKj_shadowDiffuse:(CGFloat)kj_shadowDiffuse {
    _kj_shadowDiffuse = kj_shadowDiffuse;
    [self kj_changeShadowLayerValue];
}

@end

