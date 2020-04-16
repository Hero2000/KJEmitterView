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

@end

@implementation KJShadowVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.imageView.innerShadowPath = [UIBezierPath bezierPathWithRoundedRect:self.imageView.bounds cornerRadius:1];
    self.imageView.innerShadowColor = UIColor.blackColor;
    [self.imageView kj_innerShadowAngle:self.slider4.value Distance:self.slider2.value];
    self.imageView.innerShadowRadius = self.slider3.value;
    self.imageView.innerShadowOpacity = self.slider1.value;
    [self.imageView kj_addInnerShadow];
}

- (IBAction)slider1:(UISlider *)sender {
    self.imageView.innerShadowOpacity = sender.value;
}
- (IBAction)slider2:(UISlider *)sender {
    [self.imageView kj_innerShadowAngle:self.slider4.value Distance:self.slider2.value];
}
- (IBAction)slider3:(UISlider *)sender {
    self.imageView.innerShadowRadius = sender.value;
}
- (IBAction)slider4:(UISlider *)sender {
    [self.imageView kj_innerShadowAngle:sender.value Distance:self.slider2.value];
}

@end
