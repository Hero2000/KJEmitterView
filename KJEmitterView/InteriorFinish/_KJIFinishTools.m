//
//  KJInteriorFinishTools.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/20.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "_KJIFinishTools.h"

@implementation _KJIFinishTools

#pragma mark - 几何方程式
/// 已知A、B两点和C点到B点的长度，求垂直AB的C点
+ (CGPoint)kj_perpendicularLineDotsWithPoint1:(CGPoint)A Point2:(CGPoint)B VerticalLenght:(CGFloat)len Positive:(BOOL)pos{
    return kj_perpendicularLineDots(A,B,len,pos);
}
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
/// 已知A、B、C、D 4个点，求AB与CD交点  备注：重合和平行返回（0,0）
+ (CGPoint)kj_linellaeCrosspointWithPoint1:(CGPoint)A Point2:(CGPoint)B Point3:(CGPoint)C Point4:(CGPoint)D{
    return kj_linellaeCrosspoint(A,B,C,D);
}
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
        return CGPointMake(0, 0);
    }else{
        if (y1==y2&&y3!=y4) {
            return CGPointMake((y1-b2)/k2, y1);
        }else if (y3==y4&&y1!=y2){
            return CGPointMake((y4-b1)/k1, y4);
        }else if (y3==y4&&y1==y2){
            return CGPointMake(0, 0);
        }else{
            if (k1==k2){
                return CGPointMake(0, 0);
            }else{
                CGFloat x = (b2-b1)/(k1-k2);
                CGFloat y = k2*x+b2;
                return CGPointMake(x, y);
            }
        }
    }
}
/// 求两点线段长度
+ (CGFloat)kj_distanceBetweenPointsWithPoint1:(CGPoint)A Point2:(CGPoint)B{
    return kj_distanceBetweenPoints(A,B);
}
static inline CGFloat kj_distanceBetweenPoints(CGPoint point1,CGPoint point2) {
    CGFloat deX = point2.x - point1.x;
    CGFloat deY = point2.y - point1.y;
    return sqrt(deX*deX + deY*deY);
};
/// 已知A、B、C三个点，求AB线对应C的平行线上的点  y = kx + b
+ (CGPoint)kj_parallelLineDotsWithPoint1:(CGPoint)A Point2:(CGPoint)B Point3:(CGPoint)C{
    return kj_parallelLineDots(A,B,C);
}
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
/// 椭圆求点方程
+ (CGPoint)kj_ovalPointWithRect:(CGRect)lpRect Angle:(CGFloat)angle{
    CGPoint pt = CGPointZero;
    double a = lpRect.size.width / 2.0f;
    double b = lpRect.size.height / 2.0f;
    if (a == 0 || b == 0) return CGPointMake(lpRect.origin.x, lpRect.origin.y);

    //弧度
    double radian = angle * M_PI / 180.0f;
    //获取弧度正弦值
    double yc = sin(radian);
    //获取弧度余弦值
    double xc = cos(radian);
    //获取曲率 r = ab/Sqrt((a.Sinθ)^2+(b.Cosθ)^2
    double radio = (a * b) / sqrt(pow(yc * a, 2.0) + pow(xc * b, 2.0));

    //计算坐标
    double ax = radio * xc;
    double ay = radio * yc;
    pt.x = lpRect.origin.x + a + ax;
    pt.y = lpRect.origin.y + b + ay;
    return pt;
}
/// 获取对应的Rect
+ (CGRect)kj_rectWithPoints:(KJKnownPoint)points{
    NSArray *temp = @[NSStringFromCGPoint(points.PointA),
                      NSStringFromCGPoint(points.PointB),
                      NSStringFromCGPoint(points.PointC),
                      NSStringFromCGPoint(points.PointD)];
    CGFloat minX = 0,minY = 0,maxX = 0,maxY = 0;
    for (int i = 0; i<temp.count; i++) {
        CGPoint currentPoint = CGPointFromString(temp[i]);
        if (i == 0) {
            minX = maxX = currentPoint.x;
            minY = maxY = currentPoint.y;
            continue;
        }
        minX = currentPoint.x < minX ? currentPoint.x:minX;
        maxX = currentPoint.x > maxX ? currentPoint.x:maxX;
        minY = currentPoint.y < minY ? currentPoint.y:minY;
        maxY = currentPoint.y > maxY ? currentPoint.y:maxY;
    }
    return CGRectMake(minX, minY, maxX - minX, maxY - minY);
}

