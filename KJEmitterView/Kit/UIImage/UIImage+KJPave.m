//
//  UIImage+KJPave.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/4/22.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "UIImage+KJPave.h"
#import <Accelerate/Accelerate.h>

@implementation UIImage (KJPave)

#pragma mark - 图片旋转处理
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

#pragma mark - 对花铺贴效果
/** 对花铺贴效果 */
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

#pragma mark - 地板拼接
/** 地板拼接效果 */
- (UIImage*)kj_imageFloorWithFloorJointType:(KJImageFloorJointType)type TargetImageSize:(KJImageSize)size FloorWidth:(CGFloat)w{
    if (type == KJImageFloorJointTypeClassical) {
        return [self kj_classicalWithTargetImageSize:size FloorWidth:w];
    }
    /// 裁剪小图
    NSArray *temps = [self kj_tailorSixImageWithNum:6];
    NSInteger count = temps.count;
    /// 计算行列
    KJImageRowAndCol rc = [self kj_rowAndColWithTargetImageSize:size FloorJointType:type SmallImage:temps[0] FloorWidth:w];
    CGFloat row = rc.row;
    CGFloat col = rc.col;
    UIImage *shortImage = nil;
    CGFloat x,y;
    CGFloat h1=0,h2=0;
    if (type == KJImageFloorJointTypeCustom) {
        UIImage *img = temps[0];
        h1 = (w*img.size.height)/img.size.width;
    }else if (type == KJImageFloorJointTypeLengthMix || type == KJImageFloorJointTypeAcrossAngle || type == KJImageFloorJointTypeVerticalAngle) {
        shortImage = [UIImage imageNamed:@"timg-2"];
        UIImage *img = temps[0];
        h1 = (w*img.size.height)/img.size.width;
        h2 = h1/2.0;
    }else if (type == KJImageFloorJointTypeThree) { /// 三拼法
        shortImage = [UIImage imageNamed:@"timg-2"];
        UIImage *img = temps[0];
        h1 = (w*img.size.height)/img.size.width;
        h2 = h1/3.0;
    }
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.w, size.h) ,NO, 0.0);
    for (int i=0; i<row; i++) {
        for (int j=0; j<col; j++) {
            int index = arc4random() % count;
            if (type == KJImageFloorJointTypeCustom) {
                x = w * i;
                y = h1 * j;
                [temps[index] drawInRect:CGRectMake(x,y,w,h1)];
                /// 划线
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetRGBStrokeColor(context, 100, 100, 100, 1);//设置画笔颜色
                CGContextSetLineWidth(context, 2.0);//设置画笔线条粗细
                //设置路径
                CGContextMoveToPoint(context, x, y);
                CGContextAddLineToPoint(context, x, y+h1);
                CGContextAddLineToPoint(context, x+w, y+h1);
                CGContextStrokePath(context);/// 渲染
            }else if (type == KJImageFloorJointTypeLengthMix || type == KJImageFloorJointTypeThree) {
                x = w * i;
                if (j%2) {
                    y = (j+1)/2.0*h1 + ((j+1)/2.0-1)*h2;
                    [shortImage drawInRect:CGRectMake(x,y,w,h2)];
                }else{
                    y = (h1+h2)*(j/2.0);
                    [temps[index] drawInRect:CGRectMake(x,y,w,h1)];
                }
            }else if (type == KJImageFloorJointTypeAcrossAngle || type == KJImageFloorJointTypeVerticalAngle) {
                x = w * i;
                if (j%2) {
                    y = (j+1)/2.0*h1 + ((j+1)/2.0-1)*h2;
                    [shortImage drawInRect:CGRectMake(x,y,w,h2)];
                }else{
                    y = (h1+h2)*(j/2.0);
                    [temps[index] drawInRect:CGRectMake(x,y,w,h1)];
                }
                /// 划线
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetRGBStrokeColor(context, 100, 100, 100, 1);//设置画笔颜色
                CGContextSetLineWidth(context, 2.0);//设置画笔线条粗细
                //设置路径
                if (type == KJImageFloorJointTypeAcrossAngle) {
                    CGContextMoveToPoint(context, x, y);
                    CGContextAddLineToPoint(context, x, y+h1);
                }else{
                    CGContextMoveToPoint(context, x, y+h1);
                    CGContextAddLineToPoint(context, x+w, y+h1);
                    CGContextMoveToPoint(context, x, y+h1+h2);
                    CGContextAddLineToPoint(context, x+w, y+h1+h2);
                }
                CGContextStrokePath(context);/// 渲染
            }
        }
    }
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}
/// 裁剪成均匀的num张小图
- (NSArray<UIImage*>*)kj_tailorSixImageWithNum:(NSInteger)num{
    NSMutableArray *temps = [NSMutableArray arrayWithCapacity:num];
    [temps addObject:[UIImage imageNamed:@"1f63e18a364691ce!400x400_big.jpg"]];
    [temps addObject:[UIImage imageNamed:@"9b8f47e254b75b18!400x400_big.jpg"]];
    [temps addObject:[UIImage imageNamed:@"6deabeca656f3d2c!400x400_big.jpg"]];
    [temps addObject:[UIImage imageNamed:@"7bcc1476fae0343e!400x400_big.jpg"]];
    [temps addObject:[UIImage imageNamed:@"abe6ef5c9b55f29e!400x400_big.jpg"]];
    [temps addObject:[UIImage imageNamed:@"0c87de6e044ced2b!400x400_big.jpg"]];
    return temps;
}
struct KJImageRowAndCol {
    int row;
    int col;
};typedef struct KJImageRowAndCol KJImageRowAndCol;
/// 根据拼接效果判断需要几行几列
- (KJImageRowAndCol)kj_rowAndColWithTargetImageSize:(KJImageSize)size FloorJointType:(KJImageFloorJointType)type SmallImage:(UIImage*)sImage FloorWidth:(CGFloat)Fw{
    KJImageRowAndCol rc;
    rc.row = 1; rc.col = 1;
    CGFloat FH = (Fw*sImage.size.height)/sImage.size.width;
    CGFloat xw = size.w / Fw;
    CGFloat rw = roundf(xw);
    rc.row = xw<=rw ? rw : rw+1;
    CGFloat xh = size.h / FH;
    CGFloat rh = roundf(xh);
    int x = xh<=rh ? rh : rh+1; /// 需要的最长尺寸的地板数目
    if (type == KJImageFloorJointTypeCustom) { /// 正常平铺
        rc.col = x;
    }else if (type == KJImageFloorJointTypeLengthMix || type == KJImageFloorJointTypeAcrossAngle || type == KJImageFloorJointTypeVerticalAngle) { /// 长短混合，横倒角，竖倒角
        int m = x - x/3; /// 长地板数目
        rc.col = 2*m+1;
    }else if (type == KJImageFloorJointTypeThree) { /// 三拼法
        int m = x - x/4;
        int n = x - x/4 + 1;
        rc.col = m + n;
    }
    return rc;
}
/// 古典拼接法
- (UIImage*)kj_classicalWithTargetImageSize:(KJImageSize)size FloorWidth:(CGFloat)Fw{
    CGFloat w = size.w, h = size.h; /// 画布尺寸
    UIImage *sImage = [UIImage imageNamed:@"axv"];
    UIImage *sImage3 = [UIImage imageNamed:@"timg-2"];
    NSInteger ratio = 3; /// 宽高比
    CGFloat FH = ratio*Fw;//(Fw*sImage.size.height)/sImage.size.width;
    CGFloat xw = size.w / Fw;
    CGFloat rw = roundf(xw);
    NSInteger row = xw<=rw ? rw : rw+1;
    CGFloat xh = size.h / (FH);
    CGFloat rh = roundf(xh);
    NSInteger col = xh<=rh ? rh : rh+1;
    col = row = MAX(col, row);
    CGFloat x,y;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h) ,NO, 0.0); /// 创建画布尺寸
    for (int j=0; j<col; j++) {
        for (int i=0; i<row; i++) {
            x = Fw * i;
            y = (FH+ratio*Fw)*j+x;
//            if (y-ratio*Fw>h) break; /// 超出画布
            [sImage drawInRect:CGRectMake(x,y,Fw,FH)];
            [sImage3 drawInRect:CGRectMake(x-(ratio-1)*Fw,y-ratio*Fw,FH,Fw)];
//            if (y-ratio*Fw>w) break;
            [sImage drawInRect:CGRectMake(y-(ratio-1)*Fw,x-(ratio-1)*Fw,Fw,FH)];
            [sImage3 drawInRect:CGRectMake(y-ratio*Fw+FH,x-Fw,FH,Fw)];
        }
    }
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

@end
