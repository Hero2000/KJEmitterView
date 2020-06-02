//
//  KJDecorateBoxView.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/28.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJDecorateBoxView.h"
typedef NS_ENUM(NSInteger, KJDecorateDotType) {
    KJDecorateDotTypeLeftTop,    /// 左上
    KJDecorateDotTypeRightTop,   /// 右上
    KJDecorateDotTypeLeftBottom, /// 左下
    KJDecorateDotTypeRightBottom,/// 右下
};
static CGFloat minLen = 1.0; /// 最小的滑动距离
/// 装饰类
@interface KJDecorateView : UIView
@property(nonatomic,assign) CGPoint currentCenter;/// 视图中心点
@property(nonatomic,assign) KJKnownPoints points;
@property(nonatomic,assign) CGPoint touchBeginPoint; /// 记录touch开始的点
@property(nonatomic,strong) UIImage *perspectiveImage; /// 透视好的素材图
@property(nonatomic,assign) KJDecorateDotType currentDecorateDotType; /// 当前拖动点位置
@property(nonatomic,readwrite,copy) void (^kChartletMoveBlcok)(CGPoint currentPoint,KJDecorateDotType type); /// 贴图之后移动四个角落当中某一个回调处理
@end
@interface KJDecorateBoxView ()
@property(nonatomic,assign) KJSlideDirectionType directionType; /// 选区滑动方向
@property(nonatomic,assign) KJKnownPoints knownPoints;/// 外界区域四点
@property(nonatomic,strong) CAShapeLayer *topLayer; /// 虚线选区
@property(nonatomic,assign) CGPoint touchBeginPoint; /// 记录touch开始的点
@property(nonatomic,assign) KJKnownPoints drawPoints;/// 拖动形成的四点区域
//@property(nonatomic,strong) NSMutableArray <KJDecorateView*>*temps; /// 存储装饰容器
@end

