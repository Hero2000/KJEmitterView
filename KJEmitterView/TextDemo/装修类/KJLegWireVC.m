//
//  KJLegWireVC.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/19.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJLegWireVC.h"
#import "KJLegWireLayer.h"

@interface KJLegWireVC ()
@property(nonatomic,strong) CAShapeLayer *redLayer; /// 红色透视选区
@end

@implementation KJLegWireVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat w = self.view.size.width;
    CGFloat h = self.view.size.height;
    KJKnownPoints points = {
        CGPointMake(50, 64+20),
        CGPointMake(20, h/2),
        CGPointMake(w-30, h/2-50),
        CGPointMake(w-20, 64+100),
    };
    [self.view.layer addSublayer:self.redLayer];
    self.redLayer.path = ({
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:points.PointA];
        [path addLineToPoint:points.PointB];
        [path addLineToPoint:points.PointC];
        [path addLineToPoint:points.PointD];
        [path closePath]; /// 闭合路径
        path.CGPath;
    });
    __block UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, w, 100)];
    imageView.image = [UIImage imageNamed:@"IMG_4931"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
    imageView.center = CGPointMake(w/2, h-100);
    [self.view addSubview:imageView];
    
    __block KJLegWireLayer *layer = [[KJLegWireLayer alloc]kj_initWithFrame:CGRectMake(100, 40, w, 500) KnownPoints:points Size:CGSizeMake(w-20, h/2) LegWireHeight:0.0];
    [self.view.layer addSublayer:layer];
    
    [imageView kj_AddTapGestureRecognizerBlock:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        layer.materialImage = imageView.image;
        layer.kChartletBlcok = ^UIImage * _Nonnull(KJKnownPoints points, UIImage * _Nonnull jointImage) {
            /// 透视图片
//            UIImage *imag = [jointImage kj_coreImagePerspectiveTransformWithTopLeft:CGPointMake(0, 0) TopRight:CGPointMake(100, 20) BottomRight:CGPointMake(200, 100) BottomLeft:CGPointMake(-20, 100)];
            UIImage *img = [jointImage kj_coreImagePerspectiveTransformWithTopLeft:points.PointA TopRight:points.PointD BottomRight:points.PointC BottomLeft:points.PointB];
            imageView.image = jointImage;
            return jointImage;
        };
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
