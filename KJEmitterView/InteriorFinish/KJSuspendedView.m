//
//  KJSuspendedView.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/13.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJSuspendedView.h"
/// 凹凸方向
typedef NS_ENUM(NSInteger, KJConcaveConvexType) {
    KJConcaveConvexTypeConcave = 0,/// 向内凹
    KJConcaveConvexTypeConvex, /// 向外凸
};
/// 点坐标
typedef NS_ENUM(NSInteger, KJPointsType) {
    KJPointsTypeF,  /// F点
    KJPointsTypeH,  /// H点
    KJPointsTypeE1, /// E1点
    KJPointsTypeF1, /// F1点
    KJPointsTypeG1, /// G1点
    KJPointsTypeH1, /// H1点
};
static CGFloat minLen = 1.0; /// 最小的滑动距离
@interface KJSuspendedView ()
@property(nonatomic,assign) KJKnownPoints points;
@property(nonatomic,strong) CAShapeLayer *topLayer; /// 虚线选区
@property(nonatomic,assign) CGPoint touchBeginPoint; /// 记录touch开始的点
@property(nonatomic,assign) CGPoint PointE,PointF,PointG,PointH;
@property(nonatomic,assign) CGPoint PointE1,PointF1,PointG1,PointH1;
@property(nonatomic,assign) BOOL drawTop; /// 是否绘制顶部选区
@property(nonatomic,assign) BOOL drawLine; /// 是否拖拽形成凹凸部分
@property(nonatomic,assign) BOOL clearDarw; /// 清除画布内容开关
@property(nonatomic,assign) CGFloat lineLenght; /// 线条长度
@property(nonatomic,assign) KJSlideDirectionType directionType; /// 选区滑动方向
@property(nonatomic,assign) KJConcaveConvexType concaveType; /// 凹凸方向
@property(nonatomic,assign) CGFloat ovalW,ovalH; /// 椭圆的宽高
@end

