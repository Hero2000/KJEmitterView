//
//  KJWallpaperPave.h
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/20.
//  Copyright © 2020 杨科军. All rights reserved.
//  墙纸铺贴

#import <Foundation/Foundation.h>
#import "_KJIFinishTools.h"
NS_ASSUME_NONNULL_BEGIN
/// 对花效果
typedef NS_ENUM(NSInteger, KJImageTiledType) {
    KJImageTiledTypeCustom,  /// 默认，平铺
    KJImageTiledTypeAcross,  /// 横对花
    KJImageTiledTypeVertical,/// 竖对花
    KJImageTiledTypePositively, /// 正斜对花
    KJImageTiledTypeBackslash,  /// 反斜对花
};
static NSString * const _Nonnull KJImageTiledTypeStringMap[] = {
    [KJImageTiledTypeCustom]     = @"平铺",
    [KJImageTiledTypeAcross]     = @"横对花",
    [KJImageTiledTypeVertical]   = @"竖对花",
    [KJImageTiledTypePositively] = @"正斜对花",
    [KJImageTiledTypeBackslash]  = @"反斜对花",
};
@interface KJWallpaperPave : NSObject
/// 墙纸铺贴效果
+ (UIImage*)kj_wallpaperPaveWithMaterialImage:(UIImage*)xImage TiledType:(KJImageTiledType)type TargetImageSize:(CGSize)size Width:(CGFloat)w;
+ (UIImage*)kj_wallpaperPaveWithMaterialImage:(UIImage*)xImage TiledType:(KJImageTiledType)type TargetImageSize:(CGSize)size Row:(NSInteger)row Col:(NSInteger)col;
@end

NS_ASSUME_NONNULL_END
