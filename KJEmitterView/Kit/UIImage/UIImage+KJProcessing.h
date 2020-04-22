//
//  UIImage+KJProcessing.h
//  KJEmitterView
//
//  Created by 杨科军 on 2018/12/1.
//  Copyright © 2018 杨科军. All rights reserved.
//  图片加工处理

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (KJProcessing)

/** 指定位置屏幕截图 */
+ (UIImage*)kj_captureScreen:(UIView *)view Rect:(CGRect)rect;

/// 根据特定的区域对图片进行裁剪
+ (UIImage*)kj_cutImageWithImage:(UIImage*)image Frame:(CGRect)frame;

/** 屏幕截图 返回一张截图 */
+ (UIImage*)kj_captureScreen:(UIView*)view;

/** 多边形切图 */
+ (UIImage*)kj_polygonCaptureImageWithImageView:(UIImageView*)imageView PointArray:(NSArray*)points;

/** 不规则图形切图 */
+ (UIImage*)kj_anomalyCaptureImageWithView:(UIView*)view BezierPath:(UIBezierPath*)path;

/** 截取当前屏幕 */
+ (UIImage*)kj_captureScreenWindow;

/** 返回圆形图片 直接操作layer.masksToBounds = YES 会比较卡顿 */
- (UIImage*)kj_circleImage;

/** 改变Image的任何的大小 size:目的大小 */
- (UIImage*)kj_cropImageWithAnySize:(CGSize)size;

/** 裁剪和拉升图片 targetSize:裁剪尺寸 */
- (UIImage*)kj_scalingAndCroppingForTargetSize:(CGSize)targetSize;

/** 通过比例来缩放图片 scale:缩放比例 */
- (UIImage*)kj_transformImageScale:(CGFloat)scale;

/// 获取图片大小
+ (double)kj_calulateImageFileSize:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
