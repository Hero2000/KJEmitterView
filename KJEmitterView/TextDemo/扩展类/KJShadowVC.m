//
//  KJShadowVC.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/4/13.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJShadowVC.h"

@interface KJShadowVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *slider1;
@property (weak, nonatomic) IBOutlet UISlider *slider2;
@property (weak, nonatomic) IBOutlet UISlider *slider3;
@property (weak, nonatomic) IBOutlet UISlider *slider4;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;

@end

@implementation KJShadowVC
//NSNumber* DegreesToNumber(CGFloat degrees){
//    return [NSNumber numberWithFloat: DegreesToRadians(degrees)];
//}
//CGFloat DegreesToRadians(CGFloat degrees){
//    return degrees * M_PI / 180;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.imageView.kj_innerShadowPath = [UIBezierPath bezierPathWithRoundedRect:self.imageView.bounds cornerRadius:1];
    self.imageView.kj_innerShadowColor = UIColor.blackColor;
    [self.imageView kj_innerShadowAngle:self.slider4.value Distance:self.slider2.value];
    self.imageView.kj_innerShadowRadius = self.slider3.value;
    self.imageView.kj_innerShadowOpacity = self.slider1.value;
    [self.imageView kj_addInnerShadow];
    
//    CATransform3D transform = CATransform3DIdentity;
//    //z轴纵深的3D效果和CATransform3DRotate配合使用才能看出效果
//    transform.m34 = 1.0/-1900;
//    //绕x轴向内旋转30度
//    transform = CATransform3DRotate(transform, 45.0f * M_PI/180.0f, 1, 0, 0);
//    self.imageView.layer.transform = transform;
    
    //路径阴影
    CGFloat pw = self.imageView.frame.size.width;
    CGFloat ph = self.imageView.frame.size.height;
    UIBezierPath *path = [UIBezierPath bezierPath];
    //添加直线
    [path moveToPoint:CGPointMake(pw/3, 0)];
    [path addLineToPoint:CGPointMake(pw/3*2, 0)];
    [path addLineToPoint:CGPointMake(pw, ph)];
    [path addLineToPoint:CGPointMake(0, ph)];
    [path addLineToPoint:CGPointMake(0, ph/3)];
    [path addLineToPoint:CGPointMake(pw/3, 0)];
    
    _weakself;
    [self.imageView2 kj_AddTapGestureRecognizerBlock:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
//        weakself.imageView2.image = [UIImage kj_anomalyCaptureImageWithView:weakself.imageView BezierPath:path];
        weakself.imageView2.image = [UIImage kj_captureScreen:weakself.imageView];
    }];
    
    [self kj_projection:self.imageView];
}

- (IBAction)slider1:(UISlider *)sender {
    self.imageView.kj_innerShadowOpacity = sender.value;
}
- (IBAction)slider2:(UISlider *)sender {
    [self.imageView kj_innerShadowAngle:self.slider4.value Distance:self.slider2.value];
}
- (IBAction)slider3:(UISlider *)sender {
    self.imageView.kj_innerShadowRadius = sender.value;
}
- (IBAction)slider4:(UISlider *)sender {
    [self.imageView kj_innerShadowAngle:sender.value Distance:self.slider2.value];
}
/// 投影效果
- (void)kj_projection:(UIView*)backGround{
//    backGround.layer.shadowOpacity = 1;
//    backGround.layer.shadowColor = UIColor.whiteColor.CGColor;
//    backGround.layer.borderWidth = 5;//距离2px
//    backGround.layer.borderColor = UIColor.blackColor.CGColor;
//    backGround.layer.opaque = 0.06;//透明度6%
//    backGround.layer.masksToBounds = YES;//是否裁剪
//    backGround.layer.shadowOffset = CGSizeZero;//投影偏移
//    backGround.layer.shadowRadius = 40;//大小为8px
      
//    //获取复制层，复制子层（这里的view 是 VCView）
//    CAReplicatorLayer * repL = (CAReplicatorLayer*)self.view.layer;
//    repL.instanceCount = 2;
//
//    //绕x轴旋转180度 PI
//    repL.instanceTransform = CATransform3DMakeRotation(M_PI, 1, 0, 0);
//
//    repL.instanceRedOffset -= 0.1;
//    repL.instanceGreenOffset -= 0.1;
//    repL.instanceBlueOffset -=0.1;
//    repL.instanceAlphaOffset -= 0.1;
}

@end
