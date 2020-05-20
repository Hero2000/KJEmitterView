//
//  KJLegWireLayer.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/19.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJLegWireLayer.h"

@interface KJLegWireLayer ()
@property(nonatomic,strong) CAShapeLayer *topLayer; /// 虚线选区
@property(nonatomic,assign) CGFloat legWireWidth;
@property(nonatomic,assign) CGFloat legWireHeight;/// 脚线高度，默认选区墙高度的10%
@property(nonatomic,assign) CGPoint PointE,PointF,PointG,PointH;
@property(nonatomic,strong) UIImage *jointImage; /// 拼接好的素材图
@property(nonatomic,strong) UIImage *perspectiveImage; /// 透视好的素材图
@property(nonatomic,assign) CGRect imageRect;
@end

@implementation KJLegWireLayer
/// 重置
- (void)kj_clearLayers{
    [_topLayer removeFromSuperlayer];
    _topLayer = nil;
}
/// 初始化
- (instancetype)kj_initWithFrame:(CGRect)frame KnownPoints:(KJKnownPoint)points Size:(CGSize)size LegWireHeight:(CGFloat)height{
    if (self == [super init]) {
//        self.backgroundColor = UIColor.yellowColor.CGColor;
        self.drawsAsynchronously = YES;// 进行异步绘制
        self.contentsScale = [UIScreen mainScreen].scale;
        self.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.legWireHeight = height ? height : size.height / 10.0;
        self.legWireWidth = size.width;
        self.dashPatternColor = UIColor.blackColor;
        self.dashPatternWidth = 1.;
        [self kj_getFourPoints:points]; /// 找到路径四点
        self.topLayer.path = [self kj_topPath].CGPath;
    }
    return self;
}
- (void)layoutSublayers {
    [super layoutSublayers];
    [self setNeedsDisplay];
}
#pragma mark - geter/seter
- (CAShapeLayer*)topLayer{
    if (!_topLayer) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.fillColor = [UIColor.redColor colorWithAlphaComponent:0.0].CGColor;
        shapeLayer.strokeColor = self.dashPatternColor.CGColor;
        shapeLayer.lineWidth = self.dashPatternWidth;
        shapeLayer.lineCap = kCALineCapButt;
        shapeLayer.lineDashPattern = @[@(5),@(5)];// 实线长度和虚线长度间隔
        shapeLayer.fillRule = kCAFillRuleEvenOdd;// 两个路径相交会消掉(偶消积不消)
        shapeLayer.lineJoin = kCALineJoinRound;// 连接节点样式
        shapeLayer.lineCap = kCALineCapRound;// 线头样式
        _topLayer = shapeLayer;
        [self addSublayer:_topLayer];
    }
    return _topLayer;
}
- (void)setDashPatternColor:(UIColor*)dashPatternColor{
    _dashPatternColor = dashPatternColor;
    if (_topLayer) _topLayer.strokeColor = dashPatternColor.CGColor;
}
- (void)setDashPatternWidth:(CGFloat)dashPatternWidth{
    _dashPatternWidth = dashPatternWidth;
    if (_topLayer) _topLayer.lineWidth = dashPatternWidth;
}
- (void)setMaterialImage:(UIImage *)materialImage{
    _materialImage = materialImage;
    [self kj_jointImage];
}
- (void)setKChartletBlcok:(UIImage * _Nonnull (^)(KJKnownPoint, UIImage * _Nonnull))kChartletBlcok{
    KJKnownPoint points = {self.PointE,self.PointF,self.PointG,self.PointH};
    self.perspectiveImage = kChartletBlcok(points,self.jointImage);
    if (_topLayer) {
//        _topLayer.lineWidth = 0.0;
//        UIColor *color = [UIColor colorWithPatternImage:image]; /// 图片转颜色
//        _topLayer.fillColor = color.CGColor;
        [self kj_clearLayers];
        [self setNeedsDisplay];
    }
}
#pragma mark - 绘制
- (void)drawInContext:(CGContextRef)context {
    CGContextAddPath(context, [self kj_topPath].CGPath);
    CGContextClip(context); // 裁剪路径以外部分
//    [self.perspectiveImage drawInRect:self.imageRect];//在坐标中画出图片
//    [self.perspectiveImage drawAtPoint:self.imageRect.origin];//保持图片大小在point点开始画图片，可以把注释去掉看看
//    CGContextDrawImage(context,self.imageRect,self.perspectiveImage.CGImage);//使用这个使图片上下颠倒
//    CGContextDrawTiledImage(context, CGRectMake(0,0,20,20), self.perspectiveImage.CGImage);//平铺图
    
    // 使用CGContextDrawImage绘制图片上下颠倒 用这个方法解决
    UIGraphicsPushContext(context);
    [self.perspectiveImage drawInRect:self.imageRect];
    UIGraphicsPopContext();
}

#pragma mark - 内部方法
- (UIBezierPath*)kj_topPath{
    return ({
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:self.PointE];
        [path addLineToPoint:self.PointH];
        [path addLineToPoint:self.PointG];
        [path addLineToPoint:self.PointF];
        [path closePath];
        path;
    });
}
/// 拼接素材图
- (void)kj_jointImage{
    CGFloat w = _materialImage.size.width * self.legWireHeight / _materialImage.size.height;
    CGFloat xw = self.legWireWidth / w;
    CGFloat rw = roundf(xw);
    int row = xw<=rw ? rw : rw+1;
    /// 设置画布尺寸
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.legWireWidth, self.legWireHeight) ,NO, 0.0);
    CGFloat x = 0;
    for (int i=0; i<row; i++) {
        x = w * i;
        [_materialImage drawInRect:CGRectMake(x,0,w,self.legWireHeight)];
    }
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.jointImage = resultingImage;
}
/// 获取对应的4点
- (void)kj_getFourPoints:(KJKnownPoint)points{
    CGPoint A = points.PointA;
    CGPoint B = points.PointB;
    CGPoint C = points.PointC;
    CGPoint D = points.PointD;
    CGPoint M = [_KJIFinishTools kj_perpendicularLineDotsWithPoint1:C Point2:B VerticalLenght:self.legWireHeight Positive:NO];
    CGPoint O = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:A Point2:D Point3:B Point4:C];
    if (CGPointEqualToPoint(CGPointZero, O)) { /// 重合或者平行
        CGPoint X = [_KJIFinishTools kj_parallelLineDotsWithPoint1:B Point2:C Point3:M];
        self.PointE = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:X Point2:M Point3:A Point4:B];
        self.PointF = B;self.PointG = C;
        self.PointH = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:X Point2:M Point3:C Point4:D];
    }else{
        self.PointE = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:O Point2:M Point3:A Point4:B];
        self.PointF = B;self.PointG = C;
        self.PointH = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:O Point2:M Point3:C Point4:D];
    }
    KJKnownPoint kp = {self.PointE,self.PointF,self.PointG,self.PointH};
    self.imageRect = [_KJIFinishTools kj_rectWithPoints:kp];
}

@end
