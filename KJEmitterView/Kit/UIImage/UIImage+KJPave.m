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
    /// 裁剪小图
    NSArray *temps = [self kj_tailorImageWithAcross:0 Vertical:2];
    NSInteger count = temps.count;
    NSMutableArray *temps2 = nil;
    /// 计算行列
    KJImageRowAndCol rc = [self kj_rowAndColWithTargetImageSize:size FloorJointType:type SmallImage:temps[0] FloorWidth:w];
    CGFloat x = 0.0,y = 0.0;
    CGFloat h1=0,h2=0;
    int row = rc.row;
    int col = rc.col;
    int ratio = 1; /// 宽高比
    CGFloat line = w/40.; /// 线条宽度
    CGFloat r = 63,g = 58,b = 58,a = 1; /// 线条颜色
    if (type == KJImageFloorJointTypeCustom) { /// 艺术拼法
        UIImage *img = temps[0];
        h1 = (w*img.size.height)/img.size.width;
    }else if (type == KJImageFloorJointTypeDouble || type == KJImageFloorJointTypeAcrossAngle || type == KJImageFloorJointTypeVerticalAngle || type == KJImageFloorJointTypeThree) { /// 两拼法、横倒角、竖倒角、三拼法
        UIImage *img = temps[0];
        h1 = (w*img.size.height)/img.size.width;
    }else if (type == KJImageFloorJointTypeConcaveConvex || type == KJImageFloorJointTypeLongShortThird) { /// 凹凸效果、长短三分之一效果
        UIImage *img = temps[0];
        h1 = (w*img.size.height)/img.size.width;
        NSArray *halfTemp;
        if (type == KJImageFloorJointTypeConcaveConvex) {
            halfTemp = @[@(KJImageAppointTypeTop21),@(KJImageAppointTypeCenter21),@(KJImageAppointTypeBottom21)];
            h2 = h1/2.0;
        }else{
            halfTemp = @[@(KJImageAppointTypeTop31),@(KJImageAppointTypeCenter31),@(KJImageAppointTypeBottom31)];
            h2 = h1/3.0;
        }
        temps2 = [NSMutableArray array];
        for (int i=0; i<temps.count; i++) {
            UIImage *timg = temps[i];
            NSInteger index = arc4random() % halfTemp.count;
            [temps2 addObject:[timg kj_getImageAppointAreaWithImageAppointType:[halfTemp[index] integerValue] CustomFrame:CGRectZero]];
        }
    }else if (type == KJImageFloorJointTypeClassical) { /// 古典拼法
        temps2 = [NSMutableArray array];
        for (int i=0; i<temps.count; i++) {
            UIImage *timg = temps[i];
            [temps2 addObject:[timg kj_rotationImageWithOrientation:(UIImageOrientationRight)]];
        }
        /// 交换行列、宽高、数据源
        UIImage *img = temps[0];
        if (img.size.width > img.size.height) {
            int tem = col;
            col = row;
            row = tem;
            ratio = img.size.width / img.size.height;
            h1 = w;
            w = h1/ratio;
            NSArray *temp = temps2;
            temps2 = [temps mutableCopy];
            temps = temp;
        }else{
            ratio = img.size.height / img.size.width;
            h1 = w * ratio;
        }
    }else if (type == KJImageFloorJointTypeLengthMix) { /// 长短混合
        temps2 = [NSMutableArray arrayWithArray:temps];
        NSArray *appointTemp1 = @[@(KJImageAppointTypeTop43),@(KJImageAppointTypeCenter43),@(KJImageAppointTypeBottom43)];
        NSArray *appointTemp2 = @[@(KJImageAppointTypeTop21),@(KJImageAppointTypeCenter21),@(KJImageAppointTypeBottom21)];
        NSArray *appointTemp3 = @[@(KJImageAppointTypeTop41),@(KJImageAppointTypeCenter41),@(KJImageAppointTypeBottom41)];
        for (int i=0; i<temps.count; i++) {
            UIImage *timg = temps[i];
            /// 取四分之三
            NSInteger index1 = arc4random() % appointTemp1.count;
            [temps2 addObject:[timg kj_getImageAppointAreaWithImageAppointType:[appointTemp1[index1] integerValue] CustomFrame:CGRectZero]];
            /// 取四分之二
            NSInteger index2 = arc4random() % appointTemp2.count;
            [temps2 addObject:[timg kj_getImageAppointAreaWithImageAppointType:[appointTemp2[index2] integerValue] CustomFrame:CGRectZero]];
            /// 取四分之一
            NSInteger index3 = arc4random() % appointTemp3.count;
            [temps2 addObject:[timg kj_getImageAppointAreaWithImageAppointType:[appointTemp3[index3] integerValue] CustomFrame:CGRectZero]];
        }
    }
    /// 设置画布尺寸
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.w, size.h) ,NO, 0.0);
    for (int i=0; i<row; i++) {
        for (int j=0; j<col; j++) {
            if (type == KJImageFloorJointTypeCustom) { // 艺术拼法
                int index = arc4random() % count;
                x = w * i;
                y = h1 * j;
                [temps[index] drawInRect:CGRectMake(x,y,w,h1)];
                /// 划线
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetRGBStrokeColor(context, r/255., g/255., b/255., a);//设置画笔颜色
                CGContextSetLineWidth(context, line);//设置画笔线条粗细
                //设置路径
                CGContextMoveToPoint(context, x, y);
                CGContextAddLineToPoint(context, x, y+h1);
                CGContextAddLineToPoint(context, x+w, y+h1);
                CGContextStrokePath(context);/// 渲染
            }else if (type == KJImageFloorJointTypeClassical) { // 古典拼法
                int index = arc4random() % count;
                x = w * i;
                y = (h1+ratio*w)*j+x;
                [temps[index] drawInRect:CGRectMake(x,y,w,h1)];
                [temps2[index] drawInRect:CGRectMake(x-(ratio-1)*w,y-ratio*w,h1,w)];
                [temps[index] drawInRect:CGRectMake(y-(ratio-1)*w,x-(ratio-1)*w,w,h1)];
                [temps2[index] drawInRect:CGRectMake(y-ratio*w+h1,x-w,h1,w)];
            }else if (type == KJImageFloorJointTypeDouble || type == KJImageFloorJointTypeAcrossAngle || type == KJImageFloorJointTypeVerticalAngle || type == KJImageFloorJointTypeThree) { // 两拼法、横倒角、竖倒角、三拼法
                int index = arc4random() % count;
                x = w * i;
                y = h1 * j;
                if (i%2) {
                    if (type == KJImageFloorJointTypeThree) {
                        y = y - h1/3;
                    }else{
                        y = y - h1/2;
                    }
                    if (j==col-1) [temps[index] drawInRect:CGRectMake(x,y+h1,w,h1)];
                }
                [temps[index] drawInRect:CGRectMake(x,y,w,h1)];
                /// 划线
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetRGBStrokeColor(context, r/255., g/255., b/255., a);//设置画笔颜色
                CGContextSetLineWidth(context, line);//设置画笔线条粗细
                if (type == KJImageFloorJointTypeDouble||type == KJImageFloorJointTypeThree) {
                    CGContextMoveToPoint(context, x, y);
                    CGContextAddLineToPoint(context, x, y+h1);
                    CGContextAddLineToPoint(context, x+w, y+h1);
                }else if (type == KJImageFloorJointTypeAcrossAngle) {
                    CGContextMoveToPoint(context, x, y);
                    CGContextAddLineToPoint(context, x, y+h1);
                }else{
                    CGContextMoveToPoint(context, x, y);
                    CGContextAddLineToPoint(context, x+w, y);
                }
                CGContextStrokePath(context);/// 渲染
            }else if (type == KJImageFloorJointTypeConcaveConvex || type == KJImageFloorJointTypeLongShortThird) { // 凹凸效果、 长短三分之一效果
                int index = arc4random() % count;
                x = w * i;
                if (j%2) {
                    y = (j+1)/2.0*h1 + ((j+1)/2.0-1)*h2;
                    [temps2[index] drawInRect:CGRectMake(x,y,w,h2)];
                }else{
                    y = (h1+h2)*(j/2.0);
                    [temps[index] drawInRect:CGRectMake(x,y,w,h1)];
                }
            }else if (type == KJImageFloorJointTypeLengthMix) { /// 长短混合
                NSInteger mixIndex = arc4random() % temps2.count;
                UIImage *mixImg = temps2[mixIndex];
                x = w * i;
                y = j==0 ? 0.0 : y; /// 重置坐标
                h1 = (w*mixImg.size.height)/mixImg.size.width;
                [mixImg drawInRect:CGRectMake(x,y,w,h1)];
                /// 划线
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetRGBStrokeColor(context, r/255., g/255., b/255., a);//设置画笔颜色
                CGContextSetLineWidth(context, line);//设置画笔线条粗细
                //设置路径
                CGContextMoveToPoint(context, x, y);
                CGContextAddLineToPoint(context, x, y+h1);
                CGContextAddLineToPoint(context, x+w, y+h1);
                CGContextStrokePath(context);/// 渲染
                y += h1;
            }
        }
    }
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}
/// 横向和纵向裁剪图片，然后再旋转180
- (NSArray<UIImage*>*)kj_tailorImageWithAcross:(int)across Vertical:(int)vertical{
    NSMutableArray<UIImage*>*temps = [NSMutableArray array];
    CGFloat w = self.size.width;
    CGFloat h = self.size.height;
    NSMutableArray *rectTemps = [NSMutableArray array];
    for (int i=0; i<across+1; i++) {
        for (int j=0; j<vertical+1; j++) {
            CGFloat xw = w/(across+1.0);
            CGFloat xh = h/(vertical+1.0);
            [rectTemps addObject:[NSValue valueWithCGRect:CGRectMake(xw*i, xh*j, xw, xh)]];
        }
    }
    CGImageRef imageRef = NULL;
    for (int i=0; i<(across+1)*(vertical+1); i++) {
        CGRect rect = [[rectTemps objectAtIndex:i] CGRectValue];
        imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
        UIImage *img = [UIImage imageWithCGImage:imageRef];
        [temps addObject:img];
        UIImage *img2 = [img kj_rotationImageWithOrientation:(UIImageOrientationDown)];/// 图片旋转180°
        [temps addObject:img2];
    }
    CGImageRelease(imageRef);
    return temps;
}
/// 根据拼接效果判断需要几行几列
struct KJImageRowAndCol { int row; int col;};
typedef struct KJImageRowAndCol KJImageRowAndCol;
- (KJImageRowAndCol)kj_rowAndColWithTargetImageSize:(KJImageSize)size FloorJointType:(KJImageFloorJointType)type SmallImage:(UIImage*)img FloorWidth:(CGFloat)w{
    KJImageRowAndCol rc;
    rc.row = 1; rc.col = 1;
    CGFloat FH = (w*img.size.height)/img.size.width;
    CGFloat xw = size.w / w;
    CGFloat rw = roundf(xw);
    rc.row = xw<=rw ? rw : rw+1;
    CGFloat xh = size.h / FH;
    CGFloat rh = roundf(xh);
    int x = xh<=rh ? rh : rh+1; /// 需要的最长尺寸的地板数目
    switch (type) {
        case KJImageFloorJointTypeCustom: /// 正常平铺
        case KJImageFloorJointTypeClassical: /// 古典拼法
            rc.col = x;
            break;
        case KJImageFloorJointTypeDouble: /// 两拼法
        case KJImageFloorJointTypeAcrossAngle: /// 横倒角
        case KJImageFloorJointTypeVerticalAngle: /// 竖倒角
        case KJImageFloorJointTypeThree: /// 三拼法
            rc.col = x+1;
            break;
        case KJImageFloorJointTypeConcaveConvex:/// 凹凸效果
            rc.col = (x-x/3)+(x-x/3+1);
            break;
        case KJImageFloorJointTypeLongShortThird:/// 长短三分之一效果
            rc.col = (x-x/4)+(x-x/4+1);
            break;
        case KJImageFloorJointTypeLengthMix: /// 长短混合
            rc.col = (int)(size.h/(FH/4.))+1;
            break;
    }
    return rc;
}

