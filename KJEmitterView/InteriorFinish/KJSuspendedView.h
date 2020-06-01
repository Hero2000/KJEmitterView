//
//  KJSuspendedView.h
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/13.
//  Copyright © 2020 杨科军. All rights reserved.
//  吊顶处理

#import <UIKit/UIKit.h>
#import "_KJIFinishTools.h"

NS_ASSUME_NONNULL_BEGIN
/// 所画物体形状
typedef NS_ENUM(NSInteger, KJDarwShapeType) {
    KJDarwShapeTypeQuadrangle, /// 四边形
    KJDarwShapeTypeOval, /// 椭圆
};
/// 凹凸方向
typedef NS_ENUM(NSInteger, KJConcaveConvexType) {
    KJConcaveConvexTypeConcave = 0,/// 向内凹
    KJConcaveConvexTypeConvex, /// 向外凸
};
@interface KJSuspendedModel : NSObject
/// 凹凸方向，内凹不需要管back面，外凸不需要管top面
@property(nonatomic,assign) KJConcaveConvexType concaveType;
/// 每个面对应的透视图
@property(nonatomic,strong) UIImage *topImage;
@property(nonatomic,strong) UIImage *bottomImage;
@property(nonatomic,strong) UIImage *frontImage;
@property(nonatomic,strong) UIImage *backImage;
@property(nonatomic,strong) UIImage *leftImage;
@property(nonatomic,strong) UIImage *rightImage;

/// 每个面对应的透视4点
@property(nonatomic,assign) KJKnownPoints topPoints;
@property(nonatomic,assign) KJKnownPoints bottomPoints;
@property(nonatomic,assign) KJKnownPoints frontPoints;
@property(nonatomic,assign) KJKnownPoints backPoints;
@property(nonatomic,assign) KJKnownPoints leftPoints;
@property(nonatomic,assign) KJKnownPoints rightPoints;

/// 每张图片对应的尺寸
@property(nonatomic,assign) CGRect topRect;
@property(nonatomic,assign) CGRect bottomRect;
@property(nonatomic,assign) CGRect frontRect;
@property(nonatomic,assign) CGRect backRect;
@property(nonatomic,assign) CGRect leftRect;
@property(nonatomic,assign) CGRect rightRect;
@end

@interface KJSuspendedView : UIView
/// 透视图形回调 - 贴图回调
@property(nonatomic,readwrite,copy) KJSuspendedModel *(^kChartletBlcok)(KJSuspendedModel *model);
/// 是否开始贴图，默认NO - 备注：设置这个之前必须先处理贴图回调
@property(nonatomic,assign) bool chartlet;
/// 所画物体形状，默认四边形
@property(nonatomic,assign) KJDarwShapeType shapeType;
/// 限制下拉最大距离，默认100px
@property(nonatomic,assign) CGFloat maxLen;
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
