//
//  UIImage+KJCompressJoint.h
//  KJEmitterView
//
//  Created by 杨科军 on 2020/4/20.
//  Copyright © 2020 杨科军. All rights reserved.
//  图片压缩拼接处理

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (KJCompressJoint)
/** 画水印 给图片添加水印 */
- (UIImage*)kj_waterMark:(UIImage*)mark InRect:(CGRect)rect;

/** 拼接图片 headImage:头图片 footImage:尾图片 */
- (UIImage*)kj_jointImageWithHeadImage:(UIImage*)headImage FootImage:(UIImage*)footImage;

/** 图片多次合成处理 loopTimes:要合成的次数 orientation:当前的方向 */
- (UIImage*)kj_imageCompoundWithLoopNums:(NSInteger)loopTimes Orientation:(UIImageOrientation)orientation;

/** 任意角度图片旋转 */
- (UIImage*)kj_rotateInRadians:(CGFloat)radians;

#pragma mark - 压缩图片处理
/** 压缩图片精确至指定Data大小, 只需循环3次, 并且保持图片不失真 */
- (UIImage*)kj_compressTargetByte:(NSUInteger)maxLength;

/** 压缩图片精确至指定Data大小, 只需循环3次, 并且保持图片不失真 */
+ (UIImage*)kj_compressImage:(UIImage*)image TargetByte:(NSUInteger)maxLength;

@end

NS_ASSUME_NONNULL_END
