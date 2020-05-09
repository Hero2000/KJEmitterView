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
//    [self.imageView.layer addSublayer:layer];
    
    _weakself;
    [self.imageView2 kj_AddTapGestureRecognizerBlock:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
//        weakself.imageView.image = [weakself.imageView.image kj_coreImageHighlightShadowWithHighlightAmount:10 ShadowAmount:20];
        weakself.imageView2.image = [UIImage kj_captureScreen:weakself.imageView];
    }];
    
    /// 测试
//    self.imageView.image = [image kj_imagePhotoshopWithType:(KJCoreImagePhotoshopTypeSaturation) Value:0.7];
//    CIVector *v1 = [CIVector vectorWithX:image.size.width Y:image.size.height Z:20];
//    CIVector *v2 = [CIVector vectorWithX:800 Y:600 Z:0];
//    self.imageView.image = [image kj_coreImageSpotLightWithLightPosition:v1 LightPointsAt:v2 Brightness:2.5 Concentration:0.1 LightColor:UIColor.yellowColor];
    self.imageView.image = [image kj_coreImageBlackMaskToAlpha];
//    self.imageView.image = [image kj_coreImagePixellateWithCenter:CGPointMake(100, 100) Scale:10];
//    self.imageView.image = [image kj_coreImageHighlightShadowWithHighlightAmount:10 ShadowAmount:20];
//    self.imageView.image = [image kj_coreImagePerspectiveTransformWithTopLeft:CGPointMake(0, 0) TopRight:CGPointMake(pw-10, 10) BottomRight:CGPointMake(pw, ph) BottomLeft:CGPointMake(20, ph-20)];
}

- (IBAction)slider1:(UISlider *)sender {
//    layer.kj_shadowOpacity = self.slider1.value;
    self.imageView.image = [image kj_coreImagePhotoshopWithType:(KJCoreImagePhotoshopTypeSaturation) Value:self.slider1.value];
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