/** 获取图片指定区域 */
- (UIImage*)kj_getImageAppointAreaWithImageAppointType:(KJImageAppointType)type CustomFrame:(CGRect)rect{
    CGFloat w = self.size.width;
    CGFloat h = self.size.height;
    switch (type) {
        case KJImageAppointTypeCustom:
            break;
        case KJImageAppointTypeTop21:
            rect = CGRectMake(0, 0, w, h/2.);
            break;
        case KJImageAppointTypeCenter21:
            rect = CGRectMake(0, h/4., w, h/2.);
            break;
        case KJImageAppointTypeBottom21:
            rect = CGRectMake(0, h/2., w, h/2.);
            break;
        case KJImageAppointTypeTop31:
            rect = CGRectMake(0, 0, w, h/3.);
            break;
        case KJImageAppointTypeCenter31:
            rect = CGRectMake(0, h/3., w, h/3.);
            break;
        case KJImageAppointTypeBottom31:
            rect = CGRectMake(0, h/3.*2, w, h/3.);
            break;
        case KJImageAppointTypeTop41:
            rect = CGRectMake(0, 0, w, h/4.);
            break;
        case KJImageAppointTypeCenter41:
            rect = CGRectMake(0, h/4., w, h/4.);
            break;
        case KJImageAppointTypeBottom41:
            rect = CGRectMake(0, h/4.*2, w, h/4.);
            break;
        case KJImageAppointTypeTop43:
            rect = CGRectMake(0, 0, w, h/4.*3);
            break;
        case KJImageAppointTypeCenter43:
            rect = CGRectMake(0, h/8., w, h/4.*3);
            break;
        case KJImageAppointTypeBottom43:
            rect = CGRectMake(0, h/4., w, h/4.*3);
            break;
        default:
            rect = CGRectMake(0, 0, w, h);
            break;
    }
    /// 获取裁剪图片区域
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return img;
}

@end
