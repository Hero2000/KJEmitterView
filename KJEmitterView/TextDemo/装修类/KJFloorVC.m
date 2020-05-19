//
//  KJFloorVC.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/4/22.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJFloorVC.h"
#import "UIImage+KJPave.h" /// 图片铺设处理

@interface KJFloorVC (){
    NSArray *textTemps;
    __block KJImageFloorJointType type;
    __block UIImage *image;
    __block CGFloat imagew;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UITextField *w;
@property (weak, nonatomic) IBOutlet UITextField *H;
@property (weak, nonatomic) IBOutlet UIStepper *ste;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *Button1;
@property (weak, nonatomic) IBOutlet UIButton *Button2;

@end

@implementation KJFloorVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    image = self.imageView2.image;
    imagew = 123;
    textTemps = @[@"艺术地板拼法",@"两拼法",@"三拼法",@"长短混合",@"古典拼法",@"凹凸效果",@"长短三分之一效果"];
    type = self.ste.value = 4;
    self.ste.minimumValue = 0;
    self.ste.maximumValue = textTemps.count-1;
    self.label.text = [NSString stringWithFormat:@"拼接方式:%@",textTemps[(int)self.ste.value]];
    self.w.text = @"1000";
    self.H.text = @"1000";
    _weakself;
    [self xxx:type];
    [self.imageView kj_AddGestureRecognizer:(KJGestureTypeTap) block:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        [weakself xxx:type];
    }];
    [self.imageView2 kj_AddTapGestureRecognizerBlock:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        image = weakself.imageView2.image;
        [weakself xxx:type];
    }];
    [self.imageView3 kj_AddTapGestureRecognizerBlock:^(UIView * _Nonnull view, UIGestureRecognizer * _Nonnull gesture) {
        image = weakself.imageView3.image;
        [weakself xxx:type];
    }];
    
}

- (void)xxx:(KJImageFloorJointType)type{
    [self.w resignFirstResponder];
    [self.H resignFirstResponder];
    self.label.text = [NSString stringWithFormat:@"拼接方式:%@",textTemps[type]];
    CGFloat w = [self.w.text doubleValue];
    CGFloat h = [self.H.text doubleValue];
    w = w <= 0 ? 1000 : w;
    h = h <= 0 ? 1000 : h;
    UIImage *img = [image kj_imageFloorWithFloorJointType:(type) TargetImageSize:CGSizeMake(w, h) FloorWidth:imagew OpenAcross:self.Button1.selected OpenVertical:self.Button2.selected];
    self.imageView.image = img;
}

- (IBAction)ste:(UIStepper *)sender {
    type = sender.value;
    [self xxx:type];
}
- (IBAction)button1:(UIButton *)sender {
    
}
- (IBAction)hen:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self xxx:type];
}
- (IBAction)shu:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self xxx:type];
}

@end
