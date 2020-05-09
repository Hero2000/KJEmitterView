//
//  KJShadowVC.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/4/13.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJShineVC.h"

@interface KJShineVC (){
   __block KJShadowLayer *layer;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *displayImageView;
@property (weak, nonatomic) IBOutlet UISlider *slider1;
@property (weak, nonatomic) IBOutlet UISlider *slider2;
@property (weak, nonatomic) IBOutlet UISlider *slider3;
@property (weak, nonatomic) IBOutlet UILabel *xLabel;

@end

@implementation KJShineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    //路径阴影
    CGFloat pw = self.imageView.frame.size.width;
    CGFloat ph = self.imageView.frame.size.height;
    UIBezierPath *path = [UIBezierPath bezierPath];
    //添加直线
    [path moveToPoint:CGPointMake(pw/3, 20)];
    [path addLineToPoint:CGPointMake(pw/3*2, 20)];
    [path addLineToPoint:CGPointMake(pw-20, ph-20)];
    [path addLineToPoint:CGPointMake(pw/2, ph-60)];
    [path addLineToPoint:CGPointMake(20, ph-20)];
    [path addLineToPoint:CGPointMake(20, ph/3)];
    [path addLineToPoint:CGPointMake(pw/3, 20)];
    layer = [[KJShadowLayer alloc]kj_initWithFrame:self.imageView.bounds ShadowType:(KJShadowTypeOuterShine)];
    layer.kj_shadowPath = path;
    layer.kj_shadowColor = UIColor.redColor;
    layer.kj_shadowOpacity = self.slider1.value;
    layer.kj_shadowDiffuse = self.slider2.value;
    layer.kj_shadowRadius = self.slider3.value;
    [self.imageView.layer addSublayer:layer];
//    [self.imageView.layer insertSublayer:layer atIndex:0];
    layer.contents = self.imageView.image;
    
    _weakself;
    for (UIView *view in self.view.subviews) {
        if (520<=view.tag&&view.tag<=523) {
            [view kj_AddTapGestureRecognizerBlock:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
                layer.kj_shadowColor = view.backgroundColor;
                weakself.displayImageView.image = [UIImage kj_captureScreen:weakself.imageView];
            }];
        }
    }
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

@end
