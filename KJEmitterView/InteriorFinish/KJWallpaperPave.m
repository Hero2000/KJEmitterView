//
//  KJWallpaperPave.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/20.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJWallpaperPave.h"

@implementation KJWallpaperPave
#pragma mark - 墙纸铺贴效果
+ (UIImage*)kj_wallpaperPaveWithMaterialImage:(UIImage*)xImage TiledType:(KJImageTiledType)type TargetImageSize:(CGSize)size Width:(CGFloat)w{
    CGFloat FH = (w*xImage.size.height)/xImage.size.width;
    CGFloat xw = size.width / w;
    CGFloat rw = roundf(xw);
    int row = xw<=rw ? rw : rw+1;
    CGFloat xh = size.height / FH;
    CGFloat rh = roundf(xh);
    int col = xh<=rh ? rh : rh+1;
    
    UIImage *image = nil;
    if (type == KJImageTiledTypeAcross) {
        image = [_KJIFinishTools kj_rotationImageWithImage:xImage Orientation:UIImageOrientationUpMirrored];
    }else if (type == KJImageTiledTypeVertical) {
        image = [_KJIFinishTools kj_rotationImageWithImage:xImage Orientation:UIImageOrientationDownMirrored];
    }
    UIGraphicsBeginImageContextWithOptions(size ,NO, 0.0);
    CGFloat x,y;
//    CGFloat w = size.w / row;
    CGFloat h = FH;//size.h / col;
    for (int i=0; i<row; i++) {
        for (int j=0; j<col; j++) {
            x = w * i;
            y = h * j;
            if (type == KJImageTiledTypeCustom) {
                [xImage drawInRect:CGRectMake(x,y,w,h)];
            }else if (type == KJImageTiledTypeAcross) {
                if (i%2) {
                    [image drawInRect:CGRectMake(x,y,w,h)];
                }else{
                    [xImage drawInRect:CGRectMake(x,y,w,h)];
                }
            }else if (type == KJImageTiledTypeVertical) {
                if (j%2) {
                    [image drawInRect:CGRectMake(x,y,w,h)];
                }else{
                    [xImage drawInRect:CGRectMake(x,y,w,h)];
                }
            }else if (type == KJImageTiledTypePositively || type == KJImageTiledTypeBackslash) {
                bool boo = type == KJImageTiledTypePositively ? i%2 : !(i%2);
                if (boo) {
                    y = y - h/2;
                    if (j==col-1) [xImage drawInRect:CGRectMake(x,y+h,w,h)];
                }
                [xImage drawInRect:CGRectMake(x,y,w,h)];
            }
        }
    }
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}
/** 对花铺贴效果 */
+ (UIImage*)kj_wallpaperPaveWithMaterialImage:(UIImage*)xImage TiledType:(KJImageTiledType)type TargetImageSize:(CGSize)size Row:(NSInteger)row Col:(NSInteger)col{
    /// 旋转处理之后的图片
//    UIImage *image = [self kj_rotateInRadians:-M_PI*180./180];
    UIImage *image = nil;
    if (type == KJImageTiledTypeAcross) {
        image = [_KJIFinishTools kj_rotationImageWithImage:xImage Orientation:UIImageOrientationUpMirrored];
    }else if (type == KJImageTiledTypeVertical) {
        image = [_KJIFinishTools kj_rotationImageWithImage:xImage Orientation:UIImageOrientationDownMirrored];
    }
    CGSize siz = CGSizeMake(size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(siz ,NO, 0.0);
    CGFloat x,y;
    CGFloat w = size.width / row;
    CGFloat h = size.height / col;
    for (int i=0; i<row; i++) {
        for (int j=0; j<col; j++) {
            x = w * i;
            y = h * j;
            if (type == KJImageTiledTypeCustom) {
                [xImage drawInRect:CGRectMake(x,y,w,h)];
            }else if (type == KJImageTiledTypeAcross) {
                if (i%2) {
                    [image drawInRect:CGRectMake(x,y,w,h)];
                }else{
                    [xImage drawInRect:CGRectMake(x,y,w,h)];
                }
            }else if (type == KJImageTiledTypeVertical) {
                if (j%2) {
                    [image drawInRect:CGRectMake(x,y,w,h)];
                }else{
                    [xImage drawInRect:CGRectMake(x,y,w,h)];
                }
            }else if (type == KJImageTiledTypePositively || type == KJImageTiledTypeBackslash) {
                bool boo = type == KJImageTiledTypePositively ? i%2 : !(i%2);
                if (boo) {
                    y = y - h/2;
                    if (j==col-1) [xImage drawInRect:CGRectMake(x,y+h,w,h)];
                }
                [xImage drawInRect:CGRectMake(x,y,w,h)];
            }
        }
    }
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

@end
