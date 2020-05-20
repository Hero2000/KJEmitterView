//
//  KJInteriorFinishTools.h
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/20.
//  Copyright © 2020 杨科军. All rights reserved.
//  装修公共方法类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Accelerate/Accelerate.h>

NS_ASSUME_NONNULL_BEGIN
/// 透视选区四点
struct KJKnownPoints {
    CGPoint PointA;
    CGPoint PointB;
    CGPoint PointC;
    CGPoint PointD;
};
typedef struct KJKnownPoints KJKnownPoint;
/// 滑动方向
typedef NS_ENUM(NSInteger, KJSlideDirectionType) {
    KJSlideDirectionTypeLeftBottom, /// 左下
    KJSlideDirectionTypeRightBottom,/// 右下
    KJSlideDirectionTypeRightTop,   /// 右上
    KJSlideDirectionTypeLeftTop,    /// 左上
};
/// 图片指定区域
typedef NS_ENUM(NSInteger, KJImageAppointType) {
    KJImageAppointTypeCustom,   /// 自定义区域，需要传入指定frame
    KJImageAppointTypeTop21,    /// 顶部二分之一
    KJImageAppointTypeCenter21, /// 中间二分之一
    KJImageAppointTypeBottom21, /// 底部二分之一
    KJImageAppointTypeTop31,    /// 顶部三分之一
    KJImageAppointTypeCenter31, /// 中间三分之一
    KJImageAppointTypeBottom31, /// 底部三分之一
    KJImageAppointTypeTop41,    /// 顶部四分之一
    KJImageAppointTypeCenter41, /// 中间四分之一
    KJImageAppointTypeBottom41, /// 底部四分之一
    KJImageAppointTypeTop43,    /// 顶部四分之三
    KJImageAppointTypeCenter43, /// 中间四分之三
    KJImageAppointTypeBottom43, /// 底部四分之三
};
@interface _KJIFinishTools : NSObject

#pragma mark - 几何方程式
/// 已知A、B两点和C点到B点的长度，求垂直AB的C点
+ (CGPoint)kj_perpendicularLineDotsWithPoint1:(CGPoint)A Point2:(CGPoint)B VerticalLenght:(CGFloat)len Positive:(BOOL)pos;
/// 已知A、B、C、D 4个点，求AB与CD交点  备注：重合和平行返回（0,0）
+ (CGPoint)kj_linellaeCrosspointWithPoint1:(CGPoint)A Point2:(CGPoint)B Point3:(CGPoint)C Point4:(CGPoint)D;
/// 求两点线段长度
+ (CGFloat)kj_distanceBetweenPointsWithPoint1:(CGPoint)A Point2:(CGPoint)B;
/// 已知A、B、C三个点，求AB线对应C的平行线上的点  y = kx + b
+ (CGPoint)kj_parallelLineDotsWithPoint1:(CGPoint)A Point2:(CGPoint)B Point3:(CGPoint)C;
/// 椭圆求点方程
+ (CGPoint)kj_ovalPointWithRect:(CGRect)lpRect Angle:(CGFloat)angle;
/// 获取对应的Rect
+ (CGRect)kj_rectWithPoints:(KJKnownPoint)points;
#pragma mark - 图片处理
/** 获取图片指定区域 */
+ (UIImage*)kj_getImageAppointAreaWithImage:(UIImage*)image ImageAppointType:(KJImageAppointType)type CustomFrame:(CGRect)rect;
/** 旋转图片和镜像处理 orientation 图片旋转方向 */
+ (UIImage*)kj_rotationImageWithImage:(UIImage*)image Orientation:(UIImageOrientation)orientation;
@end

NS_ASSUME_NONNULL_END
