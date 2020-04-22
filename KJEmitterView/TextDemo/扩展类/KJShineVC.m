//
//  KJShadowVC.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/4/13.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJShineVC.h"

@interface KJShineVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *displayImageView;
@property (weak, nonatomic) IBOutlet UISlider *slider1;
@property (weak, nonatomic) IBOutlet UISlider *slider2;
@property (weak, nonatomic) IBOutlet UILabel *xLabel;
@property (weak, nonatomic) IBOutlet UILabel *yLabel;
@property (weak, nonatomic) IBOutlet UIStepper *xStepper;
@property (weak, nonatomic) IBOutlet UIStepper *yStepper;

@end

@implementation KJShineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.xStepper.minimumValue = -500.f;
    self.xStepper.maximumValue = 500.f;
    self.xStepper.value = 50;
    self.yStepper.minimumValue = -500.f;
    self.yStepper.maximumValue = 500.f;
    self.yStepper.value = 50;
    self.xLabel.text = [NSString stringWithFormat:@"x:%.1f",self.xStepper.value];
    self.yLabel.text = [NSString stringWithFormat:@"y:%.1f",self.yStepper.value];
    
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
    
    self.imageView.kj_innerShadowPath = path;//[UIBezierPath bezierPathWithRoundedRect:self.backView.bounds cornerRadius:1];
    self.imageView.kj_innerShadowColor = UIColor.redColor;
    self.imageView.kj_innerShadowOffset = CGSizeMake(self.xStepper.value, self.yStepper.value);
    self.imageView.kj_innerShadowRadius = self.slider2.value;
    self.imageView.kj_innerShadowOpacity = self.slider1.value;
    [self.imageView kj_aroundInnerShine];
    
    _weakself;
    for (UIView *view in self.view.subviews) {
        if (520<=view.tag&&view.tag<=523) {
            [view kj_AddTapGestureRecognizerBlock:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
                weakself.imageView.kj_innerShadowColor = view.backgroundColor;
                    weakself.displayImageView.image = [UIImage kj_captureScreen:weakself.imageView];
            }];
        }
    }
}

- (IBAction)slider1:(UISlider *)sender {
    self.imageView.kj_innerShadowOpacity = sender.value;
}
- (IBAction)slider2:(UISlider *)sender {
    self.imageView.kj_innerShadowRadius = sender.value;
}
- (IBAction)x:(UIStepper *)sender {
    self.xLabel.text = [NSString stringWithFormat:@"x:%.1f",self.xStepper.value];
    CGSize old = self.imageView.kj_innerShadowOffset;
    CGSize new = CGSizeMake(old.width, sender.value);
    self.imageView.kj_innerShadowOffset = new;
    self.displayImageView.image = [UIImage kj_captureScreen:self.imageView];
}
- (IBAction)y:(UIStepper *)sender {
    self.yLabel.text = [NSString stringWithFormat:@"y:%.1f",self.yStepper.value];
    CGSize old = self.imageView.kj_innerShadowOffset;
    CGSize new = CGSizeMake(sender.value,old.height);
    self.imageView.kj_innerShadowOffset = new;
    self.displayImageView.image = [UIImage kj_captureScreen:self.imageView];
}


@end
