//
//  KJLegWireLayer.h
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/19.
//  Copyright © 2020 杨科军. All rights reserved.
//  脚线处理

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN
/// 透视选区四点
struct KJLegWireKnownPoints {
    CGPoint PointA;
    CGPoint PointB;
    CGPoint PointC;
    CGPoint PointD;
};typedef struct KJLegWireKnownPoints KJLegWireKnownPoints;

@interface KJLegWireLayer : CALayer
/// 透视图形回调 - 贴图回调，透视四点和拼接好的素材图
@property(nonatomic,readwrite,copy) UIImage *(^kChartletBlcok)(KJLegWireKnownPoints points,UIImage *jointImage);
/// 脚线素材图，备注此属性必须在 kChartletBlcok 之前设置
@property(nonatomic,strong) UIImage *materialImage;
/// 所绘虚线颜色，默认黑色
@property(nonatomic,strong) UIColor *dashPatternColor;
/// 所绘虚线宽度，默认1px
@property(nonatomic,assign) CGFloat dashPatternWidth;
/// 初始化
- (instancetype)kj_initWithFrame:(CGRect)frame KnowPoints:(KJLegWireKnownPoints)points Size:(CGSize)size LegWireHeight:(CGFloat)height;
/// 重置
- (void)kj_clearLayers;

@end

NS_ASSUME_NONNULL_END
