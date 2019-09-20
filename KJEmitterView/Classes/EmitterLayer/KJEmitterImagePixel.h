//
//  KJEmitterImagePixel.h
//  KJEmitterView
//
//  Created by 杨科军 on 2019/8/27.
//  Copyright © 2019 杨科军. All rights reserved.
//  图片粒子

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJEmitterImagePixel : NSObject
@property(nonatomic, strong)UIColor *color;
@property(nonatomic, strong)UIColor *pixelColor;
@property(nonatomic, assign)CGPoint point;
@property(nonatomic, assign)CGFloat randomPointRange; 
@property(nonatomic, assign)CGFloat delayTime;
@property(nonatomic, assign)CGFloat delayDuration;

@end

NS_ASSUME_NONNULL_END
