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
@property(nonatomic,assign) KJKnownPoints knownPoints;
@property(nonatomic,strong) CAShapeLayer *topLayer; /// 虚线选区
@property(nonatomic,assign) CGPoint touchBeginPoint; /// 记录touch开始的点
@property(nonatomic,assign) BOOL drawTop; /// 是否绘制顶部选区
@property(nonatomic,assign) BOOL clearDarw; /// 清除画布内容开关
@property(nonatomic,assign) BOOL sureDarw; /// 是否点在正确的选区内
@property(nonatomic,strong) UIImage *perspectiveImage; /// 透视好的素材图
@property(nonatomic,assign) CGRect imageRect;
@property(nonatomic,assign) KJKnownPoints topPoints;
@end

@implementation KJMuralView
/// 子类需要实现父类方法
- (bool)kj_delGestureWithPoint:(CGPoint)point{
    if (self.openDrawMural) {
        /// 不在透视选区内不做手势处理
        return [_KJIFinishTools kj_confirmCurrentPointWithPoint:point KnownPoints:self.knownPoints];
    }
    return false;
}
/// 重置
- (void)kj_clearLayers{
    self.sureDarw = self.drawTop = NO; /// 重置开关
    [_topLayer removeFromSuperlayer];
    _topLayer = nil;
    self.clearDarw = YES;
    [self setNeedsDisplay];
}
/// 初始化
- (instancetype)kj_initWithFrame:(CGRect)frame KnownPoints:(KJKnownPoints)points{
    if (self == [super init]) {
        self.backgroundColor = UIColor.clearColor;
        self.knownPoints = points;
        self.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.dashPatternColor = UIColor.blackColor;
        self.dashPatternWidth = 1.;
        self.sureDarw = NO;
        self.drawTop = NO;
        self.clearDarw = NO;
        self.layer.contentsScale = [[UIScreen mainScreen] scale];/// 绘图模糊有锯齿解决方案
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
@synthesize dashPatternColor = _dashPatternColor;
@synthesize dashPatternWidth = _dashPatternWidth;
- (void)setDashPatternColor:(UIColor*)dashPatternColor{
    _dashPatternColor = dashPatternColor;
    if (_topLayer) _topLayer.strokeColor = dashPatternColor.CGColor;
}
- (void)setDashPatternWidth:(CGFloat)dashPatternWidth{
    _dashPatternWidth = dashPatternWidth;
    if (_topLayer) _topLayer.lineWidth = dashPatternWidth;
}
- (void)setKChartletBlcok:(UIImage * _Nonnull (^)(KJKnownPoints, UIImage * _Nonnull))kChartletBlcok{
    self.perspectiveImage = kChartletBlcok(_topPoints,self.muralImage);
    if (_topLayer) {
        [_topLayer removeFromSuperlayer];
        _topLayer = nil;
        [self setNeedsDisplay];
//        _topLayer.lineWidth = 0.0;
//        UIImage *img = [self kj_rotationImage:image]; /// 上下翻转图片
//        UIColor *color = [UIColor colorWithPatternImage:image]; /// 图片转颜色
//        _topLayer.fillColor = color.CGColor;
    }
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
    CGPoint point = [touches.anyObject locationInView:self];
    /// 判断开始点是否在选区内
    if (![_KJIFinishTools kj_confirmCurrentPointWithPoint:point KnownPoints:self.knownPoints]) {
        return;
    }else{
        self.sureDarw = YES;
    }
    if (!_drawTop) self.touchBeginPoint = point;
}
/// 滑动当中
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.sureDarw) return; /// 未在正确选区内
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
    if (!_drawTop) {
        /// 判断开始点是否在选区内
        if (![_KJIFinishTools kj_confirmCurrentPointWithPoint:tempPoint KnownPoints:self.knownPoints]) return;
        [self kj_darwQuadrangleTopWithPoint:tempPoint];
    }
}
/// 触摸结束
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesEnded");
    [super touchesEnded:touches withEvent:event];
    if (self.sureDarw) {
        self.openDrawMural = false;
        self.drawTop = YES; /// 正确选区内
    }
}

#pragma mark - 内部处理方法
/// 操作画四边形顶部选区
- (void)kj_darwQuadrangleTopWithPoint:(CGPoint)tempPoint {
    /// 滑动方向
    KJSlideDirectionType directionType = [_KJIFinishTools kj_slideDirectionWithPoint:self.touchBeginPoint Point2:tempPoint];
    self.topPoints = [_KJIFinishTools kj_pointsWithKnownPoints:self.knownPoints BeginPoint:self.touchBeginPoint EndPoint:tempPoint DirectionType:directionType];
    self.topLayer.path = [self kj_topPath].CGPath;
    self.imageRect = [_KJIFinishTools kj_rectWithPoints:self.topPoints];
}
- (UIBezierPath*)kj_topPath{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:self.topPoints.PointA];
    [path addLineToPoint:self.topPoints.PointB];
    [path addLineToPoint:self.topPoints.PointC];
    [path addLineToPoint:self.topPoints.PointD];
    [path closePath];
    return path;
}
#pragma mark - 绘图
- (void)drawRect:(CGRect)rect{
    CGContextRef ctx = UIGraphicsGetCurrentContext(); //获取当前绘制环境
    CGContextSaveGState(ctx);
    if (self.clearDarw) {
        CGContextClearRect(ctx, self.bounds);//清除指定矩形区域上绘制的图形
        self.clearDarw = NO;
        return;
    }
    CGContextAddPath(ctx, [self kj_topPath].CGPath);
    CGContextClip(ctx); // 裁剪路径以外部分
    // 使用CGContextDrawImage绘制图片上下颠倒 用这个方法解决
    UIGraphicsPushContext(ctx);
    [self.perspectiveImage drawInRect:self.imageRect];
    UIGraphicsPopContext();
    CGContextRestoreGState(ctx);
}

@end
