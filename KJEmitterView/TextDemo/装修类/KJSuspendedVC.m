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
    KJKnownPoints points = {
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
    
    __block KJSuspendedView *__view = [[KJSuspendedView alloc]kj_initWithFrame:CGRectMake(0, 0, h, w) KnownPoints:points];
    __view.dashPatternColor = UIColor.whiteColor;
    __view.dashPatternWidth = 2;
    __view.center = self.view.center;
    __view.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0];
    __view.transform = CGAffineTransformMakeRotation(M_PI_2);
    [self.view addSubview:__view];
    __view.kChartletBlcok = ^KJSuspendedModel * _Nonnull(KJSuspendedModel * _Nonnull model) {
//        if (model.concaveType == KJDarwShapeTypeQuadrangle) {
        UIImage *image1 = [self scaleToSize:[UIImage imageNamed:@"xxxx"] size:model.bottomRect.size];
        UIImage *image2 = [self scaleToSize:[UIImage imageNamed:@"timg-2"] size:model.frontRect.size];
        UIImage *image3 = [self scaleToSize:[UIImage imageNamed:@"timg-2"] size:model.backRect.size];
        UIImage *image4 = [self scaleToSize:[UIImage imageNamed:@"timg-2"] size:model.leftRect.size];
        UIImage *image5 = [self scaleToSize:[UIImage imageNamed:@"timg-2"] size:model.rightRect.size];
        model.bottomImage = [self kj_textImageWithImage:image1 Points:model.bottomPoints];
        model.frontImage  = [self kj_textImageWithImage:image2 Points:model.frontPoints];
        model.backImage   = [self kj_textImageWithImage:image3 Points:model.backPoints];
        model.leftImage   = [self kj_textImageWithImage:image4 Points:model.leftPoints];
        model.rightImage  = [self kj_textImageWithImage:image5 Points:model.rightPoints];
        return model;
    };
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(100, __view.frame.size.height-50, 100, 50)];
    label.transform = CGAffineTransformMakeRotation(M_PI_2);
    label.center = CGPointMake(25, 64+50+25);
    label.backgroundColor = UIColor.redColor;
    label.text = @"清除";
    label.textColor = UIColor.whiteColor;
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    [label kj_AddTapGestureRecognizerBlock:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        [__view kj_clearLayers];
    }];
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(250, __view.frame.size.height-50, 100, 50)];
    label2.backgroundColor = UIColor.blueColor;
    label2.transform = CGAffineTransformMakeRotation(M_PI_2);
    label2.center = CGPointMake(25, 64+50+25+150);
    label2.text = @"四边形";
    label2.textColor = UIColor.whiteColor;
    label2.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label2];
    [label2 kj_AddTapGestureRecognizerBlock:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        [__view kj_clearLayers];
        __view.shapeType = KJDarwShapeTypeQuadrangle;
    }];
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(400, __view.frame.size.height-50, 100, 50)];
    label3.backgroundColor = UIColor.blueColor;
    label3.transform = CGAffineTransformMakeRotation(M_PI_2);
    label3.center = CGPointMake(25, 64+50+25+150+150);
    label3.text = @"椭圆";
    label3.textColor = UIColor.whiteColor;
    label3.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label3];
    [label3 kj_AddTapGestureRecognizerBlock:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        [__view kj_clearLayers];
        __view.shapeType = KJDarwShapeTypeOval;
    }];
    UILabel *label4 = [[UILabel alloc]initWithFrame:CGRectMake(400, __view.frame.size.height-50, 100, 50)];
    label4.backgroundColor = UIColor.blueColor;
    label4.transform = CGAffineTransformMakeRotation(M_PI_2);
    label4.center = CGPointMake(25, 64+50+25+150+150+150);
    label4.text = @"贴图";
    label4.textColor = UIColor.whiteColor;
    label4.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4];
    [label4 kj_AddTapGestureRecognizerBlock:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        __view.chartlet = true;
    }];
}
- (UIImage*)kj_textImageWithImage:(UIImage*)image Points:(KJKnownPoints)points{
    return [image kj_softFitmentFluoroscopyWithTopLeft:points.PointA TopRight:points.PointD BottomRight:points.PointC BottomLeft:points.PointB];
}
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size {
//    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
//    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
//    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    return img;
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
