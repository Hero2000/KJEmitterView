//
//  KJMuralView.h
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/20.
//  Copyright © 2020 杨科军. All rights reserved.
//  壁画相关操作

#import <UIKit/UIKit.h>
#import "_KJIFinishTools.h"
NS_ASSUME_NONNULL_BEGIN

@interface KJMuralView : UIView
/// 透视图形回调 - 贴图回调，透视四点和拼接好的素材图
@property(nonatomic,readwrite,copy) UIImage *(^kChartletBlcok)(KJKnownPoints points,UIImage *muralImage);
/// 壁画，备注此属性必须在 kChartletBlcok 之前设置
@property(nonatomic,strong) UIImage *muralImage;
/// 所绘虚线颜色，默认黑色
@property(nonatomic,strong) UIColor *dashPatternColor;
/// 所绘虚线宽度，默认1px
@property(nonatomic,assign) CGFloat dashPatternWidth;
/// 初始化
- (instancetype)kj_initWithFrame:(CGRect)frame KnownPoints:(KJKnownPoints)points;
/// 重置
- (void)kj_clearLayers;
@end

NS_ASSUME_NONNULL_END
