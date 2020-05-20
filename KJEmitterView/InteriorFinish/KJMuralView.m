//
//  KJMuralView.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/20.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJMuralView.h"
static CGFloat minLen = 1.0; /// 最小的滑动距离
@interface KJMuralView ()
@property(nonatomic,assign) KJKnownPoint points;
@property(nonatomic,strong) CAShapeLayer *topLayer; /// 虚线选区
@property(nonatomic,assign) CGPoint touchBeginPoint; /// 记录touch开始的点
@property(nonatomic,assign) CGPoint PointE,PointF,PointG,PointH;
@property(nonatomic,assign) BOOL drawTop; /// 是否绘制顶部选区
@property(nonatomic,assign) BOOL clearDarw; /// 清除画布内容开关
@end

@implementation KJMuralView

/// 初始化
- (instancetype)kj_initWithFrame:(CGRect)frame KnownPoints:(KJKnownPoint)points{
    if (self == [super init]) {
        self.points = points;
        self.frame = frame;
        self.dashPatternColor = UIColor.blackColor;
        self.dashPatternWidth = 1.;
        self.drawTop = NO;
        self.clearDarw = NO;
    }
    return self;
}
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
        [self.layer addSublayer:_topLayer];
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
- (void)setKChartletBlcok:(UIImage * _Nonnull (^)(KJKnownPoint, UIImage * _Nonnull))kChartletBlcok{
    KJKnownPoint points = {self.PointE,self.PointF,self.PointG,self.PointH};
    UIImage *image = kChartletBlcok(points,self.muralImage);
    if (_topLayer) {
        _topLayer.lineWidth = 0.0;
//        UIImage *img = [self kj_rotationImage:image]; /// 上下翻转图片
        UIColor *color = [UIColor colorWithPatternImage:image]; /// 图片转颜色
        _topLayer.fillColor = color.CGColor;
    }
}
/// 重置
- (void)kj_clearLayers{
    self.drawTop = NO; /// 重置开关
    [_topLayer removeFromSuperlayer];
    _topLayer = nil;
    self.clearDarw = YES;
    [self setNeedsDisplay];
}
#pragma mark - touches
/// 触摸开始
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
    NSLog(@"touchesBegan");
    // 这个是用来判断, 如果有多个手指点击则不做出响应
    UITouch *touch = (UITouch *)touches.anyObject;
    if (touches.count > 1 || [touch tapCount] > 1 || event.allTouches.count > 1) {
        return;
    }
    // 这个是用来判断, 手指点击的是不是本视图, 如果不是则不做出响应
    if (![[(UITouch *)touches.anyObject view] isEqual:self]) {
        return;
    }
    [super touchesBegan:touches withEvent:event];
    // 设置起始位置
    self.touchBeginPoint = [touches.anyObject locationInView:self];
    if (!_drawTop) self.PointE = self.touchBeginPoint;
}
/// 滑动当中
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = (UITouch *)touches.anyObject;
    if (touches.count > 1 || [touch tapCount] > 1  || event.allTouches.count > 1) {
        return;
    }
    if (![[(UITouch *)touches.anyObject view] isEqual:self]) {
        return;
    }
    [super touchesMoved:touches withEvent:event];
    
    //1.如果移动的距离过于小则判断为没有移动
    CGPoint tempPoint = [touches.anyObject locationInView:self];
    if (fabs(tempPoint.x - self.touchBeginPoint.x) < minLen && fabs(tempPoint.y - self.touchBeginPoint.y) < minLen) {
        return;
    }
    if (!_drawTop) [self kj_darwQuadrangleTopWithPoint:tempPoint];
}
/// 触摸结束
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesEnded");
    [super touchesEnded:touches withEvent:event];
    self.drawTop = YES;
}

#pragma mark - 内部处理方法
/// 操作画四边形顶部选区
- (void)kj_darwQuadrangleTopWithPoint:(CGPoint)tempPoint {
    self.PointG = tempPoint;
    CGPoint A = self.points.PointA;
    CGPoint B = self.points.PointB;
    CGPoint C = self.points.PointC;
    CGPoint D = self.points.PointD;
    CGPoint O = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:A Point2:B Point3:C Point4:D];
    CGPoint M = [_KJIFinishTools kj_parallelLineDotsWithPoint1:B Point2:C Point3:self.PointG];
    self.PointF = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:self.PointE Point2:O Point3:M Point4:self.PointG];
    
    CGPoint N = [_KJIFinishTools kj_parallelLineDotsWithPoint1:A Point2:D Point3:self.PointE];
    self.PointH = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:self.PointG Point2:O Point3:N Point4:self.PointE];

    self.topLayer.path = [self kj_topPath].CGPath;
}
- (UIBezierPath*)kj_topPath{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:self.PointE];
    [path addLineToPoint:self.PointH];
    [path addLineToPoint:self.PointG];
    [path addLineToPoint:self.PointF];
    [path closePath];
    return path;
}
//#pragma mark - 绘图
//- (void)drawRect:(CGRect)rect{
//    CGContextRef ctx = UIGraphicsGetCurrentContext(); //获取当前绘制环境
//    CGContextSaveGState(ctx);
//    if (self.clearDarw) {
//        CGContextClearRect(ctx, self.bounds);//清除指定矩形区域上绘制的图形
//        self.clearDarw = NO;
//        return;
//    }
//    CGContextAddPath(ctx, [self kj_topPath].CGPath);
//    CGContextClip(ctx); // 裁剪路径以外部分
////    if (self.kChartletBlcok) {
////        KJSuspendedModel *model = [[KJSuspendedModel alloc]init];
////        model = self.kChartletBlcok(model);
////    }
//    CGContextSetLineWidth(ctx, 1); //设置线条宽度
//    CGContextSetLineJoin(ctx, kCGLineJoinRound);// 连接节点样式
//    CGContextSetLineCap(ctx, kCGLineCapRound);// 线头样式
//    CGContextSetStrokeColorWithColor(ctx, UIColor.clearColor.CGColor);//设置线条颜色
//    CGContextSetFillColorWithColor(ctx, color.CGColor);//填充颜色
//    CGContextAddPath(ctx, [self kj_topPath].CGPath);
//    CGContextDrawPath(ctx, kCGPathFillStroke); //绘制路径
//    CGContextRestoreGState(ctx);
//}

@end
