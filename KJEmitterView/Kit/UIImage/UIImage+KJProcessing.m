//
//  UIImage+KJProcessing.m
//  KJEmitterView
//
//  Created by 杨科军 on 2018/12/1.
//  Copyright © 2018 杨科军. All rights reserved.
//

#import "UIImage+KJProcessing.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImage (KJProcessing)

/** 指定位置屏幕截图 */
+ (UIImage*)kj_captureScreen:(UIView *)view Rect:(CGRect)rect{
    return ({
        UIGraphicsBeginImageContext(view.frame.size);
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImage *newImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([viewImage CGImage], rect)];
        newImage;
    });
}
/// 根据特定的区域对图片进行裁剪
+ (UIImage*)kj_cutImageWithImage:(UIImage*)image Frame:(CGRect)frame{
    return ({
        /// 方法说明：核心裁剪方法CGImageCreateWithImageInRect(CGImageRef image,CGRect rect)
        CGImageRef tmp = CGImageCreateWithImageInRect([image CGImage], frame);
        UIImage *newImage = [UIImage imageWithCGImage:tmp scale:image.scale orientation:image.imageOrientation];
        CGImageRelease(tmp);
        newImage;
    });
}
/** 屏幕截图 */
+ (UIImage*)kj_captureScreen:(UIView *)view{
    // 手动开启图片上下文
    UIGraphicsBeginImageContext(view.bounds.size);
    // 获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 渲染上下文到图层
    [view.layer renderInContext:ctx];
    // 从当前上下文获取图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 结束上下文
    UIGraphicsEndImageContext();
    return newImage;
}
/// 多边形切图
+ (UIImage*)kj_polygonCaptureImageWithImageView:(UIImageView*)imageView PointArray:(NSArray*)points{
    CGRect rect = CGRectZero;
    rect.size = imageView.image.size;
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0);
    [[UIColor blackColor] setFill];
    UIRectFill(rect);
    [[UIColor whiteColor] setFill];
    
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    //起点
    CGPoint p1 = [self convertCGPoint:[points[0] CGPointValue] fromRect1:imageView.frame.size toRect2:imageView.frame.size];
    [aPath moveToPoint:p1];
    //其他点
    for (int i = 1; i< points.count; i++) {
        CGPoint point = [self convertCGPoint:[points[i] CGPointValue] fromRect1:imageView.frame.size toRect2:imageView.frame.size];
        [aPath addLineToPoint:point];
    }
    [aPath closePath];
    [aPath fill];
    
    //遮罩层
    UIImage *mask = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextClipToMask(UIGraphicsGetCurrentContext(), rect, mask.CGImage);
    [imageView.image drawAtPoint:CGPointZero];
    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return maskedImage;
}
+ (CGPoint)convertCGPoint:(CGPoint)point1 fromRect1:(CGSize)rect1 toRect2:(CGSize)rect2 {
    point1.y = rect1.height - point1.y;
    CGPoint result = CGPointMake((point1.x*rect2.width)/rect1.width, (point1.y*rect2.height)/rect1.height);
    return result;
}
/** 不规则图形切图 */
+ (UIImage*)kj_anomalyCaptureImageWithView:(UIView*)view BezierPath:(UIBezierPath*)path{
    CAShapeLayer *maskLayer= [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    maskLayer.fillColor = [UIColor blackColor].CGColor;//填充色
    maskLayer.strokeColor = [UIColor darkGrayColor].CGColor;
    maskLayer.frame = view.bounds;
    maskLayer.contentsCenter = CGRectMake(0.5, 0.5, 0.1, 0.1);
    //按比例放大 不变形
    maskLayer.contentsScale = [UIScreen mainScreen].scale;
    
    CALayer * contentLayer = [CALayer layer];
    contentLayer.mask = maskLayer;
    contentLayer.frame = view.bounds;
    view.layer.mask = maskLayer;
    UIImage *image = [self kj_captureScreen:view];
    return image;
}

/** 截取当前屏幕 */
+ (UIImage*)kj_captureScreenWindow{
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation))
        imageSize = [UIScreen mainScreen].bounds.size;
    else
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]){
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft){
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        }else if (orientation == UIInterfaceOrientationLandscapeRight){
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]){
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        }else{
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/** 返回圆形图片 直接操作layer.masksToBounds = YES 会比较卡顿 */
- (UIImage *)kj_circleImage{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);/// 图片是否显示通道
    CGContextRef ctx = UIGraphicsGetCurrentContext(); // 获得上下文
    // 添加一个圆
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextAddEllipseInRect(ctx, rect);
    CGContextClip(ctx);// 裁剪
    // 将图片画上去
    [self drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/** 改变Image的任何的大小
 *  @param size 目的大小
 *  @return 修改后的Image
 */
- (UIImage *)kj_cropImageWithAnySize:(CGSize)size{
    float scale = self.size.width/self.size.height;
    CGRect rect = CGRectMake(0, 0, 0, 0);
    if (scale > size.width/size.height){
        rect.origin.x = (self.size.width - self.size.height * size.width/size.height)/2;
        rect.size.width  = self.size.height * size.width/size.height;
        rect.size.height = self.size.height;
    }else {
        rect.origin.y = (self.size.height - self.size.width/size.width * size.height)/2;
        rect.size.width  = self.size.width;
        rect.size.height = self.size.width/size.width * size.height;
    }
    CGImageRef imageRef   = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return croppedImage;
}

/** 裁剪和拉升图片 */
- (UIImage*)kj_scalingAndCroppingForTargetSize:(CGSize)targetSize{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize)== NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        scaleFactor = widthFactor > heightFactor ? widthFactor : heightFactor;
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight)* 0.5;
        }else if (widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth)* 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

