//
//  KJSuspendedVC.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/11.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJSuspendedVC.h"
//#import "NSObject+KJGeometry.h"
#import "KJSuspendedView.h"

@interface KJSuspendedVC ()
@property(nonatomic,strong) CAShapeLayer *redLayer; /// 红色透视选区
@end

@implementation KJSuspendedVC
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGFloat w = self.view.size.width;
    CGFloat h = self.view.size.height;
    KJKnownPoint points = {
        CGPointMake(20+64, 20),
        CGPointMake(100+64, w/2-30),
        CGPointMake(h-150, w/2-20),
        CGPointMake(h-20, 40),
//        CGPointMake(100+64, 20),
//        CGPointMake(20+64, w/2-30),
//        CGPointMake(h-20, w/2-20),
//        CGPointMake(h-150, 40),
    };
    
    UIView *aView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, h, w)];
    [self.view addSubview:aView];
    aView.center = self.view.center;
    aView.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    [aView.layer addSublayer:self.redLayer];
    self.redLayer.path = ({
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:points.PointA];
        [path addLineToPoint:points.PointB];
        [path addLineToPoint:points.PointC];
        [path addLineToPoint:points.PointD];
        [path closePath]; /// 闭合路径
        path.CGPath;
    });
    
    __block KJSuspendedView *suspendedView = [[KJSuspendedView alloc]kj_initWithFrame:CGRectMake(0, 0, h, w) KnownPoints:points];
    suspendedView.dashPatternColor = UIColor.whiteColor;
    suspendedView.dashPatternWidth = 2;
    suspendedView.center = self.view.center;
    suspendedView.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0];
    suspendedView.transform = CGAffineTransformMakeRotation(M_PI_2);
    [self.view addSubview:suspendedView];
    suspendedView.kChartletBlcok = ^KJSuspendedModel * _Nonnull(KJSuspendedModel * _Nonnull model) {
        return model;
    };
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(100, suspendedView.frame.size.height-50, 100, 50)];
    label.transform = CGAffineTransformMakeRotation(M_PI_2);
    label.center = CGPointMake(25, 64+50+25);
    label.backgroundColor = UIColor.redColor;
    label.text = @"清除";
    label.textColor = UIColor.whiteColor;
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    [label kj_AddTapGestureRecognizerBlock:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        [suspendedView kj_clearLayers];
    }];
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(250, suspendedView.frame.size.height-50, 100, 50)];
    label2.backgroundColor = UIColor.greenColor;
    label2.transform = CGAffineTransformMakeRotation(M_PI_2);
    label2.center = CGPointMake(25, 64+50+25+150);
    label2.text = @"四边形";
    label2.textColor = UIColor.whiteColor;
    label2.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label2];
    [label2 kj_AddTapGestureRecognizerBlock:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        [suspendedView kj_clearLayers];
        suspendedView.shapeType = KJDarwShapeTypeQuadrangle;
    }];
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(400, suspendedView.frame.size.height-50, 100, 50)];
    label3.backgroundColor = UIColor.blueColor;
    label3.transform = CGAffineTransformMakeRotation(M_PI_2);
    label3.center = CGPointMake(25, 64+50+25+150+150);
    label3.text = @"椭圆";
    label3.textColor = UIColor.whiteColor;
    label3.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label3];
    [label3 kj_AddTapGestureRecognizerBlock:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        [suspendedView kj_clearLayers];
        suspendedView.shapeType = KJDarwShapeTypeOval;
    }];
}
- (CAShapeLayer*)redLayer{
    if (!_redLayer) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.fillColor = [UIColor.redColor colorWithAlphaComponent:0.5].CGColor;
        shapeLayer.strokeColor = UIColor.redColor.CGColor;
        shapeLayer.lineWidth = 2;
        shapeLayer.lineJoin = kCALineJoinRound;// 连接节点样式
        shapeLayer.lineCap = kCALineCapRound;// 线头样式
        _redLayer = shapeLayer;
    }
    return _redLayer;
}

@end
