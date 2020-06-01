//
//  KJDecorateBoxView.h
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/28.
//  Copyright © 2020 杨科军. All rights reserved.
//  墙壁装饰盒子 - 壁画、电箱、挂饰

#import <UIKit/UIKit.h>
#import "_KJIFinishTools.h"
#import "KJInteriorSuperclassView.h"
NS_ASSUME_NONNULL_BEGIN

@interface KJDecorateBoxView : KJInteriorSuperclassView
/// 改变大小后回调贴图透视处理
@property(nonatomic,readwrite,copy) UIImage *(^kMovePerspectiveBlock)(KJKnownPoints points,UIImage *materialImage);
/// 是否开启绘制装饰
@property(nonatomic,assign) bool openDrawDecorateBox;
/// 初始化
- (instancetype)kj_initWithFrame:(CGRect)frame KnownPoints:(KJKnownPoints)points;
/// 重置
- (void)kj_clearLayers;
/// 贴图并且固定装饰品
- (bool)kj_chartletAndFixationWithMaterialImage:(UIImage*)materialImage Point:(CGPoint)point PerspectiveBlock:(UIImage *(^)(KJKnownPoints points,UIImage *materialImage))block;
@end

NS_ASSUME_NONNULL_END