@implementation KJSuspendedView
/// 初始化
- (instancetype)kj_initWithFrame:(CGRect)frame KnownPoints:(KJKnownPoints)points{
    if (self == [super init]) {
        self.points = points;
        self.frame = frame;
        self.maxLen = 100.;
        self.dashPatternColor = UIColor.blackColor;
        self.dashPatternWidth = 1.;
        self.drawTop = self.drawLine = NO;
        self.shapeType = KJDarwShapeTypeQuadrangle;
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
/// 重置
- (void)kj_clearLayers{
    self.ovalW = self.ovalH = 0.0; /// 重置椭圆的宽高
    self.drawTop = self.drawLine = NO; /// 重置开关
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
    if (_drawTop == YES && _drawLine == NO) {
        
    }
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
    if (self.shapeType == KJDarwShapeTypeOval) {
        if (!_drawTop) [self kj_darwOvalTopWithPoint:tempPoint];
        if (_drawTop == YES && _drawLine == NO) [self kj_drawOvalConcaveAndConvexWithPoint:tempPoint];
    }else {
       if (!_drawTop) [self kj_darwQuadrangleTopWithPoint:tempPoint];
       if (_drawTop == YES && _drawLine == NO) [self kj_drawQuadrangleConcaveAndConvexWithPoint:tempPoint];
    }
}
/// 触摸结束
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesEnded");
    [super touchesEnded:touches withEvent:event];
//    if (_drawTop == YES && _drawLine == NO) self.drawLine = YES;
    self.drawTop = YES;
}

#pragma mark - 内部处理方法
/// 操作画四边形顶部选区
- (void)kj_darwQuadrangleTopWithPoint:(CGPoint)tempPoint {
    self.PointG = tempPoint;
    self.PointF = [self kj_getPointWithPointsType:(KJPointsTypeF)];
    self.PointH = [self kj_getPointWithPointsType:(KJPointsTypeH)];
    self.topLayer.path = [self kj_topPath].CGPath;
    /// 滑动方向
    self.directionType = [self kj_slideDirectionWithPoint:self.PointE Point2:tempPoint];
}
/// 操作四边形凹凸选区
- (void)kj_drawQuadrangleConcaveAndConvexWithPoint:(CGPoint)tempPoint{
//    NSLog(@"-----x:%f,y:%f",tempPoint.x,tempPoint.y);
    CGFloat len = fabs(self.touchBeginPoint.y - tempPoint.y);/// 取绝对值
    self.lineLenght = len<self.maxLen?len:self.maxLen; /// 限制下拉距离
    /// 凹凸方向
    self.concaveType = [self kj_concaveConvesTypeWithPoint:tempPoint];
    /// 获取点坐标
    self.PointE1 = [self kj_getPointWithPointsType:(KJPointsTypeE1)];
    self.PointF1 = [self kj_getPointWithPointsType:(KJPointsTypeF1)];
    self.PointG1 = [self kj_getPointWithPointsType:(KJPointsTypeG1)];
    self.PointH1 = [self kj_getPointWithPointsType:(KJPointsTypeH1)];
    [_topLayer removeFromSuperlayer];
    _topLayer = nil;
    /// 调用drawRect方法 - 绘图
    [self setNeedsDisplay];
}
/// 操作画椭圆顶部选区
- (void)kj_darwOvalTopWithPoint:(CGPoint)tempPoint {
    self.PointG = tempPoint;
    /// 滑动方向
    self.directionType = [self kj_slideDirectionWithPoint:self.PointE Point2:tempPoint];
    self.ovalW = self.PointG.x - self.PointE.x;
    self.ovalH = self.PointG.y - self.PointE.y;
    self.topLayer.path = [self kj_topPath].CGPath;
}
/// 操作椭圆凹凸选区
- (void)kj_drawOvalConcaveAndConvexWithPoint:(CGPoint)tempPoint{
//    NSLog(@"-----x:%f,y:%f",tempPoint.x,tempPoint.y);
    CGFloat len = fabs(self.touchBeginPoint.y - tempPoint.y);/// 取绝对值
    self.lineLenght = len<self.maxLen?len:self.maxLen; /// 限制下拉距离
    /// 凹凸方向
    self.concaveType = [self kj_concaveConvesTypeWithPoint:tempPoint];
    /// 获取点坐标
    CGFloat y = self.PointE.y;
    if (self.concaveType == KJConcaveConvexTypeConcave) { /// 内凹
        y -= self.lineLenght;
    }else { /// 外凸
        y += self.lineLenght;
    }
    self.PointE1 = CGPointMake(self.PointE.x, y);
    [_topLayer removeFromSuperlayer];
    _topLayer = nil;
    /// 调用drawRect方法 - 绘图
    [self setNeedsDisplay];
}
/// 确定滑动方向
- (KJSlideDirectionType)kj_slideDirectionWithPoint:(CGPoint)point Point2:(CGPoint)point2{
    bool b1 = (point.x - point2.x) < 0 ? true : false;
    bool b2 = (point.y - point2.y) < 0 ? true : false;
    if (b1&b2) return KJSlideDirectionTypeLeftBottom;
    if (!b1&!b2) return KJSlideDirectionTypeRightTop;
    if (b1) return KJSlideDirectionTypeLeftTop;
    return KJSlideDirectionTypeRightBottom;
}
/// 判断是凹进去还是凸出来
- (KJConcaveConvexType)kj_concaveConvesTypeWithPoint:(CGPoint)tempPoint{
    if (self.touchBeginPoint.y - tempPoint.y > 0) {
        return KJConcaveConvexTypeConcave;/// 向内凹
    }else{
        return KJConcaveConvexTypeConvex; /// 向外凸
    }
}
/// 获取点坐标
- (CGPoint)kj_getPointWithPointsType:(KJPointsType)type{
    CGPoint point = CGPointZero;
    switch (type) {
        case KJPointsTypeF:
            point = kj_FPoint(self.points.PointA, self.points.PointB, self.points.PointC, self.points.PointD, self.PointE, self.PointG);
            break;
        case KJPointsTypeH:
            point = kj_HPoint(self.points.PointA, self.points.PointB, self.points.PointC, self.points.PointD, self.PointE, self.PointG);
            break;
        case KJPointsTypeE1:
            point = kj_E1Point(self.points.PointA, self.points.PointB, self.points.PointC, self.points.PointD, self.PointE, self.PointG,self.lineLenght,self.concaveType);
            break;
        case KJPointsTypeF1:
            point = kj_F1Point(self.points.PointA, self.points.PointB, self.points.PointC, self.points.PointD, self.PointE, self.PointG,self.lineLenght,self.concaveType);
            break;
        case KJPointsTypeG1:
            point = kj_G1Point(self.points.PointA, self.points.PointB, self.points.PointC, self.points.PointD, self.PointE, self.PointG,self.lineLenght,self.concaveType);
            break;
        case KJPointsTypeH1:
            point = kj_H1Point(self.points.PointA, self.points.PointB, self.points.PointC, self.points.PointD, self.PointE, self.PointG,self.lineLenght,self.concaveType);
            break;
        default:
            break;
    }
    return point;;
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
    if (self.shapeType == KJDarwShapeTypeOval) { /// 椭圆
        if (self.concaveType == KJConcaveConvexTypeConcave) {
            [[self kj_topPath] addClip];/// 当前path路径可见，其余位置隐藏
            [self kj_drawWithCtx:ctx Path:[self kj_topPath] FillColor:UIColor.redColor];
        }else{
            CGFloat x = self.PointE.x;
            CGFloat y = self.PointE.y + self.ovalH*.5;
            CGFloat w = fabs(self.ovalW); /// 取绝对值
            if (self.directionType == KJSlideDirectionTypeRightBottom || self.directionType == KJSlideDirectionTypeRightTop) {
                x += self.ovalW;
            }
            UIBezierPath *orthogonPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x,y,w,self.lineLenght) cornerRadius:0.0]; /// 矩形路径
            UIBezierPath *topPath = [self kj_topPath];
            [topPath appendPath:orthogonPath]; /// 追加路径
//            UIBezierPath *topPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x+w/2., y) radius:w startAngle:M_PI endAngle:0 clockwise:YES];
            [self kj_drawWithCtx:ctx Path:topPath FillColor:UIColor.redColor];
        }
        [self kj_drawWithCtx:ctx Path:[self kj_bottomPath] FillColor:UIColor.greenColor];
    }else if (self.shapeType == KJDarwShapeTypeQuadrangle) { /// 四边形
        if (self.concaveType == KJConcaveConvexTypeConcave) {
            CGContextAddPath(ctx, [self kj_topPath].CGPath);
            CGContextClip(ctx); // 裁剪路径以外部分
        }
        if (self.kChartletBlcok) {
            KJSuspendedModel *model = [[KJSuspendedModel alloc]init];
            model = self.kChartletBlcok(model);
        }
        [self kj_drawOrderWithCtx:ctx];
    }
    CGContextRestoreGState(ctx);
}
- (void)kj_drawWithCtx:(CGContextRef)ctx Path:(UIBezierPath*)path FillColor:(UIColor*)color{
    CGContextSetLineWidth(ctx, 1); //设置线条宽度
    CGContextSetLineJoin(ctx, kCGLineJoinRound);// 连接节点样式
    CGContextSetLineCap(ctx, kCGLineCapRound);// 线头样式
    CGContextSetStrokeColorWithColor(ctx, UIColor.clearColor.CGColor);//设置线条颜色
    CGContextSetFillColorWithColor(ctx, color.CGColor);//填充颜色
    CGContextAddPath(ctx, path.CGPath);
    CGContextDrawPath(ctx, kCGPathFillStroke); //绘制路径
}
/// 确定绘制图层层级 - 绘制的先后顺序
- (void)kj_drawOrderWithCtx:(CGContextRef)ctx{
    if (self.concaveType == KJConcaveConvexTypeConvex) { /// 外凸
        switch (self.directionType) {
            case KJSlideDirectionTypeLeftBottom:/// 左下
            case KJSlideDirectionTypeRightBottom:/// 右下
                [self kj_drawWithCtx:ctx Path:[self kj_backPath] FillColor:[UIColor.purpleColor colorWithAlphaComponent:1]];
                [self kj_drawWithCtx:ctx Path:[self kj_leftPath] FillColor:[UIColor.greenColor colorWithAlphaComponent:1]];
                [self kj_drawWithCtx:ctx Path:[self kj_rightPath] FillColor:[UIColor.yellowColor colorWithAlphaComponent:1]];
                [self kj_drawWithCtx:ctx Path:[self kj_bottomPath] FillColor:[UIColor.redColor colorWithAlphaComponent:1]];
                [self kj_drawWithCtx:ctx Path:[self kj_frontPath] FillColor:[UIColor.blueColor colorWithAlphaComponent:1]];
                break;
            case KJSlideDirectionTypeLeftTop:/// 左上
            case KJSlideDirectionTypeRightTop:/// 右上
                [self kj_drawWithCtx:ctx Path:[self kj_frontPath] FillColor:[UIColor.blueColor colorWithAlphaComponent:1]];
                [self kj_drawWithCtx:ctx Path:[self kj_rightPath] FillColor:[UIColor.yellowColor colorWithAlphaComponent:1]];
                [self kj_drawWithCtx:ctx Path:[self kj_leftPath] FillColor:[UIColor.greenColor colorWithAlphaComponent:1]];
                [self kj_drawWithCtx:ctx Path:[self kj_bottomPath] FillColor:[UIColor.redColor colorWithAlphaComponent:1]];
                [self kj_drawWithCtx:ctx Path:[self kj_backPath] FillColor:[UIColor.purpleColor colorWithAlphaComponent:1]];
                break;
            default:
                break;
        }
    }else { /// 内凹
        switch (self.directionType) {
            case KJSlideDirectionTypeLeftBottom:/// 左下
            case KJSlideDirectionTypeRightBottom:/// 右下
                [self kj_drawWithCtx:ctx Path:[self kj_bottomPath] FillColor:[UIColor.redColor colorWithAlphaComponent:1]];
                [self kj_drawWithCtx:ctx Path:[self kj_backPath] FillColor:[UIColor.purpleColor colorWithAlphaComponent:1]];
                [self kj_drawWithCtx:ctx Path:[self kj_leftPath] FillColor:[UIColor.greenColor colorWithAlphaComponent:1]];
                [self kj_drawWithCtx:ctx Path:[self kj_rightPath] FillColor:[UIColor.yellowColor colorWithAlphaComponent:1]];
                [self kj_drawWithCtx:ctx Path:[self kj_frontPath] FillColor:[UIColor.blueColor colorWithAlphaComponent:1]];
                break;
            case KJSlideDirectionTypeLeftTop:/// 左上
            case KJSlideDirectionTypeRightTop:/// 右上
                [self kj_drawWithCtx:ctx Path:[self kj_bottomPath] FillColor:[UIColor.redColor colorWithAlphaComponent:1]];
                [self kj_drawWithCtx:ctx Path:[self kj_backPath] FillColor:[UIColor.purpleColor colorWithAlphaComponent:1]];
                [self kj_drawWithCtx:ctx Path:[self kj_leftPath] FillColor:[UIColor.greenColor colorWithAlphaComponent:1]];
                [self kj_drawWithCtx:ctx Path:[self kj_rightPath] FillColor:[UIColor.yellowColor colorWithAlphaComponent:1]];
                [self kj_drawWithCtx:ctx Path:[self kj_frontPath] FillColor:[UIColor.blueColor colorWithAlphaComponent:1]];
                break;
            default:
                break;
        }
    }
}

