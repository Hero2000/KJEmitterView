//
//  UIColor+KJExtension.h
//  KJEmitterView
//
//  Created by 杨科军 on 2019/12/31.
//  Copyright © 2019 杨科军. All rights reserved.
//  颜色相关扩展

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (KJExtension)
/** 竖直渐变颜色
 *  @param color1     开始颜色
 *  @param color2     结束颜色
 *  @param height     渐变高度
 */
+ (UIColor*)kj_gradientFromColor:(UIColor*)color1 toColor:(UIColor*)color2 Height:(NSInteger)height;

/** 横向渐变颜色
 *  @param color1     开始颜色
 *  @param color2     结束颜色
 *  @param width       渐变宽度
 */
+ (UIColor*)kj_gradientFromColor:(UIColor*)color1 toColor:(UIColor*)color2 Width:(NSInteger)width;


@end

NS_ASSUME_NONNULL_END