@implementation KJDecorateBoxView
/// 子类需要实现父类方法
- (bool)kj_delGestureWithPoint:(CGPoint)point{
    if (self.openDrawDecorateBox) {
        /// 不在透视选区内不做手势处理
        return [_KJIFinishTools kj_confirmCurrentPointWithPoint:point KnownPoints:self.knownPoints];
    }
    return false;
}
/// 重置
- (void)kj_clearLayers{
    
}
/// 初始化
- (instancetype)kj_initWithFrame:(CGRect)frame KnownPoints:(KJKnownPoints)points{
    if (self == [super init]) {
        self.backgroundColor = UIColor.clearColor;
        self.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.dashPatternColor = UIColor.blackColor;
        self.dashPatternWidth = 1.;
        self.knownPoints = points;
        self.layer.contentsScale = [[UIScreen mainScreen] scale];/// 绘图模糊有锯齿解决方案
//        self.temps = [NSMutableArray array];
    }
    return self;
}
/// 贴图并且固定装饰品
- (bool)kj_chartletAndFixationWithMaterialImage:(UIImage*)materialImage Point:(CGPoint)point PerspectiveBlock:(UIImage *(^)(KJKnownPoints points,UIImage *materialImage))block{
    /// 判断当前是否有虚线区域，优先满足是否拖动到正确虚线区域
    if (_topLayer) {
        if ([_KJIFinishTools kj_confirmCurrentPointWithPoint:point KnownPoints:self.drawPoints]) {
            if (block) {
                CGRect rect = [_KJIFinishTools kj_rectWithPoints:self.drawPoints];
                KJDecorateView *view = [[KJDecorateView alloc]initWithFrame:rect];
                view.backgroundColor = [UIColor.yellowColor colorWithAlphaComponent:0.3];
                view.tag = self.subviews.count + 500; /// 编号
                view.userInteractionEnabled = NO;
                view.points = self.drawPoints;
                view.perspectiveImage = block(self.drawPoints,materialImage);/// 获取到透视好的素材图
                view.kChartletMoveBlcok = ^(CGPoint currentPoint, KJDecorateDotType type) {
                    NSLog(@"----%.2f,%.2f  %ld",currentPoint.x,currentPoint.y,(long)type);
                };
//                [self.temps addObject:view]; /// 存入容器
                [self addSubview:view];
                [self kj_setNull]; /// 置空处理
            }
            return true;
        }else{
            return false;
        }
    }
    /// 判断是否在已存在的装饰区域
    __block bool boo = false;
    __weak typeof(self) weakself = self;
    [self.subviews enumerateObjectsUsingBlock:^(KJDecorateView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint childPoint = [weakself convertPoint:point toView:obj];
        BOOL result = [obj.layer containsPoint:childPoint];
        if (result) {
            obj.perspectiveImage = block(obj.points,materialImage);/// 获取到透视好的素材图
            [obj setNeedsDisplay];
            boo = true;
            *stop = YES;
        }
    }];
    return boo;
}
/// 置空处理
- (void)kj_setNull{
    self.drawPoints = (KJKnownPoints){CGPointZero,CGPointZero,CGPointZero,CGPointZero};
    [self.topLayer removeFromSuperlayer];
    _topLayer = nil;
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
- (void)setOpenDrawDecorateBox:(bool)openDrawDecorateBox{
    _openDrawDecorateBox = openDrawDecorateBox;
    if (openDrawDecorateBox == false) {
        [self kj_setNull];
        /// 打开容器子类里面的手势操作
        [self.subviews enumerateObjectsUsingBlock:^(KJDecorateView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.userInteractionEnabled = YES;
        }];
    }else{
        [self.subviews enumerateObjectsUsingBlock:^(KJDecorateView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.userInteractionEnabled = NO;
        }];
    }
}
#pragma mark - touches
/// 触摸开始
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
    if (self.openDrawDecorateBox == false) return;
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
}
/// 滑动当中
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.openDrawDecorateBox == false) return;
    UITouch *touch = (UITouch *)touches.anyObject;
    if (touches.count > 1 || [touch tapCount] > 1 || event.allTouches.count > 1) {
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
    /// 判断是否超出区域
    if (![_KJIFinishTools kj_confirmCurrentPointWithPoint:tempPoint KnownPoints:self.knownPoints]) return;
    /// 处理滑动形成的四边形区域
    [self kj_delSlideAreaWithTempPoint:tempPoint];
}
/// 触摸结束
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesEnded");
    [super touchesEnded:touches withEvent:event];
}
/// 处理滑动形成的四边形区域
- (void)kj_delSlideAreaWithTempPoint:(CGPoint)tempPoint{
    self.drawPoints = [self kj_pointsWithKnownPoints:self.knownPoints TempPoint:tempPoint];
    self.topLayer.path = ({
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:self.drawPoints.PointA];
        [path addLineToPoint:self.drawPoints.PointB];
        [path addLineToPoint:self.drawPoints.PointC];
        [path addLineToPoint:self.drawPoints.PointD];
        [path closePath];
        path.CGPath;
    });
}
- (KJKnownPoints)kj_pointsWithKnownPoints:(KJKnownPoints)knownPoints TempPoint:(CGPoint)tempPoint{
    CGPoint A = knownPoints.PointA;
    CGPoint B = knownPoints.PointB;
    CGPoint C = knownPoints.PointC;
    CGPoint D = knownPoints.PointD;
    CGPoint E = self.touchBeginPoint;
    CGPoint F = CGPointZero;
    CGPoint G = tempPoint;
    CGPoint H = CGPointZero;
    CGPoint O1 = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:A Point2:B Point3:C Point4:D];/// AB和CD交点
    CGPoint O2 = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:A Point2:D Point3:C Point4:B];/// AD和CB交点
    /// 重合或者平行
    if (CGPointEqualToPoint(CGPointZero,O1) && CGPointEqualToPoint(CGPointZero,O2)) {
        CGPoint M = [_KJIFinishTools kj_parallelLineDotsWithPoint1:A Point2:B Point3:E];
        CGPoint N = [_KJIFinishTools kj_parallelLineDotsWithPoint1:C Point2:D Point3:G];
        CGPoint J = [_KJIFinishTools kj_parallelLineDotsWithPoint1:B Point2:C Point3:G];
        CGPoint K = [_KJIFinishTools kj_parallelLineDotsWithPoint1:A Point2:D Point3:E];
        F = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:E Point2:M Point3:J Point4:G];
        H = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:G Point2:N Point3:K Point4:E];
    }else if (CGPointEqualToPoint(CGPointZero,O1)) {
        CGPoint M = [_KJIFinishTools kj_parallelLineDotsWithPoint1:A Point2:B Point3:E];
        CGPoint N = [_KJIFinishTools kj_parallelLineDotsWithPoint1:C Point2:D Point3:G];
        F = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:E Point2:M Point3:O2 Point4:G];
        H = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:G Point2:N Point3:O2 Point4:E];
    }else if (CGPointEqualToPoint(CGPointZero,O2)) {
        CGPoint M = [_KJIFinishTools kj_parallelLineDotsWithPoint1:B Point2:C Point3:G];
        CGPoint N = [_KJIFinishTools kj_parallelLineDotsWithPoint1:A Point2:D Point3:E];
        F = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:E Point2:O1 Point3:M Point4:G];
        H = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:G Point2:O1 Point3:N Point4:E];
    }else{
        F = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:E Point2:O1 Point3:O2 Point4:G];
        H = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:G Point2:O1 Point3:O2 Point4:E];
    }
    return (KJKnownPoints){E,F,G,H};
}

@end

