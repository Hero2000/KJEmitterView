//
//  KJEmitterLayer.h
//  KJEmitterView
//
//  Created by 杨科军 on 2019/8/27.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJEmitterLayer : CALayer
// 初始化
+ (instancetype)createEmitterLayerWithImage:(UIImage*)image WaitTime:(CGFloat)waitTime Block:(void(^)(KJEmitterLayer *obj))block;
/// 绘制完成之后的回调
@property(nonatomic,strong) void(^KJEmitterLayerDrawCompleteBlock)(void);
/// 重置
//- (void)restart;

/*****设置一些相关的数据*****/
@property(nonatomic,strong,readonly) KJEmitterLayer *(^KJIgnored)(BOOL ignoredBlack,BOOL ignoredWhite);
/// pixelColor:粒子颜色 pixelMaximum:粒子最大数目 pixelBeginPoint:粒子出生位置 pixelRandomPointRange:像素粒子随机范围
@property(nonatomic,strong,readonly) KJEmitterLayer *(^KJPixel)(UIColor *pixelColor,NSInteger pixelMaximum,CGPoint pixelBeginPoint,CGFloat pixelRandomPointRange);
@end

NS_ASSUME_NONNULL_END
