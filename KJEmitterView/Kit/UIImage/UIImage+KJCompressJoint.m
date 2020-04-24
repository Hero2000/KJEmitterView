//
//  UIImage+KJCompressJoint.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/4/20.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "UIImage+KJCompressJoint.h"
#import <Accelerate/Accelerate.h>
@implementation UIImage (KJCompressJoint)
#pragma mark - 拼接图片处理
// 画水印
- (UIImage*)kj_waterMark:(UIImage *)mark InRect:(CGRect)rect{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    CGRect imgRect = CGRectMake(0, 0, self.size.width, self.size.height);
    [self drawInRect:imgRect];// 原图
    [mark drawInRect:rect];// 水印图
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newPic;
}
/* Image 拼接
 * headImage   头图片
 * footImage   尾图片
 */
- (UIImage *)kj_jointImageWithHeadImage:(UIImage *)headImage FootImage:(UIImage *)footImage{
    CGSize size = CGSizeZero;
    size.width = self.size.width;
    CGFloat headHeight = !headImage ? 0 : headImage.size.height;
    CGFloat footHeight = !footImage ? 0 : footImage.size.height;
    size.height = self.size.height + headHeight + footHeight;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0); /// 图片是否显示通道
    if (headImage) [headImage drawInRect:CGRectMake(0, 0, self.size.width, headHeight)];
    [self drawInRect:CGRectMake(0, headHeight, self.size.width, self.size.height)];
    if (footImage) [footImage drawInRect:CGRectMake(0, self.size.height + headHeight, self.size.width, footHeight)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}
/**把图片多次合成
 @param loopNums   要合成的次数
 @param orientation 当前的方向
 @return 合成完成的图片
 */
- (UIImage *)kj_imageCompoundWithLoopNums:(NSInteger)loopNums Orientation:(UIImageOrientation)orientation{
    UIGraphicsBeginImageContextWithOptions(self.size ,NO, 0.0);
    //四个参数为水印图片的位置
    //如果要多个位置显示，继续drawInRect就行
    switch (orientation) {
        case UIImageOrientationUp:
            for (int i = 0; i < loopNums; i ++){
                CGFloat X = self.size.width/loopNums*i;
                CGFloat Y = 0;
                CGFloat W = self.size.width/loopNums;
                CGFloat H = self.size.height;
                [self drawInRect:CGRectMake(X, Y, W, H)];
            }
            break;
        case UIImageOrientationLeft :
            for (int i = 0; i < loopNums; i ++){
                CGFloat X = 0;
                CGFloat Y = self.size.height / loopNums * i;
                CGFloat W = self.size.width;
                CGFloat H = self.size.height / loopNums;
                [self drawInRect:CGRectMake(X, Y, W, H)];
            }
            break;
        case UIImageOrientationRight:
            for (int i = 0; i < loopNums; i ++){
                CGFloat X = 0;
                CGFloat Y = self.size.height / loopNums * i;
                CGFloat W = self.size.width;
                CGFloat H = self.size.height / loopNums;
                [self drawInRect:CGRectMake(X, Y, W, H)];
            }
            break;
        default:
            break;
    }
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

/** 任意角度图片旋转 */
- (UIImage *)kj_rotateInRadians:(CGFloat)radians{
    if (!(&vImageRotate_ARGB8888)) return nil;
    const size_t width  = self.size.width;
    const size_t height = self.size.height;
    const size_t bytesPerRow = width * 4;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, space, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(space);
    if (!bmContext) return nil;
    CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = height}, self.CGImage);
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

#pragma mark - 压缩图片处理
/** 压缩图片精确至指定Data大小, 只需循环3次, 并且保持图片不失真 */
- (UIImage*)kj_compressTargetByte:(NSUInteger)maxLength{
    return [UIImage kj_compressImage:self TargetByte:maxLength];
}
/** 压缩图片精确至指定Data大小, 只需循环3次, 并且保持图片不失真 */
+ (UIImage *)kj_compressImage:(UIImage *)image TargetByte:(NSUInteger)maxLength {
    // Compress by quality
    CGFloat compression = 1.;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return image;
    CGFloat max = 1,min = 0;
    // 二分法处理
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    UIImage *resultImage = [UIImage imageWithData:data];
    if (data.length < maxLength) return resultImage;
    
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio)));
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
    }
    return resultImage;
}

@end
