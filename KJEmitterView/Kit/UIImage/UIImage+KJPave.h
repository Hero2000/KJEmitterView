//
//  UIImage+KJPave.h
//  KJEmitterView
//
//  Created by 杨科军 on 2020/4/22.
//  Copyright © 2020 杨科军. All rights reserved.
//  对花铺贴效果和地板拼接效果

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/// 对花效果
typedef NS_ENUM(NSInteger, KJImageTiledType) {
    KJImageTiledTypeCustom, /// 默认，平铺
    KJImageTiledTypeAcross, /// 横对花
    KJImageTiledTypeVertical,/// 竖对花
    KJImageTiledTypePositively, /// 正斜对花
    KJImageTiledTypeBackslash, /// 反斜对花
};
static NSString  * const _Nonnull KJImageTiledTypeStringMap[] = {
    [KJImageTiledTypeCustom]  = @"平铺",
    [KJImageTiledTypeAcross]  = @"横对花",
    [KJImageTiledTypeVertical]   = @"竖对花",
    [KJImageTiledTypePositively] = @"正斜对花",
    [KJImageTiledTypeBackslash]  = @"反斜对花",
};
/// 地板拼接效果
typedef NS_ENUM(NSInteger, KJImageFloorJointType) {
    KJImageFloorJointTypeCustom = 0, /// 默认，正常平铺（艺术拼法）
    KJImageFloorJointTypeDouble, /// 两拼法
    KJImageFloorJointTypeAcrossAngle, /// 横倒角
    KJImageFloorJointTypeVerticalAngle, /// 竖倒角
    KJImageFloorJointTypeThree, /// 三拼法
    KJImageFloorJointTypeLengthMix, /// 长短混合
    KJImageFloorJointTypeClassical, /// 古典拼法
    KJImageFloorJointTypeConcaveConvex, /// 凹凸效果
    KJImageFloorJointTypeLongShortThird, /// 长短三分之一效果
};
/// 图片指定区域
typedef NS_ENUM(NSInteger, KJImageAppointType) {
    KJImageAppointTypeCustom, /// 自定义区域，需要传入指定frame
    KJImageAppointTypeTop21, /// 顶部二分之一
    KJImageAppointTypeCenter21, /// 中间二分之一
    KJImageAppointTypeBottom21, /// 底部二分之一
    KJImageAppointTypeTop31, /// 顶部三分之一
    KJImageAppointTypeCenter31, /// 中间三分之一
    KJImageAppointTypeBottom31, /// 底部三分之一
    KJImageAppointTypeTop41, /// 顶部四分之一
    KJImageAppointTypeCenter41, /// 中间四分之一
    KJImageAppointTypeBottom41, /// 底部四分之一
    KJImageAppointTypeTop43, /// 顶部四分之三
    KJImageAppointTypeCenter43, /// 中间四分之三
    KJImageAppointTypeBottom43, /// 底部四分之三
};

struct KJImageSize {
    CGFloat w;
    CGFloat h;
};typedef struct KJImageSize KJImageSize;
static inline KJImageSize KJImageSizeMake(CGFloat w, CGFloat h) {
    KJImageSize size; size.w = w; size.h = h; return size;
}

@interface UIImage (KJPave)

/** 旋转图片和镜像处理 */
- (UIImage*)kj_rotationImageWithOrientation:(UIImageOrientation)orientation;

/** 对花铺贴效果 */
- (UIImage*)kj_imageTiledWithTiledType:(KJImageTiledType)type TargetImageSize:(KJImageSize)size Row:(NSInteger)row Col:(NSInteger)col;

/** 地板拼接效果 */
- (UIImage*)kj_imageFloorWithFloorJointType:(KJImageFloorJointType)type TargetImageSize:(KJImageSize)size FloorWidth:(CGFloat)floorWidth;

/** 获取图片指定区域 */
- (UIImage*)kj_getImageAppointAreaWithImageAppointType:(KJImageAppointType)type CustomFrame:(CGRect)rect;

/// 横向和纵向裁剪图片，然后再旋转180
- (NSArray<UIImage*>*)kj_tailorImageWithAcross:(int)across Vertical:(int)vertical;

@end

NS_ASSUME_NONNULL_END
