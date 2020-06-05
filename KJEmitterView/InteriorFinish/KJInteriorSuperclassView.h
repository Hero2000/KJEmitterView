//
//  KJInteriorSuperclassView.h
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/28.
//  Copyright © 2020 杨科军. All rights reserved.
//  装修父类

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJInteriorSuperclassView : UIView
/// 所绘虚线颜色，默认黑色
@property(nonatomic,strong) UIColor *dashPatternColor;
/// 所绘虚线宽度，默认1px
@property(nonatomic,assign) CGFloat dashPatternWidth;

/// 保存至数据库
- (bool)kj_saveDatasWithTag:(NSInteger)tag;
/// 删除数据
- (bool)kj_delDatasWithTag:(NSInteger)tag;

@end

NS_ASSUME_NONNULL_END
