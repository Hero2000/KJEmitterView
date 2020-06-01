//
//  KJFloorJoint.h
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/20.
//  Copyright © 2020 杨科军. All rights reserved.
//  地板拼接效果

#import <Foundation/Foundation.h>
#import "_KJIFinishTools.h"

NS_ASSUME_NONNULL_BEGIN
/// 地板拼接效果
typedef NS_ENUM(NSInteger, KJImageFloorJointType) {
    KJImageFloorJointTypeCustom = 0, /// 默认，正常平铺（艺术拼法）
    KJImageFloorJointTypeDouble,     /// 两拼法
    KJImageFloorJointTypeThree,      /// 三拼法
    KJImageFloorJointTypeLengthMix,  /// 长短混合
    KJImageFloorJointTypeClassical,  /// 古典拼法
    KJImageFloorJointTypeConcaveConvex,  /// 凹凸效果
    KJImageFloorJointTypeLongShortThird, /// 长短三分之一效果
};
@interface KJFloorJoint : NSObject
/// 线条颜色，默认黑色
@property (nonatomic,strong,class) UIColor *lineColor;
/// 线条宽度，默认为FloorWidth的40分之1
@property (nonatomic,assign,class) CGFloat lineWidth;
/// 地板拼接效果
+ (UIImage*)kj_floorJointWithMaterialImage:(UIImage*)xImage Type:(KJImageFloorJointType)type TargetImageSize:(CGSize)size FloorWidth:(CGFloat)w OpenAcross:(BOOL)openAcross OpenVertical:(BOOL)openVertical;

@end

NS_ASSUME_NONNULL_END