#pragma mark - 图片处理
/** 获取图片指定区域 */
+ (UIImage*)kj_getImageAppointAreaWithImage:(UIImage*)image ImageAppointType:(KJImageAppointType)type CustomFrame:(CGRect)rect{
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;
    switch (type) {
        case KJImageAppointTypeCustom:
            break;
        case KJImageAppointTypeTop21:
            rect = CGRectMake(0, 0, w, h/2.);
            break;
        case KJImageAppointTypeCenter21:
            rect = CGRectMake(0, h/4., w, h/2.);
            break;
        case KJImageAppointTypeBottom21:
            rect = CGRectMake(0, h/2., w, h/2.);
            break;
        case KJImageAppointTypeTop31:
            rect = CGRectMake(0, 0, w, h/3.);
            break;
        case KJImageAppointTypeCenter31:
            rect = CGRectMake(0, h/3., w, h/3.);
            break;
        case KJImageAppointTypeBottom31:
            rect = CGRectMake(0, h/3.*2, w, h/3.);
            break;
        case KJImageAppointTypeTop41:
            rect = CGRectMake(0, 0, w, h/4.);
            break;
        case KJImageAppointTypeCenter41:
            rect = CGRectMake(0, h/4., w, h/4.);
            break;
        case KJImageAppointTypeBottom41:
            rect = CGRectMake(0, h/4.*2, w, h/4.);
            break;
        case KJImageAppointTypeTop43:
            rect = CGRectMake(0, 0, w, h/4.*3);
            break;
        case KJImageAppointTypeCenter43:
            rect = CGRectMake(0, h/8., w, h/4.*3);
            break;
        case KJImageAppointTypeBottom43:
            rect = CGRectMake(0, h/4., w, h/4.*3);
            break;
        default:
            rect = CGRectMake(0, 0, w, h);
            break;
    }
    /// 获取裁剪图片区域 - 从原图片中取小图
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return img;
}
/** 旋转图片和镜像处理 orientation 图片旋转方向 */
+ (UIImage*)kj_rotationImageWithImage:(UIImage*)image Orientation:(UIImageOrientation)orientation{
    CGRect rect = CGRectZero;
    rect.size.width  = CGImageGetWidth(image.CGImage);
    rect.size.height = CGImageGetHeight(image.CGImage);
    CGRect bounds = rect;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (orientation){
        case UIImageOrientationUp:
            break;
        case UIImageOrientationUpMirrored:
            transform = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown:
            transform = CGAffineTransformMakeTranslation(rect.size.width,rect.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformMakeTranslation(0.0, rect.size.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeft:
            bounds = kj_swapWidthAndHeight(bounds);
            transform = CGAffineTransformMakeTranslation(0.0, rect.size.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeftMirrored:
            bounds = kj_swapWidthAndHeight(bounds);
            transform = CGAffineTransformMakeTranslation(rect.size.height,rect.size.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRight:
            bounds = kj_swapWidthAndHeight(bounds);
            transform = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored:
            bounds = kj_swapWidthAndHeight(bounds);
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
    }
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (orientation){
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        CGContextScaleCTM(context, -1.0, 1.0);
        CGContextTranslateCTM(context, -rect.size.height, 0.0);
        break;
        default:
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextTranslateCTM(context, 0.0, -rect.size.height);
        break;
    }

    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, image.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}
static inline CGRect kj_swapWidthAndHeight(CGRect rect){
    CGFloat swap = rect.size.width;
    rect.size.width  = rect.size.height;
    rect.size.height = swap;
    return rect;
}

@end
