//
//  KJEmitterImagePixel.m
//  KJEmitterView
//
//  Created by 杨科军 on 2019/8/27.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "KJEmitterImagePixel.h"

@implementation KJEmitterImagePixel
- (instancetype)init{
    if (self == [super init]) {
        _delayTime = arc4random_uniform(30);
        _delayDuration = arc4random_uniform(10);
    }
    return self;
}

- (UIColor*)color {
    return _pixelColor?:_color;
}

- (void)setRandomPointRange:(CGFloat)randomPointRange {
    _randomPointRange = randomPointRange;
    if (_randomPointRange != 0) {
        _point.x = _point.x - _randomPointRange + arc4random_uniform(_randomPointRange*2);
        _point.y = _point.y - _randomPointRange + arc4random_uniform(_randomPointRange*2);
    }
}

@end
