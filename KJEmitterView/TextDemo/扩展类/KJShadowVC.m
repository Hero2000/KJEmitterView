//
//  KJShadowVC.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/4/13.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJShadowVC.h"

@interface KJShadowVC (){
    KJShadowLayer *layer;
    UIImage *image;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *slider1;
@property (weak, nonatomic) IBOutlet UISlider *slider2;
@property (weak, nonatomic) IBOutlet UISlider *slider3;
@property (weak, nonatomic) IBOutlet UISlider *slider4;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;

@end

@implementation KJShadowVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    image = self.imageView.image;
    //路径阴影
    CGFloat pw = self.imageView.frame.size.width;
    CGFloat ph = self.imageView.frame.size.height;
    UIBezierPath *path = [UIBezierPath bezierPath];
    //添加直线
    [path moveToPoint:CGPointMake(pw/3, 0)];
    [path addLineToPoint:CGPointMake(pw/3*2, 0)];
    [path addLineToPoint:CGPointMake(pw, ph/2.0)];
    [path addLineToPoint:CGPointMake(pw/4*3, ph/2.0)];
    [path addLineToPoint:CGPointMake(pw, ph)];
    [path addLineToPoint:CGPointMake(pw/3*2, ph)];
    [path addLineToPoint:CGPointMake(pw/4, ph-50)];
    [path addLineToPoint:CGPointMake(0, ph/3)];
    [path addLineToPoint:CGPointMake(pw/3, 0)];
    
//    layer = [[KJShadowLayer alloc]kj_initWithFrame:self.imageView.bounds ShadowType:(KJShadowTypeProjection)];
//    layer.position = CGPointMake(self.imageView.centerX+30, self.imageView.bottom+64);
    layer = [[KJShadowLayer alloc]kj_initWithFrame:self.imageView.bounds ShadowType:(KJShadowTypeInner)];
    layer.kj_shadowPath = path;
    layer.kj_shadowOpacity = self.slider1.value;
    layer.kj_shadowRadius = self.slider3.value;
    layer.kj_shadowAngle = self.slider4.value;
    layer.kj_shadowDiffuse = self.slider2.value;
//    [self.view.layer addSublayer:layer];
    [self.imageView.layer addSublayer:layer];
    
    _weakself;
    [self.imageView2 kj_AddTapGestureRecognizerBlock:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        weakself.imageView2.image = [UIImage kj_captureScreen:weakself.imageView];
    }];
    
}

- (IBAction)slider1:(UISlider *)sender {
    layer.kj_shadowOpacity = self.slider1.value;
}
- (IBAction)slider2:(UISlider *)sender {
    layer.kj_shadowDiffuse = self.slider2.value;
}
- (IBAction)slider3:(UISlider *)sender {
    layer.kj_shadowRadius = self.slider3.value;
}
- (IBAction)slider4:(UISlider *)sender {
    layer.kj_shadowAngle = self.slider4.value;
}

@end
