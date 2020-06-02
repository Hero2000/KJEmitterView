//
//  KJSkirtingLineVC.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/5/27.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJSkirtingLineVC.h"
#import "KJSkirtingLineView.h"
#import "KJMuralView.h"
#import "KJDecorateBoxView.h"
@interface KJSkirtingLineVC (){
    __block KJDecorateBoxView *decorateBoxView;
}
@property(nonatomic,strong) CAShapeLayer *redLayer; /// 红色透视选区
@end

@implementation KJSkirtingLineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat w = self.view.size.width;
    CGFloat h = self.view.size.height;
    KJKnownPoints points = {
        CGPointMake(50, 64+20),
        CGPointMake(20, h/2),
        CGPointMake(w-80, h/2-40),
        CGPointMake(w-20, 64+20),
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
    CGFloat xw = 75;
    __block UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, xw, xw)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageNamed:@"xxsf"];
    imageView.center = CGPointMake(xw*.5, h-100);
    [self.view addSubview:imageView];
    __block UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, xw, xw)];
    imageView2.contentMode = UIViewContentModeScaleAspectFit;
    imageView2.image = [UIImage imageNamed:@"IMG_4931"];
    imageView2.center = CGPointMake(w/4+xw*.5, h-100);
    [self.view addSubview:imageView2];
    __block UIImageView *imageView3 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, xw, xw)];
    imageView3.contentMode = UIViewContentModeScaleAspectFit;
    imageView3.image = [UIImage imageNamed:@"timg-2"];
    imageView3.center = CGPointMake(w/2+xw*.5, h-100);
    [self.view addSubview:imageView3];
    __block UIImageView *imageView4 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, xw, xw)];
    imageView4.contentMode = UIViewContentModeScaleAspectFit;
    imageView4.image = [UIImage imageNamed:@"fff"];
    imageView4.center = CGPointMake(w/4*3+xw*.5, h-100);
    [self.view addSubview:imageView4];
    UISwitch *sw = [[UISwitch alloc]initWithFrame:CGRectMake(20, h/2+50, 50, 30)];
//    sw.selected = YES;
    [self.view addSubview:sw];
    [sw addTarget:self action:@selector(swSender:) forControlEvents:(UIControlEventValueChanged)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20+50+10, h/2+50, 200, 30)];
    label.text = @"是否开启绘制壁画";
    [self.view addSubview:label];
    
    decorateBoxView = [[KJDecorateBoxView alloc] kj_initWithFrame:CGRectMake(200, 0, w, h/2) KnownPoints:points];
    decorateBoxView.dashPatternWidth = 1.7;
    decorateBoxView.dashPatternColor = UIColor.blueColor;
    decorateBoxView.openDrawDecorateBox = sw.selected;
    [self.view addSubview:decorateBoxView];
    __block CGPoint pt = imageView.center;
    [imageView kj_AddGestureRecognizer:(KJGestureTypePan) block:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        CGPoint translation = [((UIPanGestureRecognizer*)gesture) translationInView:view];
        NSLog(@"---:%.2f,%.2f",translation.x,translation.y);
        view.center = CGPointMake(pt.x + translation.x, pt.y + translation.y);
        bool boo = [self->decorateBoxView kj_chartletAndFixationWithMaterialImage:((UIImageView*)view).image Point:view.center PerspectiveBlock:^UIImage * _Nonnull(KJKnownPoints points, UIImage * _Nonnull jointImage) {
            UIImage *img = [jointImage kj_softFitmentFluoroscopyWithTopLeft:points.PointA TopRight:points.PointD BottomRight:points.PointC BottomLeft:points.PointB];
            return img;
        }];
        if (boo) view.center = pt;
    }];
    __block CGPoint pt3 = imageView3.center;
    [imageView3 kj_AddGestureRecognizer:(KJGestureTypePan) block:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        CGPoint translation = [((UIPanGestureRecognizer*)gesture) translationInView:view];
        view.center = CGPointMake(pt3.x + translation.x, pt3.y + translation.y);
        bool boo = [self->decorateBoxView kj_chartletAndFixationWithMaterialImage:((UIImageView*)view).image Point:view.center PerspectiveBlock:^UIImage * _Nonnull(KJKnownPoints points, UIImage * _Nonnull jointImage) {
            UIImage *img = [jointImage kj_softFitmentFluoroscopyWithTopLeft:points.PointA TopRight:points.PointD BottomRight:points.PointC BottomLeft:points.PointB];
            return img;
        }];
        if (boo) view.center = pt3;
    }];
    
    __block KJSkirtingLineView *__view = [[KJSkirtingLineView alloc] kj_initWithFrame:CGRectMake(200, 0, w, h/2) KnownPoints:points LegWireType:KJSkirtingLineTypeBottom | KJSkirtingLineTypeTop | KJSkirtingLineTypeLeft];
    __view.dashPatternColor = UIColor.greenColor;
    __view.dashPatternWidth = 1.5;
    [self.view addSubview:__view];
    __view.kMovePerspectiveBlock = ^UIImage * _Nonnull(KJKnownPoints points, UIImage * _Nonnull jointImage) {
        UIImage *img = [jointImage kj_softFitmentFluoroscopyWithTopLeft:points.PointA TopRight:points.PointD BottomRight:points.PointC BottomLeft:points.PointB];
        return img;
    };
    [imageView2 kj_AddGestureRecognizer:(KJGestureTypeLongPress) block:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        [__view kj_clearLayers];
    }];
    __block CGPoint pt2 = imageView2.center;
    [imageView2 kj_AddGestureRecognizer:(KJGestureTypePan) block:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        CGPoint translation = [((UIPanGestureRecognizer*)gesture) translationInView:view];
        view.center = CGPointMake(pt2.x + translation.x, pt2.y + translation.y);
        bool boo = [__view kj_changeMaterialImage:((UIImageView*)view).image Point:view.center PerspectiveBlock:^UIImage * _Nonnull(KJKnownPoints points, UIImage * _Nonnull jointImage) {
            UIImage *img = [jointImage kj_softFitmentFluoroscopyWithTopLeft:points.PointA TopRight:points.PointD BottomRight:points.PointC BottomLeft:points.PointB];
            return img;
        }];
        if (boo) view.center = pt2;
    }];
    __block CGPoint pt4 = imageView4.center;
    [imageView4 kj_AddGestureRecognizer:(KJGestureTypePan) block:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        CGPoint translation = [((UIPanGestureRecognizer*)gesture) translationInView:view];
        view.center = CGPointMake(pt4.x + translation.x, pt4.y + translation.y);
        bool boo = [__view kj_changeMaterialImage:((UIImageView*)view).image Point:view.center PerspectiveBlock:^UIImage * _Nonnull(KJKnownPoints points, UIImage * _Nonnull jointImage) {
            UIImage *img = [jointImage kj_softFitmentFluoroscopyWithTopLeft:points.PointA TopRight:points.PointD BottomRight:points.PointC BottomLeft:points.PointB];
            return img;
        }];
        if (boo) view.center = pt4;
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
- (void)swSender:(UISwitch*)sender{
    sender.selected = !sender.selected;
    decorateBoxView.openDrawDecorateBox = sender.selected;
}
@end
