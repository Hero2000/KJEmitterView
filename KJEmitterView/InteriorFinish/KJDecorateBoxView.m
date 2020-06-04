//
//  KJDecorateBoxView.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/28.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJDecorateBoxView.h"
static CGFloat minLen = 1.0; /// 最小的滑动距离
/// 装饰类
@interface KJDecorateView : UIView<UIGestureRecognizerDelegate>
@property(nonatomic,assign) KJKnownPoints points;
@property(nonatomic,strong) UIImage *materialImage; /// 原始素材图
@property(nonatomic,strong) UIImage *perspectiveImage; /// 透视好的素材图
@property(nonatomic,readwrite,copy) void (^kBlockageMoveBlcok)(CGPoint translation,KJDecorateView *decorateView,UIView *blockageView); /// 小方块移动处理
@property(nonatomic,readwrite,copy) void (^kDecorateMoveBlcok)(CGPoint translation,KJDecorateView *decorateView); /// KJDecorateView移动处理
@property(nonatomic,readwrite,copy) void (^kMoveEndBlcok)(KJDecorateView *decorateView); /// 移动结束
- (instancetype)initWithKnownPoints:(KJKnownPoints)points SuperView:(UIView*)superView;
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
    __weak typeof(self) weakself = self;
    /// 判断当前是否有虚线区域，优先满足是否拖动到正确虚线区域
    if (_topLayer) {
        if ([_KJIFinishTools kj_confirmCurrentPointWithPoint:point KnownPoints:self.drawPoints]) {
            if (block) {
                KJDecorateView *_decorateView = [[KJDecorateView alloc]initWithKnownPoints:self.drawPoints SuperView:self];
//                [self.temps addObject:decorateView]; /// 存入容器
                _decorateView.tag = self.subviews.count + 500; /// 编号
                _decorateView.materialImage = materialImage;
                _decorateView.perspectiveImage = block(self.drawPoints,materialImage);/// 获取到透视好的素材图
                _decorateView.kDecorateMoveBlcok = ^(CGPoint translation,KJDecorateView *decorateView) {
                    weakself.drawPoints = [weakself kj_changePointsWithKnownPoints:decorateView.points Translation:translation];
                    SEL selector = NSSelectorFromString(@"kj_changeBlockagePoints:");
                    IMP imp = [decorateView methodForSelector:selector];
                    void (*func)(id, SEL, KJKnownPoints) = (void *)imp;
                    func(decorateView, selector, weakself.drawPoints);
                };
                _decorateView.kBlockageMoveBlcok = ^(CGPoint translation,KJDecorateView *decorateView,UIView *blockageView) {
                    CGPoint tempPoint = CGPointZero;
                    KJSlideDirectionType directionType = KJSlideDirectionTypeLeftBottom;
                    if (blockageView.tag == 100) {/// 左上角
                        weakself.touchBeginPoint = decorateView.points.PointC;
                        tempPoint = decorateView.points.PointA;
                        directionType = KJSlideDirectionTypeRightTop;
                    }else if (blockageView.tag == 101) {/// 左下角
                        weakself.touchBeginPoint = decorateView.points.PointD;
                        tempPoint = decorateView.points.PointB;
                        directionType = KJSlideDirectionTypeRightBottom;
                    }else if (blockageView.tag == 102) {/// 右下角
                        weakself.touchBeginPoint = decorateView.points.PointA;
                        tempPoint = decorateView.points.PointC;
                        directionType = KJSlideDirectionTypeLeftBottom;
                    }else if (blockageView.tag == 103) {/// 右上角
                        weakself.touchBeginPoint = decorateView.points.PointB;
                        tempPoint = decorateView.points.PointD;
                        directionType = KJSlideDirectionTypeLeftTop;
                    }
                    tempPoint.x += translation.x;tempPoint.y += translation.y;
                    weakself.drawPoints = [weakself kj_pointsWithTempPoint:tempPoint DirectionType:directionType];
                    if (weakself.kMovePerspectiveBlock) {
                        decorateView.perspectiveImage = weakself.kMovePerspectiveBlock(weakself.drawPoints,decorateView.materialImage);
                    }
                    SEL selector = NSSelectorFromString(@"kj_changeBlockagePoints:");
                    IMP imp = [decorateView methodForSelector:selector];
                    void (*func)(id, SEL, KJKnownPoints) = (void *)imp;
                    func(decorateView, selector, weakself.drawPoints);
                };
                _decorateView.kMoveEndBlcok = ^(KJDecorateView *decorateView){
                    decorateView.points = weakself.drawPoints;
                };
                [self kj_setNull]; /// 置空处理
            }
            return true;
        }else{
            return false;
        }
    }
    /// 判断是否在已存在的装饰区域
    __block bool boo = false;
    [self.subviews enumerateObjectsUsingBlock:^(KJDecorateView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint childPoint = [weakself convertPoint:point toView:obj];
        BOOL result = [obj.layer containsPoint:childPoint];
        if (result) {
            obj.materialImage = materialImage;
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
/// 平移之后透视点相对处理
- (KJKnownPoints)kj_changePointsWithKnownPoints:(KJKnownPoints)points Translation:(CGPoint)translation{
    CGPoint A = points.PointA;
    CGPoint B = points.PointB;
    CGPoint C = points.PointC;
    CGPoint D = points.PointD;
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
    /// 确定滑动方向
    KJSlideDirectionType directionType = [_KJIFinishTools kj_slideDirectionWithPoint:self.touchBeginPoint Point2:tempPoint];
    self.drawPoints = [self kj_pointsWithTempPoint:tempPoint DirectionType:directionType];
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
- (KJKnownPoints)kj_pointsWithTempPoint:(CGPoint)tempPoint DirectionType:(KJSlideDirectionType)directionType{
    CGPoint A = _knownPoints.PointA;
    CGPoint B = _knownPoints.PointB;
    CGPoint C = _knownPoints.PointC;
    CGPoint D = _knownPoints.PointD;
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
    KJKnownPoints points = (KJKnownPoints){E,F,G,H}; /// 左下滑动
    if (directionType == KJSlideDirectionTypeRightBottom) { /// 右下滑动
        points = (KJKnownPoints){H,G,F,E};
    }else if (directionType == KJSlideDirectionTypeLeftTop) { /// 左上滑动
        points = (KJKnownPoints){F,E,H,G};
    }else if (directionType == KJSlideDirectionTypeRightTop) { /// 右上滑动
        points = (KJKnownPoints){G,H,E,F};
    }
    return points;
}

@end

@implementation KJDecorateView
- (instancetype)initWithKnownPoints:(KJKnownPoints)points SuperView:(UIView*)superView{
    if (self==[super init]) {
        [superView addSubview:self];
        self.points = points;
        self.backgroundColor = [UIColor.yellowColor colorWithAlphaComponent:0.3];
        self.userInteractionEnabled = NO;
        /// 添加移动手势
        [self addGestureRecognizer:({
            UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(kj_panMove:)];
            gesture.delegate = self;
            gesture;
        })];
        /// 添加4个小正方形
        for (NSInteger i=0; i<4; i++) {
            UIView *view = [UIView new];
            view.tag = 100 + i;
            view.userInteractionEnabled = YES;
            view.backgroundColor = UIColor.blueColor;
            [self addSubview:view];
            /// 添加移动手势
            [view addGestureRecognizer:({
                UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(kj_blockageMove:)];
                gesture;
            })];
        }
        [self kj_changeBlockagePoints:points];
    }
    return self;
}
/// 改变小方块位置和KJDecorateView尺寸
- (void)kj_changeBlockagePoints:(KJKnownPoints)points{
    self.frame = [_KJIFinishTools kj_rectWithPoints:points];
    __weak typeof(self) weakself = self;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == 100) {/// 左上角
            obj.frame = [weakself kj_drawPrecinctRectWithPoint:points.PointA SuperView:weakself.superview];
        }else if (obj.tag == 101) {/// 左下角
            obj.frame = [weakself kj_drawPrecinctRectWithPoint:points.PointB SuperView:weakself.superview];
        }else if (obj.tag == 102) {/// 右下角
            obj.frame = [weakself kj_drawPrecinctRectWithPoint:points.PointC SuperView:weakself.superview];
        }else if (obj.tag == 103) {/// 右上角
            obj.frame = [weakself kj_drawPrecinctRectWithPoint:points.PointD SuperView:weakself.superview];
        }
    }];
}
/// 设置小方块对应的坐标
- (CGRect)kj_drawPrecinctRectWithPoint:(CGPoint)point SuperView:(UIView*)superView{
    /// 转化对应在父视图上的坐标
    CGPoint superPoint = [superView convertPoint:point toView:self];
    /// 20像素选区
    return CGRectMake(superPoint.x - 10, superPoint.y - 10, 20, 20);
}
#pragma mark - 点击域处理
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event{
    /// 如果不能接收触摸事件，直接返回nil
    if (self.userInteractionEnabled == NO || self.hidden == YES || self.alpha < 0.01) return nil;
    /// 判断是否触发的是自己内部的view
    NSInteger count = self.subviews.count;
    for (NSInteger i=count-1; i>=0; i--) {
        UIView *childView = self.subviews[i];
        CGPoint childPoint = [self convertPoint:point toView:childView];
        UIView *view = [childView hitTest:childPoint withEvent:event];
        if (view) return view;
    }
    /// 扩大触发范围
    CGRect rect = self.bounds;//CGRectMake(self.bounds.origin.x-10, self.bounds.origin.y-10, self.bounds.size.width+20, self.bounds.size.height+20);
    return CGRectContainsPoint(rect, point) ? self : nil;
}
#pragma mark - 绘制
- (void)drawRect:(CGRect)rect{
    CGContextRef ctx = UIGraphicsGetCurrentContext(); //获取当前绘制环境
    CGContextSaveGState(ctx);
    CGContextSetShouldAntialias(ctx,YES); 
    UIGraphicsPushContext(ctx);// 解决绘制图片上下颠倒
    [self.perspectiveImage drawInRect:self.bounds];
    UIGraphicsPopContext();
}
#pragma mark - 手势处理
- (void)kj_panMove:(UIPanGestureRecognizer*)panGesture{
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        
    }else if (panGesture.state == UIGestureRecognizerStateChanged) {
        !self.kDecorateMoveBlcok?:self.kDecorateMoveBlcok([panGesture translationInView:self],self);
    }else if (panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateFailed) {
        !self.kMoveEndBlcok?:self.kMoveEndBlcok(self);
    }
}
/// 小方块移动处理
- (void)kj_blockageMove:(UIPanGestureRecognizer*)panGesture{
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        
    }else if (panGesture.state == UIGestureRecognizerStateChanged) {
        !self.kBlockageMoveBlcok?:self.kBlockageMoveBlcok([panGesture translationInView:panGesture.view],self,panGesture.view);
    }else if (panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateFailed) {
        !self.kMoveEndBlcok?:self.kMoveEndBlcok(self);
    }
}
#pragma mark - UIGestureRecognizerDelegate
/// 设置手势范围
- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//    if ([gestureRecognizer locationInView:self].y>CGRectGetMaxY(self.topMenuView.bounds)&&[gestureRecognizer locationInView:self].y<self.functionalView.y) {
//        return YES;
//    }
    return YES;
}
@end