#pragma mark - 路径处理
/// 镂空路径
- (UIBezierPath*)kj_hollowOutPath{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.usesEvenOddFillRule = YES;//设置填充规则为奇偶填充
    [path moveToPoint:self.points.PointA];
    [path addLineToPoint:self.points.PointB];
    [path addLineToPoint:self.points.PointC];
    [path addLineToPoint:self.points.PointD];
    [path addLineToPoint:self.points.PointA];
    
    UIBezierPath *bPath = [UIBezierPath bezierPath];
    [bPath moveToPoint:self.PointE];
    [bPath addLineToPoint:self.PointH];
    [bPath addLineToPoint:self.PointG];
    [bPath addLineToPoint:self.PointF];
    [bPath addLineToPoint:self.PointE];
    [path appendPath:bPath];
    return path;
}
- (UIBezierPath*)kj_topPath{
    if (self.shapeType == KJDarwShapeTypeOval) {
        CGFloat x = self.PointE.x;
        CGFloat y = self.PointE.y;
        return [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x,y,self.ovalW,self.ovalH)];/// 椭圆路径
    }else {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:self.PointE];
        [path addLineToPoint:self.PointH];
        [path addLineToPoint:self.PointG];
        [path addLineToPoint:self.PointF];
        [path closePath];
        return path;
    }
}
- (UIBezierPath*)kj_bottomPath{
    if (self.shapeType == KJDarwShapeTypeOval) {
        CGFloat x = self.PointE1.x;
        CGFloat y = self.PointE1.y;
        return [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x,y,self.ovalW,self.ovalH)];/// 椭圆路径
    }else {
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.usesEvenOddFillRule = YES;
        [path moveToPoint:self.PointE1];
        [path addLineToPoint:self.PointF1];
        [path addLineToPoint:self.PointG1];
        [path addLineToPoint:self.PointH1];
        [path closePath];
        return path;
    }
}
- (UIBezierPath*)kj_frontPath{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.usesEvenOddFillRule = YES;
    [path moveToPoint:self.PointE];
    [path addLineToPoint:self.PointE1];
    [path addLineToPoint:self.PointH1];
    [path addLineToPoint:self.PointH];
    [path closePath];
    return path;
}
- (UIBezierPath*)kj_backPath{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.usesEvenOddFillRule = YES;
    [path moveToPoint:self.PointF];
    [path addLineToPoint:self.PointF1];
    [path addLineToPoint:self.PointG1];
    [path addLineToPoint:self.PointG];
    [path closePath];
    return path;
}
- (UIBezierPath*)kj_leftPath{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.usesEvenOddFillRule = YES;
    [path moveToPoint:self.PointE];
    [path addLineToPoint:self.PointE1];
    [path addLineToPoint:self.PointF1];
    [path addLineToPoint:self.PointF];
    [path closePath];
    return path;
}
- (UIBezierPath*)kj_rightPath{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.usesEvenOddFillRule = YES;
    [path moveToPoint:self.PointH];
    [path addLineToPoint:self.PointH1];
    [path addLineToPoint:self.PointG1];
    [path addLineToPoint:self.PointG];
    [path closePath];
    return path;
}

