//
//  KJSkirtingLineView.h
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/27.
//  Copyright © 2020 杨科军. All rights reserved.
//  四边踢脚线处理 - 四周边线

#import <UIKit/UIKit.h>
#import "_KJIFinishTools.h"
#import "KJInteriorSuperclassView.h"
NS_ASSUME_NONNULL_BEGIN
/// 踢脚线位置
typedef NS_ENUM(NSInteger, KJSkirtingLineType) {
    KJSkirtingLineTypeTop    = 1 << 0,/// 上边
    KJSkirtingLineTypeBottom = 1 << 1,/// 下边
    KJSkirtingLineTypeLeft   = 1 << 2,/// 左边
    KJSkirtingLineTypeRight  = 1 << 3,/// 右边
};
@interface KJSkirtingLineView : KJInteriorSuperclassView
/// 拖动时刻回调贴图透视处理
@property(nonatomic,readwrite,copy) UIImage *(^kMovePerspectiveBlock)(KJKnownPoints points,UIImage *jointImage);
/// 初始化
- (instancetype)kj_initWithFrame:(CGRect)frame KnownPoints:(KJKnownPoints)points LegWireType:(KJSkirtingLineType)type;
/// 重置
- (void)kj_clearLayers;
/// 根据当前坐标修改指定区域素材图，返回是否贴图成功
- (bool)kj_changeMaterialImage:(UIImage*)materialImage Point:(CGPoint)point PerspectiveBlock:(UIImage *(^)(KJKnownPoints points,UIImage *jointImage))block;
@end

NS_ASSUME_NONNULL_END
