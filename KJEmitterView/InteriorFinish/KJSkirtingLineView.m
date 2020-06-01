//
//  KJSkirtingLineView.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/27.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJSkirtingLineView.h"
static CGFloat minLen = 1.0; /// 最小的滑动距离
@interface KJSkirtingLineModel : NSObject
@property(nonatomic,assign) KJSkirtingLineType type;
@property(nonatomic,assign) KJKnownPoints knownPoints; /// 已知选区ABCD四点
@property(nonatomic,strong) UIImage *materialImage; /// 素材图
@property(nonatomic,strong) UIImage *jointImage; /// 拼接好的素材图
@property(nonatomic,strong) UIImage *perspectiveImage; /// 透视好的素材图
@property(nonatomic,strong) CAShapeLayer *dashPatternLayer; /// 虚线选区
@property(nonatomic,assign) CGFloat width; /// 边线宽度
@property(nonatomic,assign) CGFloat height;/// 边线高度
@property(nonatomic,assign) CGRect imageRect;
@property(nonatomic,assign) KJKnownPoints points; /// 虚线框四点
@property(nonatomic,strong) UIBezierPath *bezierPath;/// 虚线路径
@property(nonatomic,assign) bool chartletComplete; /// 是否贴图
@property(nonatomic,readwrite,copy) void (^kChartletMoveBlcok)(KJSkirtingLineModel *model); /// 贴图之后移动回调处理
@end
@interface KJSkirtingLineView ()
@property(nonatomic,strong) KJSkirtingLineModel *topModel;
@property(nonatomic,strong) KJSkirtingLineModel *bottomModel;
@property(nonatomic,strong) KJSkirtingLineModel *leftModel;
@property(nonatomic,strong) KJSkirtingLineModel *rightModel;
@property(nonatomic,assign) KJKnownPoints knownPoints;/// 外界区域四点
@property(nonatomic,assign) CGPoint touchBeginPoint; /// 记录touch开始的点
@property(nonatomic,assign) CGPoint lastMovePoint; /// 记录上一次移动的点，用于确定上拉还是下拉
@property(nonatomic,assign) KJSkirtingLineType currentType;/// 当前拖动的边线
@property(nonatomic,assign) bool canMove;/// 是否可以移动
@end

