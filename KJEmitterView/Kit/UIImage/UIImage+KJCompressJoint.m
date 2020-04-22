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

/** 图片铺贴 */
- (UIImage*)kj_imageTiledWithTiledType:(KJImageTiledType)type TargetImageSize:(KJImageSize)size Row:(NSInteger)row Col:(NSInteger)col{
    /// 旋转处理之后的图片
//    UIImage *image = [self kj_rotateInRadians:-M_PI*180./180];
    UIImage *image = nil;
    if (type == KJImageTiledTypeAcross) {
        image = [self kj_rotationImageWithOrientation:(UIImageOrientationUpMirrored)];
    }else if (type == KJImageTiledTypeVertical) {
        image = [self kj_rotationImageWithOrientation:(UIImageOrientationDownMirrored)];
    }
    CGSize siz = CGSizeMake(size.w, size.h);
    UIGraphicsBeginImageContextWithOptions(siz ,NO, 0.0);
    CGFloat x,y;
    CGFloat w = size.w / row;
    CGFloat h = size.h / col;
    for (int i=0; i<row; i++) {
        for (int j=0; j<col; j++) {
            x = w * i;
            y = h * j;
            if (type == KJImageTiledTypeCustom) {
                [self drawInRect:CGRectMake(x,y,w,h)];
            }else if (type == KJImageTiledTypeAcross) {
                if (i%2) {
                    [image drawInRect:CGRectMake(x,y,w,h)];
                }else{
                    [self drawInRect:CGRectMake(x,y,w,h)];
                }
            }else if (type == KJImageTiledTypeVertical) {
                if (j%2) {
                    [image drawInRect:CGRectMake(x,y,w,h)];
                }else{
                    [self drawInRect:CGRectMake(x,y,w,h)];
                }
            }else if (type == KJImageTiledTypePositively || type == KJImageTiledTypeBackslash) {
                bool boo = type == KJImageTiledTypePositively ? i%2 : !(i%2);
                if (boo) {
                    y = y - h/2;
                    if (j==col-1) [self drawInRect:CGRectMake(x,y+h,w,h)];
                }
                [self drawInRect:CGRectMake(x,y,w,h)];
            }
        }
    }
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}
/** 旋转图片和镜像处理 orientation 图片旋转方向 */
- (UIImage*)kj_rotationImageWithOrientation:(UIImageOrientation)orientation{
    CGRect bnds = CGRectZero;
    UIImage *copy = nil;
    CGContextRef ctxt = nil;
    CGImageRef imag = self.CGImage;
    CGRect rect = CGRectZero;
    CGAffineTransform tran = CGAffineTransformIdentity;
    rect.size.width  = CGImageGetWidth(imag);
    rect.size.height = CGImageGetHeight(imag);
    bnds = rect;
    switch (orientation){
        case UIImageOrientationUp:
            break;
        case UIImageOrientationUpMirrored:
            tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            break;
        case UIImageOrientationDown:
            tran = CGAffineTransformMakeTranslation(rect.size.width,rect.size.height);
            tran = CGAffineTransformRotate(tran, M_PI);
            break;
        case UIImageOrientationDownMirrored:
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
            tran = CGAffineTransformScale(tran, 1.0, -1.0);
            break;
        case UIImageOrientationLeft:
            bnds = kj_swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeftMirrored:
            bnds = kj_swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height,rect.size.width);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRight:
            bnds = kj_swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored:
            bnds = kj_swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeScale(-1.0, 1.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
    }

    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
    switch (orientation){
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        CGContextScaleCTM(ctxt, -1.0, 1.0);
        CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
        break;
          
        default:
        CGContextScaleCTM(ctxt, 1.0, -1.0);
        CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
        break;
    }

    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return copy;
}
static CGRect kj_swapWidthAndHeight(CGRect rect){
    CGFloat swap = rect.size.width;
    rect.size.width  = rect.size.height;
    rect.size.height = swap;
    return rect;
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
