//
//  KJInteriorFinishTools.h
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/20.
//  Copyright © 2020 杨科军. All rights reserved.
//  装修公共方法类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN
/// 透视选区四点
struct KJKnownPoints {
    CGPoint PointA;
    CGPoint PointB;
    CGPoint PointC;
    CGPoint PointD;
};typedef struct KJKnownPoints KJKnownPoints;

@interface _KJIFinishTools : NSObject


/// 几何方程
static inline CGPoint kj_perpendicularLineDots(CGPoint A,CGPoint B, CGFloat len,BOOL positive);
static inline CGPoint kj_linellaeCrosspoint(CGPoint A,CGPoint B,CGPoint C,CGPoint D);
static inline CGFloat kj_distanceBetweenPoints(CGPoint point1,CGPoint point2);
static inline CGPoint kj_parallelLineDots(CGPoint A,CGPoint B,CGPoint C);
@end

NS_ASSUME_NONNULL_END