@implementation KJSkirtingLineView
/// 子类需要实现父类方法
- (bool)kj_delGestureWithPoint:(CGPoint)point{
    /// 不在透视选区内不做手势处理
    if (![_KJIFinishTools kj_confirmCurrentPointWithPoint:point KnownPoints:self.knownPoints]) {
        return false;
    }
    /// 四条边线区域之外，触摸事件丢失
    bool top = [_KJIFinishTools kj_confirmCurrentPointWithPoint:point KnownPoints:self.topModel.points];
    bool bottom = [_KJIFinishTools kj_confirmCurrentPointWithPoint:point KnownPoints:self.bottomModel.points];
    bool left = [_KJIFinishTools kj_confirmCurrentPointWithPoint:point KnownPoints:self.leftModel.points];
    bool right = [_KJIFinishTools kj_confirmCurrentPointWithPoint:point KnownPoints:self.rightModel.points];
    if (!top && !bottom && !left && !right) return false;
    return true;
}
/// 重置
- (void)kj_clearLayers{
    [self.bottomModel.dashPatternLayer removeFromSuperlayer];
    self.bottomModel = nil;
    [self setNeedsDisplay];
}
/// 创建对应的模型
- (KJSkirtingLineModel*)kj_skirtingLineModelWithType:(KJSkirtingLineType)type KnownPoints:(KJKnownPoints)points Rect:(CGRect)rect{
    KJSkirtingLineModel *model = [[KJSkirtingLineModel alloc]init];
    model.type = type;
    model.knownPoints = points;
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    if (type == KJSkirtingLineTypeLeft || type == KJSkirtingLineTypeRight) {
        CGFloat AB = [_KJIFinishTools kj_distanceBetweenPointsWithPoint1:points.PointA Point2:points.PointB];
        CGFloat CD = [_KJIFinishTools kj_distanceBetweenPointsWithPoint1:points.PointC Point2:points.PointD];
        if (AB>CD) {
            model.width = type == KJSkirtingLineTypeLeft ? w/10. : (w/10. * CD/AB);
        }else{
            model.width = type == KJSkirtingLineTypeRight ? w/10. : (w/10. * CD/AB);
        }
        model.height = h;
    }else {
        CGFloat AD = [_KJIFinishTools kj_distanceBetweenPointsWithPoint1:points.PointA Point2:points.PointD];
        CGFloat CB = [_KJIFinishTools kj_distanceBetweenPointsWithPoint1:points.PointC Point2:points.PointB];
        if (AD>CB) {
            model.height = type == KJSkirtingLineTypeTop ? h/10. : (h/10. * CB/AD);
        }else{
            model.height = type == KJSkirtingLineTypeBottom ? h/10. : (h/10. * AD/CB);
        }
        model.width = w;
    }
    __weak typeof(self) weakself = self;
    model.kChartletMoveBlcok = ^(KJSkirtingLineModel *model) {
        model.dashPatternLayer.strokeColor = weakself.dashPatternColor.CGColor;
        if (weakself.kMovePerspectiveBlock) {
            /// 重新拼接素材
            SEL selector = NSSelectorFromString(@"kj_jointImage");
            IMP imp = [model methodForSelector:selector];
            void (*func)(id, SEL) = (void *)imp;
            func(model, selector);
            /// 回调贴图
            model.perspectiveImage = weakself.kMovePerspectiveBlock(model.points, model.jointImage);
            [weakself setNeedsDisplay];
        }
    };
    [self.layer addSublayer:model.dashPatternLayer];
    return model;
}
/// 初始化
- (instancetype)kj_initWithFrame:(CGRect)frame KnownPoints:(KJKnownPoints)points LegWireType:(KJSkirtingLineType)type{
    if (self == [super init]) {
        self.backgroundColor = UIColor.clearColor;
        self.knownPoints = points;
        self.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.layer.contentsScale = [[UIScreen mainScreen] scale];/// 绘图模糊有锯齿解决方案
        CGRect rect = [_KJIFinishTools kj_rectWithPoints:points];/// 最大矩形框
        if (type == 0 || (type & KJSkirtingLineTypeTop)) {
            self.topModel = [self kj_skirtingLineModelWithType:KJSkirtingLineTypeTop KnownPoints:points Rect:rect];
            self.topModel.dashPatternLayer.zPosition = 104;
        }
        if (type == 1 || (type & KJSkirtingLineTypeBottom)) {
            self.bottomModel = [self kj_skirtingLineModelWithType:KJSkirtingLineTypeBottom KnownPoints:points Rect:rect];
            self.bottomModel.dashPatternLayer.zPosition = 103;
        }
        if (type == 2 || (type & KJSkirtingLineTypeLeft)) {
            self.leftModel = [self kj_skirtingLineModelWithType:KJSkirtingLineTypeLeft KnownPoints:points Rect:rect];
            self.leftModel.dashPatternLayer.zPosition = 101;
        }
        if (type == 3 || (type & KJSkirtingLineTypeRight)) {
            self.rightModel = [self kj_skirtingLineModelWithType:KJSkirtingLineTypeRight KnownPoints:points Rect:rect];
            self.rightModel.dashPatternLayer.zPosition = 100;
        }
    }
    return self;
}
/// 根据当前坐标修改指定区域素材图 - 透视图片
- (bool)kj_changeMaterialImage:(UIImage*)materialImage Point:(CGPoint)point PerspectiveBlock:(UIImage *(^)(KJKnownPoints points,UIImage *jointImage))block{
    NSInteger i = [self kj_getSkirtingLineTypeWithcurrentPoint:point];
    if (i == -1) {
        return false;
    }else if (i == 0) {
        [self kj_materialImage:materialImage SkirtingLineModel:self.topModel PerspectiveBlock:block];
    }else if (i == 1) {
        [self kj_materialImage:materialImage SkirtingLineModel:self.bottomModel PerspectiveBlock:block];
    }else if (i == 2) {
        [self kj_materialImage:materialImage SkirtingLineModel:self.leftModel PerspectiveBlock:block];
    }else if (i == 3) {
        [self kj_materialImage:materialImage SkirtingLineModel:self.rightModel PerspectiveBlock:block];
    }
    return true;
}
/// 根据当前坐标返回所在区域 -1：无该区域 0：上 1：下 2：左 3：右
- (NSInteger)kj_getSkirtingLineTypeWithcurrentPoint:(CGPoint)point{
    if ([_KJIFinishTools kj_confirmCurrentPointWithPoint:point KnownPoints:self.bottomModel.points]) {
        return 1;
    }
    if ([_KJIFinishTools kj_confirmCurrentPointWithPoint:point KnownPoints:self.topModel.points]) {
        return 0;
    }
    if ([_KJIFinishTools kj_confirmCurrentPointWithPoint:point KnownPoints:self.leftModel.points]) {
        return 2;
    }
    if ([_KJIFinishTools kj_confirmCurrentPointWithPoint:point KnownPoints:self.rightModel.points]) {
        return 3;
    }
    return -1;
}
- (void)kj_materialImage:(UIImage*)materialImage SkirtingLineModel:(KJSkirtingLineModel*)model PerspectiveBlock:(UIImage *(^)(KJKnownPoints points,UIImage *jointImage))block{
    model.materialImage = materialImage;
    if (block) {
        /// 获取到透视好的素材图
        model.perspectiveImage = block(model.points,model.jointImage);
        model.chartletComplete = true;
        model.dashPatternLayer.strokeColor = UIColor.clearColor.CGColor;
        [self setNeedsDisplay];
    }
}
#pragma mark - geter/seter
@synthesize dashPatternColor = _dashPatternColor;
@synthesize dashPatternWidth = _dashPatternWidth;
- (void)setDashPatternColor:(UIColor*)dashPatternColor{
    _dashPatternColor = dashPatternColor;
    self.topModel.dashPatternLayer.strokeColor = dashPatternColor.CGColor;
    self.bottomModel.dashPatternLayer.strokeColor = dashPatternColor.CGColor;
    self.leftModel.dashPatternLayer.strokeColor = dashPatternColor.CGColor;
    self.rightModel.dashPatternLayer.strokeColor = dashPatternColor.CGColor;
//    self.topModel.dashPatternLayer.strokeColor = UIColor.redColor.CGColor;//dashPatternColor.CGColor;
//    self.bottomModel.dashPatternLayer.strokeColor = UIColor.blueColor.CGColor;//dashPatternColor.CGColor;
//    self.leftModel.dashPatternLayer.strokeColor = UIColor.yellowColor.CGColor;//dashPatternColor.CGColor;
//    self.rightModel.dashPatternLayer.strokeColor = UIColor.greenColor.CGColor;//dashPatternColor.CGColor;
}
- (void)setDashPatternWidth:(CGFloat)dashPatternWidth{
    _dashPatternWidth = dashPatternWidth;
    self.topModel.dashPatternLayer.lineWidth = dashPatternWidth;
    self.bottomModel.dashPatternLayer.lineWidth = dashPatternWidth;
    self.leftModel.dashPatternLayer.lineWidth = dashPatternWidth;
    self.rightModel.dashPatternLayer.lineWidth = dashPatternWidth;
}
#pragma mark - 绘制
- (void)drawRect:(CGRect)rect{
    CGContextRef ctx = UIGraphicsGetCurrentContext(); //获取当前绘制环境
    CGContextSaveGState(ctx);
    CGContextSetShouldAntialias(ctx,YES); // 为图形上下文设置抗锯齿功能
    if (self.rightModel.chartletComplete) [self kj_chartletWithCtx:ctx SkirtingLineModel:self.rightModel];
    if (self.leftModel.chartletComplete)  [self kj_chartletWithCtx:ctx SkirtingLineModel:self.leftModel];
    if (self.topModel.chartletComplete)   [self kj_chartletWithCtx:ctx SkirtingLineModel:self.topModel];
    if (self.bottomModel.chartletComplete)[self kj_chartletWithCtx:ctx SkirtingLineModel:self.bottomModel];
}
- (void)kj_chartletWithCtx:(CGContextRef)ctx SkirtingLineModel:(KJSkirtingLineModel*)model{
//    CGContextAddPath(ctx, model.bezierPath.CGPath);
//    CGContextClip(ctx); // 裁剪路径以外部分
    UIGraphicsPushContext(ctx);// 解决绘制图片上下颠倒
    CGRect tempRect = model.imageRect;
    if (model.type == KJSkirtingLineTypeBottom || model.type == KJSkirtingLineTypeTop) {
        tempRect.size.height += 1; /// 解决所绘之图有点往上移位的问题
    }else{
        tempRect.size.width += 1.;
    }
    [model.perspectiveImage drawInRect:tempRect];
    UIGraphicsPopContext();
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
    
    /// 确认当前所在选区
    bool top = [_KJIFinishTools kj_confirmCurrentPointWithPoint:self.touchBeginPoint KnownPoints:self.topModel.points];
    bool bottom = [_KJIFinishTools kj_confirmCurrentPointWithPoint:self.touchBeginPoint KnownPoints:self.bottomModel.points];
    bool left = [_KJIFinishTools kj_confirmCurrentPointWithPoint:self.touchBeginPoint KnownPoints:self.leftModel.points];
    bool right = [_KJIFinishTools kj_confirmCurrentPointWithPoint:self.touchBeginPoint KnownPoints:self.rightModel.points];
    if (top || bottom || left || right) {
        self.lastMovePoint = self.touchBeginPoint;
        self.canMove = true;
    }
    if (right) self.currentType = KJSkirtingLineTypeRight;
    if (left) self.currentType = KJSkirtingLineTypeLeft;
    if (top) self.currentType = KJSkirtingLineTypeTop;
    if (bottom) self.currentType = KJSkirtingLineTypeBottom;
}
/// 滑动当中
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.canMove) return; /// 不能移动
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
    if (self.currentType == KJSkirtingLineTypeTop) {
        if (self.topModel.height>0) {
            CGFloat x = tempPoint.y - self.lastMovePoint.y;
            self.topModel.height += x;
            if (self.topModel.height<=0) self.topModel.height = 0;
            self.lastMovePoint = tempPoint;
        }
    }else if (self.currentType == KJSkirtingLineTypeBottom) {
        if (self.bottomModel.height>0) {
            CGFloat x = tempPoint.y - self.lastMovePoint.y;
            self.bottomModel.height -= x;
            if (self.bottomModel.height<=0) self.bottomModel.height = 0;
            self.lastMovePoint = tempPoint;
        }
    }else if (self.currentType == KJSkirtingLineTypeLeft) {
        if (self.leftModel.width>0) {
            CGFloat x = tempPoint.x - self.lastMovePoint.x;
            self.leftModel.width += x;
            if (self.leftModel.width<=0) self.leftModel.width = 0;
            self.lastMovePoint = tempPoint;
        }
    }else if (self.currentType == KJSkirtingLineTypeRight) {
        if (self.rightModel.width>0) {
            CGFloat x = tempPoint.x - self.lastMovePoint.x;
            self.rightModel.width -= x;
            if (self.rightModel.width<=0) self.rightModel.width = 0;
            self.lastMovePoint = tempPoint;
        }
    }
}
/// 触摸结束
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesEnded");
    [super touchesEnded:touches withEvent:event];
    self.canMove = false;
    if (self.topModel.chartletComplete) self.topModel.dashPatternLayer.strokeColor = UIColor.clearColor.CGColor;
    if (self.bottomModel.chartletComplete) self.bottomModel.dashPatternLayer.strokeColor = UIColor.clearColor.CGColor;
    if (self.leftModel.chartletComplete) self.leftModel.dashPatternLayer.strokeColor = UIColor.clearColor.CGColor;
    if (self.rightModel.chartletComplete) self.rightModel.dashPatternLayer.strokeColor = UIColor.clearColor.CGColor;
}

