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
@end

@implementation KJLegWireLayer
/// 重置
- (void)kj_clearLayers{
    [_topLayer removeFromSuperlayer];
    _topLayer = nil;
}
/// 初始化
- (instancetype)kj_initWithFrame:(CGRect)frame KnowPoints:(KJLegWireKnownPoints)points Size:(CGSize)size LegWireHeight:(CGFloat)height{
    if (self == [super init]) {
        self.frame = frame;
        self.legWireHeight = height ? height : size.height / 10.0;
        self.legWireWidth = size.width;
        self.dashPatternColor = UIColor.blackColor;
        self.dashPatternWidth = 1.;
        [self kj_getFourPoints:points]; /// 找到路径四点
        self.topLayer.path = ({
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:self.PointE];
            [path addLineToPoint:self.PointH];
            [path addLineToPoint:self.PointG];
            [path addLineToPoint:self.PointF];
            [path closePath];
            path.CGPath;
        });
    }
    return self;
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
- (void)setKChartletBlcok:(UIImage * _Nonnull (^)(KJLegWireKnownPoints, UIImage * _Nonnull))kChartletBlcok{
    KJLegWireKnownPoints points = {self.PointE,self.PointF,self.PointG,self.PointH};
    UIImage *image = kChartletBlcok(points,self.jointImage);
    if (_topLayer) {
        _topLayer.lineWidth = 0.0;
        UIImage *img = [self kj_rotationImage:image];
        UIColor *color = [UIColor colorWithPatternImage:image]; /// 图片转颜色
        _topLayer.fillColor = color.CGColor;
    }
}
#pragma mark - 内部方法
/** 图片上下翻转 */
- (UIImage*)kj_rotationImage:(UIImage*)image{
    CGRect rect = CGRectZero;
    rect.size.width  = CGImageGetWidth(image.CGImage);
    rect.size.height = CGImageGetHeight(image.CGImage);
    CGRect bounds = rect;
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformMakeTranslation(rect.size.width,rect.size.height);
    transform = CGAffineTransformRotate(transform, M_PI);
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -rect.size.height);
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, image.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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
- (void)kj_getFourPoints:(KJLegWireKnownPoints)points{
    CGPoint A = points.PointA;
    CGPoint B = points.PointB;
    CGPoint C = points.PointC;
    CGPoint D = points.PointD;
    CGPoint M = kj_perpendicularLineDots(C,B,self.legWireHeight,NO);
    CGPoint O = kj_linellaeCrosspoint(A,D,B,C);
    if (CGPointEqualToPoint(CGPointZero, O)) { /// 重合或者平行
        CGPoint X = kj_parallelLineDots(B,C,M);
        self.PointE = kj_linellaeCrosspoint(X,M,A,B);
        self.PointF = B;
        self.PointG = C;
        self.PointH = kj_linellaeCrosspoint(X,M,C,D);
    }else{
        self.PointE = kj_linellaeCrosspoint(O,M,A,B);
        self.PointF = B;
        self.PointG = C;
        self.PointH = kj_linellaeCrosspoint(O,M,C,D);
    }
}
#pragma mark - 几何方程式
/// 已知A、B两点和C点到B点的长度，求垂直AB的C点
static inline CGPoint kj_perpendicularLineDots(CGPoint A,CGPoint B, CGFloat len,BOOL positive){
    CGFloat x1 = A.x,y1 = A.y;
    CGFloat x2 = B.x,y2 = B.y;
    CGFloat k1 = 0,k = 0;
    if (x1 == x2) {
        k1 = -1;/// 垂直线
        k = 1;
    }else if (y1 == y2) {
        k1 = 1;/// 水平线
        k = -1;
    }else{
        k1 = (y1-y2)/(x1-x2);
        k = -1/k1;
    }
    CGFloat b = y2 - k*x2;
    
    /// 根据 len² = (x-x2)² + (y-y2)²  和  y = kx + b 推倒出x、y
    CGFloat t = k*k + 1;
    CGFloat g = k*(b-y2) - x2;
    CGFloat f = x2*x2 + (b-y2)*(b-y2);
    CGFloat m = g/t;
    CGFloat n = (len*len - f)/t + m*m;
    
    CGFloat xa = sqrt(n) - m;
    CGFloat ya = k * xa + b;
    CGFloat xb = -sqrt(n) - m;
    CGFloat yb = k * xb + b;
    if (positive) {
        return yb>ya ? CGPointMake(xb, yb) : CGPointMake(xa, ya);
    }else{
        return yb>ya ? CGPointMake(xa, ya) : CGPointMake(xb, yb);
    }
    return CGPointZero;
}
/// 已知A、B、C、D 4个点，求AB与CD交点  备注：重合和平行返回CGPointZero
static inline CGPoint kj_linellaeCrosspoint(CGPoint A,CGPoint B,CGPoint C,CGPoint D){
    CGFloat x1 = A.x,y1 = A.y;
    CGFloat x2 = B.x,y2 = B.y;
    CGFloat x3 = C.x,y3 = C.y;
    CGFloat x4 = D.x,y4 = D.y;
    
    CGFloat k1 = (y1-y2)/(x1-x2);
    CGFloat k2 = (y3-y4)/(x3-x4);
    CGFloat b1 = y1-k1*x1;
    CGFloat b2 = y4-k2*x4;
    if (x1==x2&&x3!=x4) {
        return CGPointMake(x1, k2*x1+b2);
    }else if (x3==x4&&x1!=x2){
        return CGPointMake(x3, k1*x3+b1);
    }else if (x3==x4&&x1==x2){
        return CGPointZero;
    }else{
        if (y1==y2&&y3!=y4) {
            return CGPointMake((y1-b2)/k2, y1);
        }else if (y3==y4&&y1!=y2){
            return CGPointMake((y4-b1)/k1, y4);
        }else if (y3==y4&&y1==y2){
            return CGPointZero;
        }else{
            if (k1==k2){
                return CGPointZero;
            }else{
                CGFloat x = (b2-b1)/(k1-k2);
                CGFloat y = k2*x+b2;
                return CGPointMake(x, y);
            }
        }
    }
}
/// 已知A、B、C三个点，求AB线对应C的平行线上的点  y = kx + b
static inline CGPoint kj_parallelLineDots(CGPoint A,CGPoint B,CGPoint C){
    CGFloat x1 = A.x,y1 = A.y;
    CGFloat x2 = B.x,y2 = B.y;
    CGFloat x3 = C.x,y3 = C.y;
    CGFloat k = 0;
    if (x1 == x2) k = 1;/// 水平线
    k = (y1-y2)/(x1-x2);
    CGFloat b = y3 - k*x3;
    CGFloat x = x1;
    CGFloat y = k * x + b;/// y = kx + b
    return CGPointMake(x, y);
}

@end
