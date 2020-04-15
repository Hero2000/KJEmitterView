//
//  KJShadowVC.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/4/13.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJShadowVC.h"

@interface KJShadowVC ()
@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) UIView *backView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *slider1;
@property (weak, nonatomic) IBOutlet UISlider *slider2;
@property (weak, nonatomic) IBOutlet UILabel *xLabel;
@property (weak, nonatomic) IBOutlet UILabel *yLabel;
@property (weak, nonatomic) IBOutlet UIStepper *xStepper;
@property (weak, nonatomic) IBOutlet UIStepper *yStepper;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UIView *view4;

@end

@implementation KJShadowVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.backView = [[UIView alloc]initWithFrame:self.imageView.bounds];
    self.backView.backgroundColor = UIColor.clearColor;
    [self.imageView addSubview:self.backView];
    
    self.backView2 = [[UIView alloc]initWithFrame:self.imageView.bounds];
    self.backView2.backgroundColor = UIColor.clearColor;
    [self.imageView addSubview:self.backView2];
    
    self.xStepper.minimumValue = -50.f;
    self.xStepper.maximumValue = 50.f;
    self.xStepper.value = 30.f;
    self.yStepper.minimumValue = -50.f;
    self.yStepper.maximumValue = 50.f;
    self.yStepper.value = 30.f;
    self.xLabel.text = [NSString stringWithFormat:@"x:%.1f",self.xStepper.value];
    self.yLabel.text = [NSString stringWithFormat:@"y:%.1f",self.yStepper.value];
    
    self.backView.innerShadowPath = [UIBezierPath bezierPathWithRoundedRect:self.backView.bounds cornerRadius:1];
    self.backView.innerShadowColor = UIColor.blackColor;
    self.backView.innerShadowOffset = CGSizeMake(self.xStepper.value, self.yStepper.value);
    self.backView.innerShadowRadius = 20;
    self.backView.innerShadowOpacity = 1;
    [self.backView addInnerShadow];
    
    self.backView2.innerShadowPath = [UIBezierPath bezierPathWithRoundedRect:self.backView2.bounds cornerRadius:1];
    self.backView2.innerShadowColor = UIColor.blackColor;
    self.backView2.innerShadowOffset = CGSizeMake(-self.xStepper.value, -self.yStepper.value);
    self.backView2.innerShadowRadius = 20;
    self.backView2.innerShadowOpacity = 1;
    [self.backView2 addInnerShadow];
    
    _weakself;
    [self.view1 kj_AddTapGestureRecognizerBlock:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        weakself.backView.innerShadowColor = view.backgroundColor;
        weakself.backView2.innerShadowColor = view.backgroundColor;
    }];
    [self.view2 kj_AddTapGestureRecognizerBlock:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        weakself.backView.innerShadowColor = view.backgroundColor;
        weakself.backView2.innerShadowColor = view.backgroundColor;
    }];
    [self.view3 kj_AddTapGestureRecognizerBlock:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        weakself.backView.innerShadowColor = view.backgroundColor;
        weakself.backView2.innerShadowColor = view.backgroundColor;
    }];
    [self.view4 kj_AddTapGestureRecognizerBlock:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        weakself.backView.innerShadowColor = view.backgroundColor;
        weakself.backView2.innerShadowColor = view.backgroundColor;
    }];
}

- (IBAction)slider1:(UISlider *)sender {
    self.backView.innerShadowOpacity = sender.value;
    self.backView2.innerShadowOpacity = sender.value;
}
- (IBAction)slider2:(UISlider *)sender {
    self.backView.innerShadowRadius = sender.value;
    self.backView2.innerShadowRadius = sender.value;
}
- (IBAction)x:(UIStepper *)sender {
    self.xLabel.text = [NSString stringWithFormat:@"x:%.1f",self.xStepper.value];
    CGSize old = self.backView.innerShadowOffset;
    CGSize new = CGSizeMake(old.width, sender.value);
    self.backView.innerShadowOffset = new;
    
    CGFloat x = sender.value > 0 ? -sender.value : sender.value;
    CGSize old2 = self.backView2.innerShadowOffset;
    CGSize new2 = CGSizeMake(old2.width, x);
    self.backView2.innerShadowOffset = new2;
}
- (IBAction)y:(UIStepper *)sender {
    self.yLabel.text = [NSString stringWithFormat:@"y:%.1f",self.yStepper.value];
    CGSize old = self.backView.innerShadowOffset;
    CGSize new = CGSizeMake(sender.value,old.height);
    self.backView.innerShadowOffset = new;
    
    CGFloat x = sender.value > 0 ? -sender.value : sender.value;
    CGSize old2 = self.backView2.innerShadowOffset;
    CGSize new2 = CGSizeMake(x,old2.height);
    self.backView2.innerShadowOffset = new2;
}


@end
