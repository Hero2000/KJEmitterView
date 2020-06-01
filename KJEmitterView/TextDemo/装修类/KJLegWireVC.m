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
        CGPointMake(w-30, h/2+50),
        CGPointMake(w-20, 64+20+50),
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
    UIImage *image = [UIImage imageNamed:@"IMG_4931"];
    __block UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, h/2+20, w, h/2-20)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
//    imageView.center = CGPointMake(w/2, h-100);
    [self.view addSubview:imageView];
    UIImage *img = [UIImage imageNamed:@"timg-2"];
    imageView.image = [_KJIFinishTools kj_orthogonImageBecomeOvalWithImage:img Rect:CGRectMake(0, 0, 1228, 660) Margin:YES];
//    NSArray *pointTemps = @[NSStringFromCGPoint(points.PointA),
//                            NSStringFromCGPoint(points.PointD),
//                            NSStringFromCGPoint(points.PointC),
//                            NSStringFromCGPoint(points.PointB)];
//    KJImageWarpResult result = [_KJIFinishTools changeImageByPoints:pointTemps Image:image];
//    imageView.frame = result.newRect;
//    imageView.image = result.newImage;
    
    __block KJLegWireLayer *layer = [[KJLegWireLayer alloc]kj_initWithFrame:CGRectMake(100, 40, w, h/2) KnownPoints:points Size:CGSizeMake(w-20, h/2) LegWireHeight:h/2/6];
    [self.view.layer addSublayer:layer];
    layer.materialImage = image;
    [imageView kj_AddTapGestureRecognizerBlock:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        layer.kChartletBlcok = ^UIImage * _Nonnull(KJKnownPoints points, UIImage * _Nonnull jointImage) {
            /// 透视图片
            UIImage *img = [jointImage kj_softFitmentFluoroscopyWithTopLeft:points.PointA TopRight:points.PointD BottomRight:points.PointC BottomLeft:CGPointMake(points.PointB.x, points.PointB.y)];
            imageView.image = jointImage;
            
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.fillColor = [UIColor.redColor colorWithAlphaComponent:0.5].CGColor;
            shapeLayer.strokeColor = UIColor.redColor.CGColor;
            shapeLayer.lineWidth = 2;
            shapeLayer.lineJoin = kCALineJoinRound;// 连接节点样式
            shapeLayer.lineCap = kCALineCapRound;// 线头样式
            shapeLayer.path = ({
                UIBezierPath *path = [UIBezierPath bezierPath];
                [path moveToPoint:points.PointA];
                [path addLineToPoint:points.PointB];
                [path addLineToPoint:points.PointC];
                [path addLineToPoint:points.PointD];
                [path closePath]; /// 闭合路径
                path.CGPath;
            });
            [self.view.layer addSublayer:shapeLayer];
            return img;
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