@end

@implementation KJSkirtingLineModel
#pragma mark - geter/seter
- (CAShapeLayer*)dashPatternLayer{
    if (!_dashPatternLayer) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.fillColor = [UIColor.redColor colorWithAlphaComponent:0.0].CGColor;
        shapeLayer.strokeColor = UIColor.blackColor.CGColor;
        shapeLayer.lineWidth = 1.;
        shapeLayer.lineCap = kCALineCapButt;
        shapeLayer.lineDashPattern = @[@(5),@(5)];// 实线长度和虚线长度间隔
        shapeLayer.fillRule = kCAFillRuleEvenOdd;// 两个路径相交会消掉(偶消积不消)
        shapeLayer.lineJoin = kCALineJoinRound;// 连接节点样式
        shapeLayer.lineCap = kCALineCapRound;// 线头样式
        _dashPatternLayer = shapeLayer;
    }
    return _dashPatternLayer;
}
- (void)setMaterialImage:(UIImage *)materialImage{
    _materialImage = materialImage;
    [self kj_jointImage];/// 拼接素材图
}
- (void)setHeight:(CGFloat)height{
    if ((_height == height && height != 0) || height == 0) return;
    _height = height;
    [self kj_skirtingLinePointsWithKnownPoints:self.knownPoints];/// 找到路径四点
}
- (void)setWidth:(CGFloat)width{
    if (width == 0) return;
    if (_width == width) return;
    _width = width;
    [self kj_skirtingLinePointsWithKnownPoints:self.knownPoints];/// 找到路径四点
}
#pragma mark - 内部方法
/// 拼接素材图
- (void)kj_jointImage{
    /// 设置画布尺寸
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(_width, _height) ,NO, 0.0);
    if (self.type == KJSkirtingLineTypeTop || self.type == KJSkirtingLineTypeBottom) {
        CGFloat w  = _materialImage.size.width * _height / _materialImage.size.height;
        CGFloat xw = _width / w;
        CGFloat rw = roundf(xw);
        int row = xw<=rw ? rw : rw+1;
        CGFloat x = 0;
        for (int i=0; i<row; i++) {
            x = w * i;
            [_materialImage drawInRect:CGRectMake(x,0,w,_height)];
        }
    }else {
        CGFloat h  = _materialImage.size.height * _width / _materialImage.size.width;
        CGFloat xh = _height / h;
        CGFloat rh = roundf(xh);
        int col = xh<=rh ? rh : rh+1;
        CGFloat y = 0;
        for (int i=0; i<col; i++) {
            y = h * i;
            [_materialImage drawInRect:CGRectMake(0,y,_width,h)];
        }
    }
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.jointImage = resultingImage;
}
/// 获取对应边线数据
- (void)kj_skirtingLinePointsWithKnownPoints:(KJKnownPoints)points{
    if (self.type == KJSkirtingLineTypeTop) {
        self.points = [self kj_topPointsWithKnownPoints:points];
    }else if (self.type == KJSkirtingLineTypeBottom) {
        self.points = [self kj_bottomPointsWithKnownPoints:points];
    }else if (self.type == KJSkirtingLineTypeLeft) {
        self.points = [self kj_leftPointsWithKnownPoints:points];
    }else if (self.type == KJSkirtingLineTypeRight) {
        self.points = [self kj_rightPointsWithKnownPoints:points];
    }
    /// 获取贴图尺寸
    self.imageRect = [_KJIFinishTools kj_rectWithPoints:self.points];
    self.bezierPath = ({
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:self.points.PointA];
        [path addLineToPoint:self.points.PointB];
        [path addLineToPoint:self.points.PointC];
        [path addLineToPoint:self.points.PointD];
        [path closePath];
        path;
    });
    /// 已经贴好图需单独处理
    if (self.chartletComplete) !self.kChartletMoveBlcok?:self.kChartletMoveBlcok(self);
    self.dashPatternLayer.path = self.bezierPath.CGPath;
}
- (KJKnownPoints)kj_topPointsWithKnownPoints:(KJKnownPoints)knownPoints{
    CGPoint A = knownPoints.PointA;
    CGPoint B = knownPoints.PointB;
    CGPoint C = knownPoints.PointC;
    CGPoint D = knownPoints.PointD;
    KJKnownPoints points;
    CGPoint O = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:A Point2:D Point3:B Point4:C];
        CGFloat AD = [_KJIFinishTools kj_distanceBetweenPointsWithPoint1:A Point2:D];
    CGFloat CB = [_KJIFinishTools kj_distanceBetweenPointsWithPoint1:C Point2:B];
    CGPoint M = CGPointZero;
    if (AD>CB) {
        M = [_KJIFinishTools kj_perpendicularLineDotsWithPoint1:D Point2:A VerticalLenght:self.height Positive:YES];
    }else{
        M = [_KJIFinishTools kj_perpendicularLineDotsWithPoint1:A Point2:D VerticalLenght:self.height Positive:YES];
    }
    if (CGPointEqualToPoint(CGPointZero, O)) { /// 重合或者平行
        O = [_KJIFinishTools kj_parallelLineDotsWithPoint1:A Point2:D Point3:M];
    }
    points.PointA = A;
    points.PointB = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:O Point2:M Point3:A Point4:B];
    points.PointC = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:O Point2:M Point3:C Point4:D];
    points.PointD = D;
    return points;
}
- (KJKnownPoints)kj_bottomPointsWithKnownPoints:(KJKnownPoints)knownPoints{
    CGPoint A = knownPoints.PointA;
    CGPoint B = knownPoints.PointB;
    CGPoint C = knownPoints.PointC;
    CGPoint D = knownPoints.PointD;
    KJKnownPoints points;
    CGPoint O = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:A Point2:D Point3:B Point4:C];
    CGFloat AD = [_KJIFinishTools kj_distanceBetweenPointsWithPoint1:A Point2:D];
    CGFloat CB = [_KJIFinishTools kj_distanceBetweenPointsWithPoint1:C Point2:B];
    CGPoint M = CGPointZero;
    if (AD>CB) {
        M = [_KJIFinishTools kj_perpendicularLineDotsWithPoint1:C Point2:B VerticalLenght:self.height Positive:NO];
    }else{
        M = [_KJIFinishTools kj_perpendicularLineDotsWithPoint1:B Point2:C VerticalLenght:self.height Positive:NO];
    }
    if (CGPointEqualToPoint(CGPointZero, O)) { /// 重合或者平行
        O = [_KJIFinishTools kj_parallelLineDotsWithPoint1:B Point2:C Point3:M];
    }
    points.PointA = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:O Point2:M Point3:A Point4:B];
    points.PointB = B;
    points.PointC = C;
    points.PointD = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:O Point2:M Point3:C Point4:D];
    return points;
}
- (KJKnownPoints)kj_leftPointsWithKnownPoints:(KJKnownPoints)knownPoints{
    CGPoint A = knownPoints.PointA;
    CGPoint B = knownPoints.PointB;
    CGPoint C = knownPoints.PointC;
    CGPoint D = knownPoints.PointD;
    KJKnownPoints points;
    CGPoint O = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:A Point2:B Point3:C Point4:D];
    CGFloat AB = [_KJIFinishTools kj_distanceBetweenPointsWithPoint1:A Point2:B];
    CGFloat CD = [_KJIFinishTools kj_distanceBetweenPointsWithPoint1:C Point2:D];
    CGPoint M = CGPointZero;
    if (AB>CD) {
        M = [_KJIFinishTools kj_perpendicularLineDotsWithPoint1:B Point2:A VerticalLenght:self.width Positive:YES];
    }else{
        M = [_KJIFinishTools kj_perpendicularLineDotsWithPoint1:A Point2:B VerticalLenght:self.width Positive:YES];
    }

    if (CGPointEqualToPoint(CGPointZero, O)) { /// 重合或者平行
        O = [_KJIFinishTools kj_parallelLineDotsWithPoint1:A Point2:B Point3:M];
    }
    points.PointA = A;
    points.PointB = B;
    points.PointC = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:O Point2:M Point3:B Point4:C];
    points.PointD = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:O Point2:M Point3:A Point4:D];
    return points;
}
- (KJKnownPoints)kj_rightPointsWithKnownPoints:(KJKnownPoints)knownPoints{
    CGPoint A = knownPoints.PointA;
    CGPoint B = knownPoints.PointB;
    CGPoint C = knownPoints.PointC;
    CGPoint D = knownPoints.PointD;
    KJKnownPoints points;
    CGPoint O = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:A Point2:B Point3:C Point4:D];
    CGFloat AB = [_KJIFinishTools kj_distanceBetweenPointsWithPoint1:A Point2:B];
    CGFloat CD = [_KJIFinishTools kj_distanceBetweenPointsWithPoint1:C Point2:D];
    CGPoint M = CGPointZero;
    if (AB>CD) {
        M = [_KJIFinishTools kj_perpendicularLineDotsWithPoint1:C Point2:D VerticalLenght:self.width Positive:NO];
    }else{
        M = [_KJIFinishTools kj_perpendicularLineDotsWithPoint1:D Point2:C VerticalLenght:self.width Positive:NO];
    }
    if (CGPointEqualToPoint(CGPointZero, O)) { /// 重合或者平行
        O = [_KJIFinishTools kj_parallelLineDotsWithPoint1:D Point2:C Point3:M];
    }
    points.PointA = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:O Point2:M Point3:A Point4:D];
    points.PointB = [_KJIFinishTools kj_linellaeCrosspointWithPoint1:O Point2:M Point3:B Point4:C];
    points.PointC = C;
    points.PointD = D;
    return points;
}
@end
