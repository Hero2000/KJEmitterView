//
//  KJSuspendedView.h
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/13.
//  Copyright © 2020 杨科军. All rights reserved.
//  吊顶处理

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/// 已知吊顶的A、B、C、D、E、G六个点
struct KJSuspendedKnownPoints {
    CGPoint PointA;
    CGPoint PointB;
    CGPoint PointC;
    CGPoint PointD;
};typedef struct KJSuspendedKnownPoints KJSuspendedKnownPoints;
/// 所画物体形状
typedef NS_ENUM(NSInteger, KJDarwShapeType) {
    KJDarwShapeTypeQuadrangle, /// 四边形
    KJDarwShapeTypeOval, /// 椭圆
};
@interface KJSuspendedModel : NSObject
/// 每个面对应的透视图
@property(nonatomic,strong) UIImage *topImage;
@property(nonatomic,strong) UIImage *bottomImage;
@property(nonatomic,strong) UIImage *frontImage;
@property(nonatomic,strong) UIImage *backImage;
@property(nonatomic,strong) UIImage *leftImage;
@property(nonatomic,strong) UIImage *rightImage;

/// 每个面对应的透视4点
@property(nonatomic,assign) KJSuspendedKnownPoints topPoints;
@property(nonatomic,assign) KJSuspendedKnownPoints bottomPoints;
@property(nonatomic,assign) KJSuspendedKnownPoints frontPoints;
@property(nonatomic,assign) KJSuspendedKnownPoints backPoints;
@property(nonatomic,assign) KJSuspendedKnownPoints leftPoints;
@property(nonatomic,assign) KJSuspendedKnownPoints rightPoints;
@end

@interface KJSuspendedView : UIView
/// 透视图形回调 - 贴图回调
@property(nonatomic,readwrite,copy) KJSuspendedModel *(^kChartletBlcok)(KJSuspendedModel *model);
/// 所画物体形状，默认四边形
@property(nonatomic,assign) KJDarwShapeType shapeType;
/// 限制下拉最大距离，默认100px
@property(nonatomic,assign) CGFloat maxLen;
/// 所绘虚线颜色，默认黑色
@property(nonatomic,strong) UIColor *dashPatternColor;
/// 所绘虚线宽度，默认1px
@property(nonatomic,assign) CGFloat dashPatternWidth;
/// 初始化
- (instancetype)kj_initWithFrame:(CGRect)frame KnownPoints:(KJSuspendedKnownPoints)points;
/// 重置
- (void)kj_clearLayers;
@end

NS_ASSUME_NONNULL_END
