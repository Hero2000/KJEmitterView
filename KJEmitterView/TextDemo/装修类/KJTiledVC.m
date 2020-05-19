//
//  KJTiledVC.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/4/20.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJTiledVC.h"
#import "UIImage+KJPave.h" /// 图片铺设处理

@interface KJTiledVC (){
    KJImageTiledType tiledType;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *rowLabel;
@property (weak, nonatomic) IBOutlet UILabel *colLabel;
@property (weak, nonatomic) IBOutlet UIStepper *rowSte;
@property (weak, nonatomic) IBOutlet UIStepper *colSte;
@property (weak, nonatomic) IBOutlet UIImageView *smallImageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIStepper *huaSte;

@end

@implementation KJTiledVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.huaSte.value = 0;
    self.huaSte.minimumValue = 0;
    self.huaSte.maximumValue = 4;
    tiledType = KJImageTiledTypePositively;
    self.huaSte.value = tiledType;
    self.rowSte.value = 5;
    self.colSte.value = 5;
    self.label.text = [NSString stringWithFormat:@"当前对花：%@", KJImageTiledTypeStringMap[tiledType]];
    self.rowLabel.text = [NSString stringWithFormat:@"行：%d", (int)self.rowSte.value];
    self.colLabel.text = [NSString stringWithFormat:@"列：%d", (int)self.colSte.value];
//    UIImage *img = [self.smallImageView.image kj_imageTiledWithTiledType:(tiledType) TargetImageSize:KJImageSizeMake(self.view.bounds.size.width, self.view.bounds.size.width) Row:self.rowSte.value Col:self.colSte.value];
    UIImage *img = [self.smallImageView.image kj_imageTiledWithTiledType:(tiledType) TargetImageSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width) Width:87];
    self.imageView.image = img;
}
- (IBAction)row:(UIStepper*)sender {
    UIImage *img = [self.smallImageView.image kj_imageTiledWithTiledType:(tiledType) TargetImageSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width) Row:self.rowSte.value Col:self.colSte.value];
    self.imageView.image = img;
    self.rowLabel.text = [NSString stringWithFormat:@"行：%d", (int)self.rowSte.value];
}
- (IBAction)col:(UIStepper*)sender {
    self.colLabel.text = [NSString stringWithFormat:@"列：%d", (int)self.colSte.value];
    UIImage *img = [self.smallImageView.image kj_imageTiledWithTiledType:(tiledType) TargetImageSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width) Row:self.rowSte.value Col:self.colSte.value];
    self.imageView.image = img;
}
- (IBAction)button:(UIButton *)sender {
    self.smallImageView.image = [self.smallImageView.image kj_rotationImageWithOrientation:(UIImageOrientationLeft)];
    UIImage *img = [self.smallImageView.image kj_imageTiledWithTiledType:(tiledType) TargetImageSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width) Row:self.rowSte.value Col:self.colSte.value];
    self.imageView.image = img;
}
- (IBAction)hua:(UIStepper *)sender {
    tiledType = sender.value;
    self.label.text = [NSString stringWithFormat:@"当前对花：%@", KJImageTiledTypeStringMap[tiledType]];
    UIImage *img = [self.smallImageView.image kj_imageTiledWithTiledType:(tiledType) TargetImageSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width) Row:self.rowSte.value Col:self.colSte.value];
    self.imageView.image = img;
}

@end
