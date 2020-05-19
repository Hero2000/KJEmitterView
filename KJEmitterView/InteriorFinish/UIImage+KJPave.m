//
//  UIImage+KJPave.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/4/22.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "UIImage+KJPave.h"
#import <objc/runtime.h>
#import <Accelerate/Accelerate.h>

@implementation UIImage (KJPave)
/** 旋转图片和镜像处理 orientation 图片旋转方向 */
- (UIImage*)kj_rotationImageWithOrientation:(UIImageOrientation)orientation{
    CGRect rect = CGRectZero;
    rect.size.width  = CGImageGetWidth(self.CGImage);
    rect.size.height = CGImageGetHeight(self.CGImage);
    CGRect bounds = rect;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (orientation){
        case UIImageOrientationUp:
            break;
        case UIImageOrientationUpMirrored:
            transform = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown:
            transform = CGAffineTransformMakeTranslation(rect.size.width,rect.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformMakeTranslation(0.0, rect.size.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeft:
            bounds = kj_swapWidthAndHeight(bounds);
            transform = CGAffineTransformMakeTranslation(0.0, rect.size.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeftMirrored:
            bounds = kj_swapWidthAndHeight(bounds);
            transform = CGAffineTransformMakeTranslation(rect.size.height,rect.size.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRight:
            bounds = kj_swapWidthAndHeight(bounds);
            transform = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored:
            bounds = kj_swapWidthAndHeight(bounds);
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
    }
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (orientation){
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        CGContextScaleCTM(context, -1.0, 1.0);
        CGContextTranslateCTM(context, -rect.size.height, 0.0);
        break;
        default:
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextTranslateCTM(context, 0.0, -rect.size.height);
        break;
    }

    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, self.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}
static inline CGRect kj_swapWidthAndHeight(CGRect rect){
    CGFloat swap = rect.size.width;
    rect.size.width  = rect.size.height;
    rect.size.height = swap;
    return rect;
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
    /// 获取裁剪图片区域 - 从原图片中取小图
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return img;
}

#pragma mark - 墙纸铺贴效果
- (UIImage*)kj_imageTiledWithTiledType:(KJImageTiledType)type TargetImageSize:(CGSize)size Width:(CGFloat)w{
    CGFloat FH = (w*self.size.height)/self.size.width;
    CGFloat xw = size.width / w;
    CGFloat rw = roundf(xw);
    int row = xw<=rw ? rw : rw+1;
    CGFloat xh = size.height / FH;
    CGFloat rh = roundf(xh);
    int col = xh<=rh ? rh : rh+1;
    
    UIImage *image = nil;
    if (type == KJImageTiledTypeAcross) {
        image = [self kj_rotationImageWithOrientation:(UIImageOrientationUpMirrored)];
    }else if (type == KJImageTiledTypeVertical) {
        image = [self kj_rotationImageWithOrientation:(UIImageOrientationDownMirrored)];
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
/** 对花铺贴效果 */
- (UIImage*)kj_imageTiledWithTiledType:(KJImageTiledType)type TargetImageSize:(CGSize)size Row:(NSInteger)row Col:(NSInteger)col{
    /// 旋转处理之后的图片
//    UIImage *image = [self kj_rotateInRadians:-M_PI*180./180];
    UIImage *image = nil;
    if (type == KJImageTiledTypeAcross) {
        image = [self kj_rotationImageWithOrientation:(UIImageOrientationUpMirrored)];
    }else if (type == KJImageTiledTypeVertical) {
        image = [self kj_rotationImageWithOrientation:(UIImageOrientationDownMirrored)];
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
- (UIImage*)kj_imageFloorWithFloorJointType:(KJImageFloorJointType)type TargetImageSize:(CGSize)size FloorWidth:(CGFloat)w OpenAcross:(BOOL)openAcross OpenVertical:(BOOL)openVertical{
    /// 裁剪小图
    NSArray *temps = [self kj_tailorImageWithAcross:0 Vertical:2];
    NSInteger count = temps.count;
    NSMutableArray *temps2 = nil;
    /// 计算行列
    KJImageRowAndCol rc = [self kj_rowAndColWithTargetImageSize:size FloorJointType:type SmallImage:temps[0] FloorWidth:w];
    CGFloat x = 0.0,y = 0.0;
    CGFloat h1= 0.0,h2= 0.0;
    int row = rc.row;
    int col = rc.col;
    int ratio = 1; /// 宽高比
    if (type == KJImageFloorJointTypeCustom) { /// 艺术拼法
        UIImage *img = temps[0];
        h1 = (w*img.size.height)/img.size.width;
    }else if (type == KJImageFloorJointTypeDouble || type == KJImageFloorJointTypeThree) { /// 两拼法、三拼法
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
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height) ,NO, 0.0);
    for (int i=0; i<row; i++) {
        for (int j=0; j<col; j++) {
            switch (type) {
                case KJImageFloorJointTypeCustom:// 艺术拼法
                    x = w * i;y = h1 * j;
                    [temps[arc4random()%count] drawInRect:CGRectMake(x,y,w,h1)];
                    [self kj_drawLineWithType:type Across:openAcross Vertical:openVertical X:x Y:y W:w H:h1 Ratio:ratio];
                    break;
                case KJImageFloorJointTypeDouble:// 两拼法
                case KJImageFloorJointTypeThree:{//三拼法
                    int index = arc4random() % count;
                    x = w * i;y = h1 * j;
                    if (i%2) {
                        y = type == KJImageFloorJointTypeThree ? y - h1/3 : y - h1/2;
                        if (j==col-1) [temps[index] drawInRect:CGRectMake(x,y+h1,w,h1)];
                    }
                    [temps[index] drawInRect:CGRectMake(x,y,w,h1)];
                    [self kj_drawLineWithType:type Across:openAcross Vertical:openVertical X:x Y:y W:w H:h1 Ratio:ratio];
                }
                    break;
                case KJImageFloorJointTypeConcaveConvex: // 凹凸效果
                case KJImageFloorJointTypeLongShortThird:{ // 长短三分之一效果
                    int index = arc4random() % count;
                    x = w * i;
                    if (j%2) {
                        y = (j+1)/2.0*h1 + ((j+1)/2.0-1)*h2;
                        [temps2[index] drawInRect:CGRectMake(x,y,w,h2)];
                        [self kj_drawLineWithType:type Across:openAcross Vertical:openVertical X:x Y:y W:w H:h2 Ratio:ratio];
                    }else{
                        y = (h1+h2)*(j/2.0);
                        [temps[index] drawInRect:CGRectMake(x,y,w,h1)];
                        [self kj_drawLineWithType:type Across:openAcross Vertical:openVertical X:x Y:y W:w H:h1 Ratio:ratio];
                    }
                }
                    break;
                case KJImageFloorJointTypeLengthMix:{ // 长短混合
                    int mixIndex = arc4random() % temps2.count;
                    UIImage *mixImg = temps2[mixIndex];
                    x = w * i;y = j==0 ? 0.0 : y; /// 重置坐标
                    h1 = (w*mixImg.size.height)/mixImg.size.width;
                    [mixImg drawInRect:CGRectMake(x,y,w,h1)];
                    [self kj_drawLineWithType:type Across:openAcross Vertical:openVertical X:x Y:y W:w H:h1 Ratio:ratio];
                    y += h1; /// 最后坐标递加
                }
                    break;
                case KJImageFloorJointTypeClassical:{ // 古典拼法
                    int index = arc4random() % count;
                    x = w * i;y = (h1+ratio*w)*j+x;
                    [temps[index]  drawInRect:CGRectMake(x,y,w,h1)];
                    [temps2[index] drawInRect:CGRectMake(x-(ratio-1)*w,y-ratio*w,h1,w)];
                    [temps[index]  drawInRect:CGRectMake(y-(ratio-1)*w,x-(ratio-1)*w,w,h1)];
                    [temps2[index] drawInRect:CGRectMake(y-ratio*w+h1,x-w,h1,w)];
                }
                    break;
                default:
                    break;
            }
        }
    }
    /// 古典单独处理 - 经多次测试，需要先画图再划线
    if (type == KJImageFloorJointTypeClassical) {
        for (int i=0; i<row; i++) {
            for (int j=0; j<col; j++) {
                x = w * i;y = (h1+ratio*w)*j+x;
                [self kj_drawLineWithType:type Across:openAcross Vertical:openVertical X:x Y:y W:w H:h1 Ratio:ratio];
            }
        }
    }
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}
/// 横竖倒角处理 0：无横倒角也无竖倒角 1：有横倒角无竖倒角 2：无横倒角有竖倒角 3：有横倒角也有竖倒角
static int AcrossAndVertical(bool a,bool v){
    if (a&v) return 3;
    if (!(a|v)) return 0;
    if (a) return 1;
    if (v) return 2;
    return 0;
}
/// 划线
- (void)kj_drawLineWithType:(KJImageFloorJointType)type Across:(BOOL)across Vertical:(BOOL)vertical X:(CGFloat)x Y:(CGFloat)y W:(CGFloat)w H:(CGFloat)h Ratio:(CGFloat)r{
    int boo = AcrossAndVertical(across, vertical);
    if (boo == 0) return; /// 不需要划线
    CGFloat l = w/40.; /// 线条宽度
    // 古典拼法划线单独处理
    if (type == KJImageFloorJointTypeClassical) {
        CGFloat x1 = x, y1 = y;/// 左下竖直
        CGFloat x2 = x-(r-1)*w, y2 = y-r*w;/// 左下横向
        CGFloat x3 = y-(r-1)*w, y3 = x-(r-1)*w;/// 右上竖直
        CGFloat x4 = y-r*w+h, y4 = x-w;/// 右上横向
        if (boo == 1) {
            [self kj_drawLineWithLineType:0 Line:l A:x1 B:y1-l*.5 C:x1 + w D:0.0];
            [self kj_drawLineWithLineType:0 Line:l A:x2 B:y2-l*.5 C:x2 + h D:1.0];
            [self kj_drawLineWithLineType:0 Line:l A:x3 B:y3-l*.5 C:x3 + w D:2.0];
            [self kj_drawLineWithLineType:0 Line:l A:x4 B:y4-l*.5 C:x4 + h D:3.0];
        }else if (boo == 2) {
            [self kj_drawLineWithLineType:1 Line:l A:x1-l*.5 B:y1 C:y1 + h D:0.0];
            [self kj_drawLineWithLineType:1 Line:l A:x2-l*.5 B:y2 C:y2 + w D:1.0];
            [self kj_drawLineWithLineType:1 Line:l A:x3-l*.5 B:y3 C:y3 + h D:2.0];
            [self kj_drawLineWithLineType:1 Line:l A:x4-l*.5 B:y4 C:y4 + w D:3.0];
        }else if (boo == 3) {
            [self kj_drawLineWithLineType:2 Line:l A:x1-l*.5 B:y1-l*.5 C:x1-l*.5 + w D:y1-l*.5 + h];
            [self kj_drawLineWithLineType:3 Line:l A:x2-l*.5 B:y2-l*.5 C:x2-l*.5 + h D:y2-l*.5 + w];
            [self kj_drawLineWithLineType:4 Line:l A:x3-l*.5 B:y3-l*.5 C:x3-l*.5 + w D:y3-l*.5 + h];
            [self kj_drawLineWithLineType:5 Line:l A:x4-l*.5 B:y4-l*.5 C:x4-l*.5 + h D:y4-l*.5 + w];
        }
        return;
    }
    if (boo == 1) {
        [self kj_drawLineWithLineType:0 Line:l A:x B:y C:x+w D:0.0];
    }else if (boo == 2) {
        [self kj_drawLineWithLineType:1 Line:l A:x B:y C:y+h D:0.0];
    }else if (boo == 3) {
        [self kj_drawLineWithLineType:2 Line:l A:x B:y C:x+w D:y+h-l*.5];
    }
}
/// lineType线条类型 0：横向 1：竖向 2：横向和竖向
- (void)kj_drawLineWithLineType:(NSInteger)lineType Line:(CGFloat)line A:(CGFloat)a B:(CGFloat)b C:(CGFloat)c D:(CGFloat)d{
    CGFloat red = 63,green = 58,blue = 58,alpe = 1; /// 线条颜色
//    if (lineType==3 || d==0) { // 蓝色
//        red = 3;green = 38;blue = 254;
//    }else if (lineType==3 || d==1) {// 绿色
//        red = 3;green = 254;blue = 56;
//    }else if (lineType==4 || d==2) {// 黄色
//        red = 239;green = 254;blue = 3;
//    }else if (lineType==5 || d==3) {// 红色
//        red = 255;green = 3;blue = 6;
//    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, red/255., green/255., blue/255., alpe);
    CGContextSetLineWidth(context, line);
    if (lineType == 0) { /// 横向
        CGContextMoveToPoint(context, a, b);
        CGContextAddLineToPoint(context, c, b);
    }else if (lineType == 1) { /// 竖向
        CGContextMoveToPoint(context, a, b);
        CGContextAddLineToPoint(context, a, c);
    }else if (lineType >= 2) { /// 横向和竖向
        CGContextMoveToPoint(context, a, b);
        CGContextAddLineToPoint(context, a, d);
        CGContextAddLineToPoint(context, c, d);
    }
    CGContextStrokePath(context);
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
struct KJImageRowAndCol {int row; int col;};
typedef struct KJImageRowAndCol KJImageRowAndCol;
- (KJImageRowAndCol)kj_rowAndColWithTargetImageSize:(CGSize)size FloorJointType:(KJImageFloorJointType)type SmallImage:(UIImage*)img FloorWidth:(CGFloat)w{
    KJImageRowAndCol rc;
    rc.row = 1; rc.col = 1;
    CGFloat FH = (w*img.size.height)/img.size.width;
    CGFloat xw = size.width / w;
    CGFloat rw = roundf(xw);
    rc.row = xw<=rw ? rw : rw+1;
    CGFloat xh = size.height / FH;
    CGFloat rh = roundf(xh);
    int x = xh<=rh ? rh : rh+1; /// 需要的最长尺寸的地板数目
    switch (type) {
        case KJImageFloorJointTypeCustom: /// 正常平铺
        case KJImageFloorJointTypeClassical: /// 古典拼法
            rc.col = x;
            break;
        case KJImageFloorJointTypeDouble: /// 两拼法
        case KJImageFloorJointTypeThree:  /// 三拼法
            rc.col = x+1;
            break;
        case KJImageFloorJointTypeConcaveConvex:/// 凹凸效果（长短二分之一效果）
            rc.col = (x-x/3)+(x-x/3+1);
            break;
        case KJImageFloorJointTypeLongShortThird:/// 长短三分之一效果
            rc.col = (x-x/4)+(x-x/4+1);
            break;
        case KJImageFloorJointTypeLengthMix: /// 长短混合
            rc.col = (int)(size.height/(FH/4.))+1;
            break;
    }
    return rc;
}

@end
