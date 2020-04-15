//
//  UIView+KJShadow.h
//  KJEmitterView
//
//  Created by 杨科军 on 2020/4/13.
//  Copyright © 2020 杨科军. All rights reserved.
//  阴影相关

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class KJShadowLayer;
@interface UIView (KJShadow)
/* 内阴影的路径 */
@property (nonatomic, strong) UIBezierPath *innerShadowPath;
/* 内阴影的颜色 */
@property (nonatomic, strong) UIColor *innerShadowColor;
/* 内阴影的偏移 */
@property (nonatomic, assign) CGSize innerShadowOffset;
/* 内阴影的阴影半径 */
@property (nonatomic, assign) CGFloat innerShadowRadius;
/* 内阴影的透明度,0为完全透明 */
@property (nonatomic, assign) CGFloat innerShadowOpacity;
/* 内阴影的Layer */
@property (nonatomic, strong) KJShadowLayer *innerShadowLayer;

/* 支持多层内阴影,不执行就不会添加内阴影 */
- (void)addInnerShadow;
/* 清除内阴影,为全部清除,慎用 */
- (void)removeInnerShadow;

@end

NS_ASSUME_NONNULL_END
