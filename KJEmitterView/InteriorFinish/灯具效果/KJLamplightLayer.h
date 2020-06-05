//
//  KJLamplightLayer.h
//  KJEmitterView
//
//  Created by 杨科军 on 2020/6/3.
//  Copyright © 2020 杨科军. All rights reserved.
//  灯具效果展示

#import <QuartzCore/QuartzCore.h>
#import "_KJIFinishTools.h"
NS_ASSUME_NONNULL_BEGIN
@interface KJLamplightModel : NSObject
/// 灯光素材
@property(nonatomic,strong) UIImage *lamplightImage;
/// 灯光个数
@property(nonatomic,assign) NSInteger lamplightNumber;
/// 灯光角度，0 - 360°
@property(nonatomic,assign) CGFloat lamplightAngle;
/// 灯光平移Y轴
@property(nonatomic,assign) CGFloat lamplightMoveY;
/// 灯光平移X轴
@property(nonatomic,assign) CGFloat lamplightMoveX;
/// 灯光大小，画布宽度5% - 50%
@property(nonatomic,assign) CGFloat lamplightSize;
/// 灯光间隔，画布宽度5% - 50%
@property(nonatomic,assign) CGFloat lamplightSpace;
@end
@interface KJLamplightLayer : CALayer
/// 改变角度后回调灯光大小处理
@property(nonatomic,readwrite,copy) void (^kAngleChangeSizeBlock)(CGFloat lamplightSize);
/// 画布宽度
@property(nonatomic,assign,readonly) CGFloat canvasWidth;
/// 初始化
- (instancetype)kj_initWithKnownPoints:(KJKnownPoints)points;
/// 重置
- (void)kj_clearLayers;
/// 处理灯光效果
- (UIImage*)kj_addLayerWithLamplightModel:(KJLamplightModel*)lamplightModel PerspectiveBlock:(UIImage *(^)(KJKnownPoints points,UIImage *jointImage))block;

@end

NS_ASSUME_NONNULL_END