@implementation KJDecorateView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        /// 添加移动手势
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipe:)];
        [self addGestureRecognizer:recognizer];
        self.currentCenter = self.center;
    }
    return self;
}
#pragma mark - 点击域处理
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event{
    /// 如果不能接收触摸事件，直接返回nil
    if (self.userInteractionEnabled == NO || self.hidden == YES || self.alpha < 0.01) return nil;
    /// 四个角落区域
    if (CGRectContainsPoint([self kj_drawPrecinctRectWithPoint:self.points.PointA], point)) {
        self.touchBeginPoint = point;
        self.currentDecorateDotType = KJDecorateDotTypeLeftTop;
        return self;
    }else if (CGRectContainsPoint([self kj_drawPrecinctRectWithPoint:self.points.PointB], point)) {
        self.touchBeginPoint = point;
        self.currentDecorateDotType = KJDecorateDotTypeLeftBottom;
        return self;
    }else if (CGRectContainsPoint([self kj_drawPrecinctRectWithPoint:self.points.PointC], point)) {
        self.touchBeginPoint = point;
        self.currentDecorateDotType = KJDecorateDotTypeRightBottom;
        return self;
    }else if (CGRectContainsPoint([self kj_drawPrecinctRectWithPoint:self.points.PointD], point)) {
        self.touchBeginPoint = point;
        self.currentDecorateDotType = KJDecorateDotTypeRightTop;
        return self;
    }
    return nil;
}
/// 设置有效区域
- (CGRect)kj_drawPrecinctRectWithPoint:(CGPoint)point{
    CGPoint childPoint = [self.superview convertPoint:point toView:self];
    CGFloat w = 5;/// 上下5px
    CGRect rect = CGRectMake(childPoint.x-w, childPoint.y-w, w*2, w*2);
    return rect;
}
/// 滑动当中
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event{
    UITouch *touch = (UITouch *)touches.anyObject;
    if (touches.count > 1 || [touch tapCount] > 1 || event.allTouches.count > 1) {
        return;
    }
    [super touchesMoved:touches withEvent:event];
    CGPoint tempPoint = [touches.anyObject locationInView:self];
    if (fabs(tempPoint.x - self.touchBeginPoint.x) < minLen && fabs(tempPoint.y - self.touchBeginPoint.y) < minLen) {
        return;
    }
    !self.kChartletMoveBlcok?:self.kChartletMoveBlcok(tempPoint,self.currentDecorateDotType);
}

#pragma mark - 绘制
- (void)drawRect:(CGRect)rect{
    CGContextRef ctx = UIGraphicsGetCurrentContext(); //获取当前绘制环境
    CGContextSaveGState(ctx);
    CGContextSetShouldAntialias(ctx,YES); // 为图形上下文设置抗锯齿功能
    UIGraphicsPushContext(ctx);// 解决绘制图片上下颠倒
    CGRect tempRect = self.bounds;
//    tempRect.origin.y += 1;
//    tempRect.origin.x += 1;
//    tempRect.size.height += 1;
//    tempRect.size.width += 1;
    [self.perspectiveImage drawInRect:tempRect];
    UIGraphicsPopContext();
}
#pragma mark - 手势处理
- (void)handleSwipe:(UIPanGestureRecognizer*)pan{
    if (pan.state == UIGestureRecognizerStateBegan) {
        
    }else if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [pan translationInView:self];
        [self kj_commitTranslation:translation];
        self.center = CGPointMake(self.currentCenter.x + translation.x, self.currentCenter.y + translation.y);
//        self.points = [self kj_changePointsWithTranslation:translation];
//        NSLog(@"----%f,%f",self.frame.origin.x,self.frame.origin.y);
    }else if (pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateFailed) {
        self.currentCenter = self.center;
    }
}
- (KJKnownPoints)kj_changePointsWithTranslation:(CGPoint)translation{
    CGPoint A = self.points.PointA;
    CGPoint B = self.points.PointB;
    CGPoint C = self.points.PointC;
    CGPoint D = self.points.PointD;
    A.x += translation.x;
    A.y += translation.y;
    B.x += translation.x;
    B.y += translation.y;
    C.x += translation.x;
    C.y += translation.y;
    D.x += translation.x;
    D.y += translation.y;
    return (KJKnownPoints){A,B,C,D};
}
/// 判断手势方向 0：没有移动 1：向左滑动 2：向右滑动 3：向上滑动 4：向下滑动
- (NSInteger)kj_commitTranslation:(CGPoint)translation{
    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);
    // 设置滑动有效距离
    if (MAX(absX, absY) < minLen) return 0;
    if (absX > absY) {
        if (translation.x<0) {
            return 1;//向左滑动
        }else{
            return 2;//向右滑动
        }
    }else if (absY > absX) {
        if (translation.y<0) {
            return 3;//向上滑动
        }else{
            return 4;//向下滑动
        }
    }
    return 0;
}
@end
