//
//  KJInvertedVC.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/4/21.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJReflectionVC.h"

@interface KJReflectionVC (){
    CALayer *reflectionLayer;
    CAGradientLayer *gradientLayer;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *slider1;
@property (weak, nonatomic) IBOutlet UISlider *slider2;
@property (weak, nonatomic) IBOutlet UISlider *slider3;

@end

@implementation KJReflectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    CGFloat w = self.imageView.frame.size.width;
//    CGFloat h = self.imageView.frame.size.height;
//    CGFloat a = self.imageView.center.x;
//    CGFloat b = self.imageView.center.y;
//    CGFloat m = h*self.slider3.value;
//    CGFloat cy = b+(h+m)*.5+64;
//    //倒影(图片旋转180度）
//    reflectionLayer = [[CALayer alloc] init];
////    reflectionLayer.backgroundColor = UIColor.redColor.CGColor;
//    reflectionLayer.bounds = CGRectMake(0, 0, w, m);
//    reflectionLayer.position = CGPointMake(a, cy);
//    reflectionLayer.contents = [self.imageView.layer contents];
//
//    reflectionLayer.opacity = self.slider1.value;
//
//    //创建镜像层上的遮蔽层
//    gradientLayer = [[CAGradientLayer alloc] init];
//    gradientLayer.bounds = reflectionLayer.bounds;
//    gradientLayer.position = CGPointMake(reflectionLayer.bounds.size.width/2, reflectionLayer.bounds.size.height/2);
//    gradientLayer.colors = @[(id)UIColor.clearColor.CGColor,(id)UIColor.blackColor.CGColor];
//    gradientLayer.locations = @[@(self.slider2.value),@1];
//    gradientLayer.startPoint = CGPointMake(0.5,0.0);
//    gradientLayer.endPoint = CGPointMake(0.5,1.0);
//
//    //设置倒影的遮蔽层
//    [reflectionLayer setMask:gradientLayer];
//    [self.imageView.superview.layer addSublayer:reflectionLayer];
//
////    CATransform3D transform = CATransform3DIdentity;
////    //z轴纵深的3D效果和CATransform3DRotate配合使用才能看出效果
////    transform.m34 = 1.0/-1900;
////    //绕x轴向内旋转30度
////    transform = CATransform3DRotate(transform, (30.0f) * M_PI/180.0f, h/sin(30.0f * M_PI/180.0f), 1-h/cos(30.0f * M_PI/180.0f), 0);
////    reflectionLayer.transform = transform;
//    [reflectionLayer setValue:[NSNumber numberWithFloat:M_PI] forKeyPath:@"transform.rotation.x"];
    
    self.imageView.layer.kj_reflectionHideNavigation = self.fd_prefersNavigationBarHidden = NO;
    self.imageView.layer.kj_reflectionOpacity = self.slider1.value;
    self.imageView.layer.kj_reflectionFuzzy = self.slider2.value;
    self.imageView.layer.kj_reflectionSize = self.slider3.value;
    self.imageView.layer.kj_reflectionImageSpace = 10.;
    [self.imageView.layer kj_addReflection];
}

- (IBAction)slider1:(UISlider *)sender {
    self.imageView.layer.kj_reflectionOpacity = sender.value;
}
- (IBAction)slider2:(UISlider *)sender {
    self.imageView.layer.kj_reflectionFuzzy = sender.value;
}
- (IBAction)slider3:(UISlider *)sender {
    self.imageView.layer.kj_reflectionSize = sender.value;
//    CGFloat w = self.imageView.frame.size.width;
//    CGFloat h = self.imageView.frame.size.height;
//    CGFloat a = self.imageView.center.x;
//    CGFloat b = self.imageView.center.y;
//    CGFloat m = h*sender.value;
//    CGFloat cy = b+(h+m)*.5;
//    //倒影(图片旋转180度）
//    reflectionLayer.bounds = CGRectMake(0, 0, w, m);
//    reflectionLayer.position = CGPointMake(a, cy);
//    gradientLayer.bounds = reflectionLayer.bounds;
//    gradientLayer.position = CGPointMake(reflectionLayer.bounds.size.width/2, reflectionLayer.bounds.size.height/2);
}

@end
