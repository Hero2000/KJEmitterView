//
//  KJInteriorFinishTools.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/20.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "_KJIFinishTools.h"

@implementation _KJIFinishTools

#pragma mark - 逻辑处理
/// 判断手势方向
+ (KJPanMoveDirectionType)kj_moveDirectionWithTranslation:(CGPoint)translation{
    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);
    // 设置滑动有效距离
    if (MAX(absX, absY) < 1.0) return 0;
    if (absY > absX) {
        if (translation.y<0) {
            return 1;//向上滑动
        }else{
            return 2;//向下滑动
        }
    }else if (absX > absY) {
        if (translation.x<0) {
            return 3;//向左滑动
        }else{
            return 4;//向右滑动
        }
    }
    return KJPanMoveDirectionTypeNoMove;
}
/// 确定滑动方向
+ (KJSlideDirectionType)kj_slideDirectionWithPoint:(CGPoint)point Point2:(CGPoint)point2{
    bool boo = (point.x - point2.x) < 0 ? true : false;
    bool booo= (point.y - point2.y) < 0 ? true : false;
    if (boo & booo) return KJSlideDirectionTypeLeftBottom;
    if (!boo&!booo) return KJSlideDirectionTypeRightTop;
    if (boo) return KJSlideDirectionTypeLeftTop;
    return KJSlideDirectionTypeRightBottom;
}
/// 不同滑动方向转换为正确透视区域四点
+ (KJKnownPoints)kj_pointsWithKnownPoints:(KJKnownPoints)knownPoints BeginPoint:(CGPoint)beginPoint EndPoint:(CGPoint)endPoint DirectionType:(KJSlideDirectionType)directionType{
    CGPoint A = knownPoints.PointA;
    CGPoint B = knownPoints.PointB;
    CGPoint C = knownPoints.PointC;
    CGPoint D = knownPoints.PointD;
    CGPoint E = beginPoint;
    CGPoint F = CGPointZero;
    CGPoint G = endPoint;
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
/// 平移之后透视点相对处理
+ (KJKnownPoints)kj_changePointsWithKnownPoints:(KJKnownPoints)points Translation:(CGPoint)translation{
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
/// 判断当前点是否在路径选区内
+ (bool)kj_confirmCurrentPointWithPoint:(CGPoint)point BezierPath:(UIBezierPath*)path{
    return [path containsPoint:point];
}
/// 判断当前点是否在已知四点选区内
+ (bool)kj_confirmCurrentPointWithPoint:(CGPoint)point KnownPoints:(KJKnownPoints)points{
    UIBezierPath *path = ({
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:points.PointA];
        [path addLineToPoint:points.PointB];
        [path addLineToPoint:points.PointC];
        [path addLineToPoint:points.PointD];
        [path closePath];
        path;
    });
    return [self kj_confirmCurrentPointWithPoint:point BezierPath:path];
}
/// 判断当前点是否在Rect内
+ (bool)kj_confirmCurrentPointWithPoint:(CGPoint)point Rect:(CGRect)rect{
    return CGRectContainsPoint(rect, point);
}
/// 获取对应的Rect
+ (CGRect)kj_rectWithPoints:(KJKnownPoints)points{
    NSArray *temp = @[NSStringFromCGPoint(points.PointA),
                      NSStringFromCGPoint(points.PointB),
                      NSStringFromCGPoint(points.PointC),
                      NSStringFromCGPoint(points.PointD)];
    CGFloat minX = points.PointA.x;
    CGFloat maxX = points.PointA.x;
    CGFloat minY = points.PointA.y;
    CGFloat maxY = points.PointA.y;
    CGPoint pt = CGPointZero;
    for (NSString *string in temp) {
        pt = CGPointFromString(string);
        minX = pt.x < minX ? pt.x : minX;
        maxX = pt.x > maxX ? pt.x : maxX;
        minY = pt.y < minY ? pt.y : minY;
        maxY = pt.y > maxY ? pt.y : maxY;
    }
    return CGRectMake(minX-1, minY-1, maxX - minX+2, maxY - minY+2);
}

#pragma mark - 几何方程式
/// 已知A、B两点和C点到B点的长度，求垂直AB的C点
+ (CGPoint)kj_perpendicularLineDotsWithPoint1:(CGPoint)A Point2:(CGPoint)B VerticalLenght:(CGFloat)len Positive:(BOOL)pos{
    return kj_perpendicularLineDots(A,B,len,pos);
}
static inline CGPoint kj_perpendicularLineDots(CGPoint A,CGPoint B,CGFloat len,BOOL positive){
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
    rect.size.width = CGImageGetWidth(image.CGImage);
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
/** 任意角度图片旋转 */
+ (UIImage*)kj_rotateImage:(UIImage*)image Radians:(CGFloat)radians{
    if (!(&vImageRotate_ARGB8888)) return nil;
    const size_t width  = image.size.width;
    const size_t height = image.size.height;
    const size_t bytesPerRow = width * 4;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, space, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(space);
    if (!bmContext) return nil;
    CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = height}, image.CGImage);
    UInt8 *data = (UInt8*)CGBitmapContextGetData(bmContext);
    if (!data){
        CGContextRelease(bmContext);
        return nil;
    }
    vImage_Buffer src  = {data, height, width, bytesPerRow};
    vImage_Buffer dest = {data, height, width, bytesPerRow};
    Pixel_8888 bgColor = {0, 0, 0, 0};
    vImageRotate_ARGB8888(&src, &dest, NULL, radians, bgColor, kvImageBackgroundColorFill);
    CGImageRef rotatedImageRef = CGBitmapContextCreateImage(bmContext);
    UIImage *newImg = [UIImage imageWithCGImage:rotatedImageRef];
    CGImageRelease(rotatedImageRef);
    CGContextRelease(bmContext);
    return newImg;
}
/// 图片围绕任意点旋转任意角度
+ (UIImage*)kj_rotateImage:(UIImage*)image Rotation:(CGFloat)rotation Point:(CGPoint)point{
    NSInteger num = (NSInteger)(floor(rotation));
    if (num == rotation && num % 360 == 0) return image;
    double radius = rotation * M_PI / 180;
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;
    UIGraphicsBeginImageContext(CGSizeMake(w, h));
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextTranslateCTM(bitmap, point.x, -point.y);
    CGContextRotateCTM(bitmap, radius);
    CGFloat x = -point.x;
    CGFloat y = -h + point.y;
    CGContextDrawImage(bitmap, CGRectMake(x, y, w, h), image.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
/// 矩形图扭曲变形成椭圆弧形图
+ (UIImage*)kj_orthogonImageBecomeOvalWithImage:(UIImage*)image Rect:(CGRect)rect Margin:(bool)margin{
    CGImageRef imageRef = image.CGImage;
    CGFloat width  = 180;//image.size.width;
    CGFloat height = 180;//image.size.height;
    CGColorSpaceRef space = CGImageGetColorSpace(imageRef);
    CGImageAlphaInfo bitmapInfo = CGImageGetAlphaInfo(imageRef);
    unsigned char * imageData = malloc(width * height * 4);/// 读取图片中的所有像素点数据
    CGContextRef imageContext = CGBitmapContextCreate(imageData, width, height, 8, width * 4, space, bitmapInfo);
    CGContextDrawImage(imageContext, CGRectMake(0, 0, width, height), imageRef);// 解码
    CGContextRelease(imageContext);
    CGFloat shapW = width;//rect.size.width;
    CGFloat shapH = height * 3;//rect.size.height * 3;
    // 读取某个点的内容 初始化新的图片需要的data
    unsigned char * shapeData = malloc(shapW * shapH * 4);
    /// 是否需要透明空白处
    if (!margin) {
        for (int i = 0; i < shapH-1; i++) {
            for (int j = 0; j < shapW-1; j++) {
                int offset = (i * shapW + j) * 4;
                shapeData[offset + 0] = 255; // r
                shapeData[offset + 1] = 255; // g
                shapeData[offset + 2] = 255; // b
                shapeData[offset + 3] = 255; // a
            }
        }
    }
    // 扫描图片像素粒子
    for (int i = 0; i < height-1; i++) {
        for (int j = 0; j < width-1; j++) {
            // 计算原图每个点在新图中的位置
//            CGFloat angle = j * 1.0f / shapW * 180.0f;
//            CGPoint point = [self kj_ovalPointWithRect:CGRectMake(0, 0, 180, 100) Angle:180-angle];
            CGFloat x = j;
            CGFloat y = x; /// 画一条线
            y += i; /// 画全部
            if (y>shapH) continue; /// 超出画布处理
            int newOffset = (y * shapW + x) * 4;
            int offset = (i * width + j) * 4;
            // 添加像素
            shapeData[newOffset]     = imageData[offset];
            shapeData[newOffset + 1] = imageData[offset + 1];
            shapeData[newOffset + 2] = imageData[offset + 2];
            shapeData[newOffset + 3] = imageData[offset + 3];
        }
    }
    //创建新图片
    CGContextRef newContext = CGBitmapContextCreate(shapeData, shapW, shapH, 8, shapW*4, space, bitmapInfo);
    CGImageRef cgImage = CGBitmapContextCreateImage(newContext);
    UIImage *newImage = [UIImage imageWithCGImage:cgImage];
    CGContextRelease(newContext);
    CGColorSpaceRelease(space);
    CGImageRelease(cgImage);
    free(shapeData);
    free(imageData);
    return newImage;
}

@end
