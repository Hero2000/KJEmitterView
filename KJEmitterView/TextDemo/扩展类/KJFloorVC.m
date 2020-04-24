//
//  KJFloorVC.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/4/22.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJFloorVC.h"

@interface KJFloorVC (){
    __block KJImageFloorJointType type;
    NSArray *textTemps;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UITextField *w;
@property (weak, nonatomic) IBOutlet UITextField *H;
@property (weak, nonatomic) IBOutlet UIStepper *ste;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation KJFloorVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIImage *image = [UIImage imageNamed:@"axv"];
//    KJImageFloorJointTypeCustom, /// 默认，正常平铺
//    KJImageFloorJointTypeAcrossAngle, /// 横倒角
//    KJImageFloorJointTypeVerticalAngle, /// 竖倒角
//    KJImageFloorJointTypeLengthMix, /// 长短混合
//    KJImageFloorJointTypeClassical, /// 古典拼法
//    KJImageFloorJointTypeDouble, /// 两拼法
//    KJImageFloorJointTypeThree, /// 三拼法
//    KJImageFloorJointTypeConcaveConvex, /// 凹凸效果
    textTemps = @[@"艺术地板拼法",@"横倒角",@"竖倒角",@"长短混合",@"古典拼法",@"两拼法",@"三拼法",@"凹凸效果"];
    type = self.ste.value = 0;
    self.ste.minimumValue = 0;
    self.ste.maximumValue = textTemps.count-1;
    self.label.text = [NSString stringWithFormat:@"拼接方式:%@",textTemps[(int)self.ste.value]];
    self.w.text = @"800";
    self.H.text = @"800";
    _weakself;
    CGFloat w = [weakself.w.text doubleValue];
    CGFloat h = [weakself.H.text doubleValue];
    w = w <= 0 ? 1000 : w;
    h = h <= 0 ? 1000 : h;
    weakself.imageView.image = [image kj_imageFloorWithFloorJointType:(type) TargetImageSize:KJImageSizeMake(w, h) FloorWidth:110];
    
    [self.imageView kj_AddGestureRecognizer:(KJGestureTypeTap) block:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        CGFloat w = [weakself.w.text doubleValue];
        CGFloat h = [weakself.H.text doubleValue];
        w = w <= 0 ? 1000 : w;
        h = h <= 0 ? 1000 : h;
        weakself.imageView.image = [image kj_imageFloorWithFloorJointType:(type) TargetImageSize:KJImageSizeMake(w, h) FloorWidth:110];
        [weakself.w resignFirstResponder];
        [weakself.H resignFirstResponder];
    }];
}
- (IBAction)ste:(UIStepper *)sender {
    [self.w resignFirstResponder];
    [self.H resignFirstResponder];
    type = sender.value;
    self.label.text = [NSString stringWithFormat:@"拼接方式:%@",textTemps[(int)sender.value]];
    CGFloat w = [self.w.text doubleValue];
    CGFloat h = [self.H.text doubleValue];
    w = w <= 0 ? 1000 : w;
    h = h <= 0 ? 1000 : h;
    UIImage *image = [UIImage imageNamed:@"axv"];
    self.imageView.image = [image kj_imageFloorWithFloorJointType:(type) TargetImageSize:KJImageSizeMake(w, h) FloorWidth:110];
}

@end