#pragma mark - 找点方法
/// 获取F点
static inline CGPoint kj_FPoint(CGPoint A,CGPoint B,CGPoint C,CGPoint D,CGPoint E,CGPoint G){
    CGPoint O = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:A Point2:B Point3:C Point4:D];//kj_linellaeCrosspoint(A,B,C,D);
    CGPoint M = [_KJIFinishTools kj_parallelLineDotsWithPoint1:B Point2:C Point3:G];//kj_parallelLineDots(B,C,G);
    return [_KJIFinishTools kj_linellaeCrosspointWithPoint1:E Point2:O Point3:M Point4:G];//kj_linellaeCrosspoint(E,O,M,G);
}
/// 获取H点
static inline CGPoint kj_HPoint(CGPoint A,CGPoint B,CGPoint C,CGPoint D,CGPoint E,CGPoint G){
    CGPoint O = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:A Point2:B Point3:C Point4:D];
    CGPoint M1 = [_KJIFinishTools kj_parallelLineDotsWithPoint1:A Point2:D Point3:E];//kj_parallelLineDots(A,D,E);
    return [_KJIFinishTools kj_linellaeCrosspointWithPoint1:G Point2:O Point3:M1 Point4:E];//kj_linellaeCrosspoint(G,O,M1,E);
}
/// 获取E1点
static inline CGPoint kj_E1Point(CGPoint A,CGPoint B,CGPoint C,CGPoint D,CGPoint E,CGPoint G,CGFloat len,BOOL positive){
    CGPoint O = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:A Point2:B Point3:C Point4:D];
    CGPoint H = kj_HPoint(A, B, C, D, E, G);
    CGPoint F1 = kj_F1Point(A, B, C, D, E, G, len, positive);
    CGPoint E2 = [_KJIFinishTools kj_perpendicularLineDotsWithPoint1:H Point2:E VerticalLenght:len Positive:positive ];//kj_perpendicularLineDots(H,E,len,positive);
    return [_KJIFinishTools kj_linellaeCrosspointWithPoint1:O Point2:F1 Point3:E Point4:E2];//kj_linellaeCrosspoint(O,F1,E,E2);
}
/// 获取H1点
static inline CGPoint kj_H1Point(CGPoint A,CGPoint B,CGPoint C,CGPoint D,CGPoint E,CGPoint G,CGFloat len,BOOL positive){
    CGPoint H = kj_HPoint(A, B, C, D, E, G);
    CGPoint H2 = [_KJIFinishTools kj_perpendicularLineDotsWithPoint1:E Point2:H VerticalLenght:len Positive:positive ];//kj_perpendicularLineDots(E,H,len,positive);
    CGPoint E1 = kj_E1Point(A, B, C, D, E, G, len, positive);
    CGPoint M = [_KJIFinishTools kj_parallelLineDotsWithPoint1:H Point2:E Point3:E1];//kj_parallelLineDots(H,E,E1);
    return [_KJIFinishTools kj_linellaeCrosspointWithPoint1:E1 Point2:M Point3:H Point4:H2];//kj_linellaeCrosspoint(E1,M,H,H2);
}
/// 获取F1点
static inline CGPoint kj_F1Point(CGPoint A,CGPoint B,CGPoint C,CGPoint D,CGPoint E,CGPoint G,CGFloat len,BOOL positive){
    CGPoint F = kj_FPoint(A, B, C, D, E, G);
    return [_KJIFinishTools kj_perpendicularLineDotsWithPoint1:G Point2:F VerticalLenght:len Positive:positive ];//kj_perpendicularLineDots(G,F,len,positive);
}
/// 获取G1点
static inline CGPoint kj_G1Point(CGPoint A,CGPoint B,CGPoint C,CGPoint D,CGPoint E,CGPoint G,CGFloat len,BOOL positive){
    CGPoint F = kj_FPoint(A, B, C, D, E, G);
    return [_KJIFinishTools kj_perpendicularLineDotsWithPoint1:F Point2:G VerticalLenght:len Positive:positive ];//kj_perpendicularLineDots(F,G,len,positive);
}

@end

@implementation KJSuspendedModel
@end