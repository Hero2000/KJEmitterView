//
//  KJLamplightVC.m
//  KJEmitterView
//
//  Created by 杨科军 on 2020/6/3.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "KJLamplightVC.h"
#import "KJLamplightLayer.h"
@interface KJLamplightVC ()
@property(nonatomic,strong) KJLamplightModel *lamplightModel;
@property(nonatomic,strong) KJLamplightLayer *lamplightLayer;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIStepper *ste;
@property (weak, nonatomic) IBOutlet UISlider *slider1;
@property (weak, nonatomic) IBOutlet UISlider *slider2;
@property (weak, nonatomic) IBOutlet UISlider *slider3;
@property (weak, nonatomic) IBOutlet UISlider *slider4;
@end

@implementation KJLamplightVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGFloat w = 375;//self.view.size.width;
    CGFloat h = self.view.size.height;
    KJKnownPoints points = {
        CGPointMake(50, 64+20),
        CGPointMake(20, h/2),
        CGPointMake(w-30, h/2-50),
        CGPointMake(w-20, 64+100),
    };
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = [UIColor.redColor colorWithAlphaComponent:0.1].CGColor;
    shapeLayer.strokeColor = UIColor.redColor.CGColor;
    shapeLayer.lineWidth = 2;
    shapeLayer.lineJoin = kCALineJoinRound;// 连接节点样式
    shapeLayer.lineCap = kCALineCapRound;// 线头样式
    shapeLayer.path = ({
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:points.PointA];
        [path addLineToPoint:points.PointB];
        [path addLineToPoint:points.PointC];
        [path addLineToPoint:points.PointD];
        [path closePath]; /// 闭合路径
        path.CGPath;
    });
    [self.view.layer addSublayer:shapeLayer];
    
    _weakself;
    self.lamplightLayer = [[KJLamplightLayer alloc]kj_initWithKnownPoints:points];
    [self.view.layer addSublayer:self.lamplightLayer];
    self.lamplightLayer.kAngleChangeSizeBlock = ^(CGFloat lamplightSize) {
        weakself.slider3.value = lamplightSize;
    };
    self.slider3.minimumValue = self.lamplightLayer.canvasWidth * 0.05;
    self.slider3.maximumValue = self.lamplightLayer.canvasWidth * 0.5;
    self.slider4.minimumValue = self.lamplightLayer.canvasWidth * 0.05;
    self.slider4.maximumValue = self.lamplightLayer.canvasWidth * 0.5;
    self.slider3.value = self.lamplightLayer.canvasWidth * 0.15;
    self.slider4.value = self.lamplightLayer.canvasWidth * 0.1;
    self.ste.value = 4;
    self.label.text = [NSString stringWithFormat:@"个数：%d",(int)self.ste.value];
    
    self.lamplightModel = [[KJLamplightModel alloc]init];
    _lamplightModel.lamplightImage = [UIImage imageNamed:@"IMG_4931"];
    _lamplightModel.lamplightAngle = self.slider1.value;
    _lamplightModel.lamplightMoveY = self.slider2.value;
    _lamplightModel.lamplightSize = self.slider3.value;
    _lamplightModel.lamplightSpace = self.slider4.value;
    _lamplightModel.lamplightNumber = self.ste.value;
    [self kj_xxx];
}
- (void)kj_xxx{
    [self.lamplightLayer kj_addLayerWithLamplightModel:self.lamplightModel PerspectiveBlock:^UIImage * _Nonnull(KJKnownPoints points, UIImage * _Nonnull jointImage) {
        UIImage *img = [jointImage kj_softFitmentFluoroscopyWithTopLeft:points.PointA TopRight:points.PointD BottomRight:points.PointC BottomLeft:points.PointB];
        return img;
    }];
}
- (IBAction)buttonSender:(UIButton *)sender {
    self.lamplightModel.lamplightImage = sender.imageView.image;
    [self kj_xxx];
}
- (IBAction)steSender:(UIStepper *)sender {
    self.label.text = [NSString stringWithFormat:@"个数：%d",(int)sender.value];
    self.lamplightModel.lamplightNumber = (NSInteger)sender.value;
    [self kj_xxx];
}
- (IBAction)sliderSender:(UISlider *)sender {
    switch (sender.tag) {
            case 500:/// 角度
            self.lamplightModel.lamplightAngle = sender.value;
            break;
            case 501:/// 平移
            self.lamplightModel.lamplightMoveY = sender.value;
            break;
            case 502:/// 大小
            self.lamplightModel.lamplightSize = sender.value;
            break;
            case 503:/// 间隔
            self.lamplightModel.lamplightSpace = sender.value;
            break;
            default:
                break;
        }
        [self kj_xxx];
}

@end
