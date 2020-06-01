//
//  KJMuralView.h
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/20.
//  Copyright © 2020 杨科军. All rights reserved.
//  壁画相关操作

#import <UIKit/UIKit.h>
#import "_KJIFinishTools.h"
#import "KJInteriorSuperclassView.h"
NS_ASSUME_NONNULL_BEGIN

@interface KJMuralView : KJInteriorSuperclassView
/// 透视图形回调 - 贴图回调，透视四点和拼接好的素材图
@property(nonatomic,readwrite,copy) UIImage *(^kChartletBlcok)(KJKnownPoints points,UIImage *muralImage);
/// 壁画，备注此属性必须在 kChartletBlcok 之前设置
@property(nonatomic,strong) UIImage *muralImage;
/// 是否开启绘制壁画
@property(nonatomic,assign) bool openDrawMural;
/// 初始化
- (instancetype)kj_initWithFrame:(CGRect)frame KnownPoints:(KJKnownPoints)points;
/// 重置
- (void)kj_clearLayers;
@end

NS_ASSUME_NONNULL_END