/** 通过比例来缩放图片 scale 缩放比例*/
- (UIImage *)kj_transformImageScale:(CGFloat)scale{
    UIGraphicsBeginImageContext(CGSizeMake(self.size.width * scale, self.size.height * scale));
    [self drawInRect:CGRectMake(0, 0, self.size.width * scale, self.size.height * scale)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

/// 获取图片大小
+ (double)kj_calulateImageFileSize:(UIImage *)image {
    NSData *data = UIImagePNGRepresentation(image);
    if (!data) {
        /// 实际上, UIImageJPEGRepresentation这个函数获取到的图片文件大小并不准确
        /// 后面的参数改为 0.7才大概是原图片的文件大小
        data = UIImageJPEGRepresentation(image, 0.7);
    }
    return [data length] * 1.0;
//    double num = dataLength;
//    NSArray *typeArray = @[@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB",@"ZB",@"YB"];
//    NSInteger index = 0;
//    while (dataLength > 1024) {
//        dataLength /= 1024.0;
//        index ++;
//    }
//    return @[@(num),[NSString stringWithFormat:@"image = %.3f %@",dataLength,typeArray[index]]];
}

//// 改变图片的透明度
//+ (UIImage *)changeAlphaOfImageWith:(CGFloat)alpha withImage:(UIImage*)image{
//    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
//    CGContextScaleCTM(ctx, 1, -1);
//    CGContextTranslateCTM(ctx, 0, -area.size.height);
//    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
//    CGContextSetAlpha(ctx, alpha);
//    CGContextDrawImage(ctx, area, image.CGImage);
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newImage;
//}
//
//// 更换图片的背景颜色
//+ (UIImage*) imageToTransparent:(UIImage*) image{
//    // 分配内存
//    const int imageWidth = image.size.width;
//    const int imageHeight = image.size.height;
//    size_t bytesPerRow = imageWidth * 4;
//    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
//    // 创建context
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
//    kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
//    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
//    // 遍历像素
//    int pixelNum = imageWidth * imageHeight;
//    uint32_t* pCurPtr = rgbImageBuf;
//    for (int i = 0; i < pixelNum; i++, pCurPtr++){
//        if ((*pCurPtr & 0xFFFFFF00) == 0xffffff00) {
//            // 此处把白色背景颜色给变为透明
//            uint8_t* ptr = (uint8_t*)pCurPtr;
//            ptr[0] = 0;
//        }else{
//            // 改成下面的代码，会将图片转成想要的颜色
//            uint8_t* ptr = (uint8_t*)pCurPtr;
//            ptr[3] = 0; //0~255
//            ptr[2] = 0;
//            ptr[1] = 0;
//        }
//    }
//
//    // 将内存转成image
//    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
//    CGImageRef imageRef = CGImageCreate(imageWidth,
//                                        imageHeight,
//                                        8,
//                                        32,
//                                        bytesPerRow,
//                                        colorSpace,
//                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little,
//                                        dataProvider,
//                                        NULL,
//                                        true,
//                                        kCGRenderingIntentDefault);
//    CGDataProviderRelease(dataProvider);
//    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
//    // 释放
//    CGImageRelease(imageRef);
//    CGContextRelease(context);
//    CGColorSpaceRelease(colorSpace);
//    return resultUIImage;
//}
//
//void ProviderReleaseData (void *info, const void *data, size_t size){
//    free((void*)data);
//}
//
//- (UIImage*) imageToTransparent:(UIImage*) image{
//    // 分配内存
//    const int imageWidth = image.size.width;
//    const int imageHeight = image.size.height;
//    size_t bytesPerRow = imageWidth * 4;
//    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
//    // 创建context
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
//    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
//    // 遍历像素
//    int pixelNum = imageWidth * imageHeight;
//    uint32_t* pCurPtr = rgbImageBuf;
//    for (int i = 0; i < pixelNum; i++, pCurPtr++){
//        //接近粉色
//        //将像素点转成子节数组来表示---第一个表示透明度即ARGB这种表示方式。ptr[0]:透明度,ptr[1]:R,ptr[2]:G,ptr[3]:B
//        //分别取出RGB值后。进行判断需不需要设成透明。
//        uint8_t* ptr = (uint8_t*)pCurPtr;
//        // NSLog(@"1是%d,2是%d,3是%d",ptr[1],ptr[2],ptr[3]);
//        if(ptr[1] >= 200 || ptr[2] >= 200 || ptr[3] >= 200){
//             ptr[0] = 0;
//        }
//    }
//    // 将内存转成image
//    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, nil);
//    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight,8, 32, bytesPerRow, colorSpace, kCGImageAlphaLast |kCGBitmapByteOrder32Little, dataProvider, NULL, true,kCGRenderingIntentDefault);
//    CGDataProviderRelease(dataProvider);
//    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
//    // 释放
//    CGImageRelease(imageRef);
//    CGContextRelease(context);
//    CGColorSpaceRelease(colorSpace);
//    return resultUIImage;
//}

@end
