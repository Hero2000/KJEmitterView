# KJEmitterView
![coverImage](https://upload-images.jianshu.io/upload_images/1933747-b7e843a01999b9a9.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

* 这个工程提供开发中用到的类目，方便开发
* 这里有我经常用到的扩展，方便好用开发
* 整理好用的自定义控件，部分数据来源于网络 

<p align="left">
<img src="https://upload-images.jianshu.io/upload_images/1933747-239364ee4c736ec5.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" width="200" hspace="1px">
<img src="https://upload-images.jianshu.io/upload_images/1933747-6561a3bae67f461a.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" width="200" hspace="30px">
<img src="https://upload-images.jianshu.io/upload_images/1933747-5fee5e92f2df341d.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" width="200" hspace="1px">
</p>

<p align="left">
<img src="https://upload-images.jianshu.io/upload_images/1933747-6b51769f19338dba.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" width="200" hspace="1px">
<img src="https://upload-images.jianshu.io/upload_images/1933747-6cc69b6c96f252e0.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" width="200" hspace="30px">
<img src="https://upload-images.jianshu.io/upload_images/1933747-f75249465cc14d81.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" width="200" hspace="1px">
</p>

<p align="left">
<img src="https://upload-images.jianshu.io/upload_images/1933747-9385d8d7fb2909d0.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" width="200" hspace="1px">
<img src="https://upload-images.jianshu.io/upload_images/1933747-372ef40fe388d844.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" width="200" hspace="30px">
<img src="https://upload-images.jianshu.io/upload_images/1933747-f147b4553be64856.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" width="200" hspace="1px">
</p>

<p align="left">
<img src="https://upload-images.jianshu.io/upload_images/1933747-ea61b0e9dfe9b6ca.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" width="200" hspace="1px">
<img src="https://upload-images.jianshu.io/upload_images/1933747-b5c171bee7c7bae5.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" width="200" hspace="30px">
<img src="https://upload-images.jianshu.io/upload_images/1933747-3a5a89ada127313b.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" width="200" hspace="1px">
</p>

<p align="left">
<img src="https://upload-images.jianshu.io/upload_images/1933747-b06d24effbdb86ab.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" width="200" hspace="1px">
<img src="https://upload-images.jianshu.io/upload_images/1933747-8e01116d67e820ad.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" width="200" hspace="30px">
<img src="" width="200" hspace="30px">
</p>

----------------------------------------
### 框架整体介绍
* [作者信息](#作者信息)
* [作者其他库](#作者其他库)
* [功能介绍](#功能介绍)
* [Cocoapods安装](#Cocoapods安装)
* [更新日志](#更新日志)
* [效果图](#效果图)
* [目录结构](#目录结构)
* [打赏作者 &radic;](#打赏作者)

----------------------------------------

#### <a id="作者信息"></a>作者信息
> Github地址：https://github.com/yangKJ  
> 简书地址：https://www.jianshu.com/u/c84c00476ab6  
> 博客地址：https://blog.csdn.net/qq_34534179  


#### <a id="作者其他库"></a>作者其他Pod库
```
/*
*********************************************************************************
*
*⭐️⭐️⭐️ ----- 本人其他库 ----- ⭐️⭐️⭐️
*
- 粒子效果、Button图文混排、点击事件封装、扩大点击域、点赞粒子效果，
- 手势封装、圆角渐变、倒影、投影、内阴影、内外发光处理、Xib属性，
- 图片加工处理、滤镜渲染、泛洪算法、识别网址超链接等等
- 脚线处理、地板拼接处理、墙纸铺贴处理、吊顶处理
pod 'KJEmitterView'
pod 'KJEmitterView/InteriorFinish' # 装修控件
pod 'KJEmitterView/Function'#
pod 'KJEmitterView/Control' # 自定义控件

播放器 - KJPlayer是一款视频播放器，AVPlayer的封装，继承UIView
- 视频可以边下边播，把播放器播放过的数据流缓存到本地，下次直接从缓冲读取播放
pod 'KJPlayer'  # 播放器功能区
pod 'KJPlayer/KJPlayerView'  # 自带展示界面

轮播图 - 支持缩放 多种pagecontrol 支持继承自定义样式 自带网络加载和缓存
pod 'KJBannerView'  # 轮播图，网络图片加载 支持网络GIF和网络图片和本地图片混合轮播

加载Loading - 多种样式供选择 HUD控件封装
pod 'KJLoadingAnimation' # 加载控件

菜单控件 - 下拉控件 选择控件
pod 'KJMenuView' # 菜单控件

工具库 - 推送工具、网络下载工具、识别网页图片工具等
pod 'KJWorkbox' # 系统工具
pod 'KJWorkbox/CommonBox'

* 如果觉得好用,希望您能Star支持,你的 ⭐️ 是我持续更新的动力!
*
*********************************************************************************
*/
```

##### Issue
如果您在使用中有好的需求及建议，或者遇到什么bug，欢迎随时issue，我会及时的回复，有空也会不断优化更新这些库

#### <a id="Cocoapods安装"></a>Cocoapods安装
```
pod 'KJEmitterView'
pod 'KJEmitterView/InteriorFinish' # 装修控件
pod 'KJEmitterView/Function'#
pod 'KJEmitterView/Control' # 自定义控件
```

#### <a id="更新日志"></a>更新日志
```
####版本更新日志:
#### Add 4.7.4
1、KJMuralView 新增壁画
2、KJFloorJoint 地板拼接
3、KJWallpaperPave 墙纸铺贴
4、_KJIFinishTools 装修公共类

#### Add 4.7.1
1、UIView+KJGestureBlock 新增单指双击操作
2、NSObject+KJGeometry 新增几何方程式算法
3、KJSuspendedView 新增吊顶操作
4、KJLegWireLayer 新增脚线处理
5、重新整理装修类归纳到InteriorFinish

#### Add 4.6.9
1、UIImage+KJPhotoshop 新增 CoreImage 框架多种滤镜效果
2、UIImage+KJPhotoshop 新增透视和透视矫正处理
3、UIImage+KJPave 修改横竖倒角选择操作

#### Add 4.6.8
1、KJShadowLayer 完善外发光、外阴影、内发光

#### Add 4.6.7
1、UIView+KJShadow 移出，修改至KJShadowLayer
2、KJShadowLayer 继承CALayer的阴影、发光处理
3、UIImage+KJPave 新增地板拼接处理、获取图片指定区域、横向和纵向裁剪图片

#### Add 4.6.6
1、UIImage+KJProcessing 新增屏幕截图 kj_captureScreenWindow
2、UIImage+KJProcessing 新增多边形切图 kj_polygonCaptureImageWithImageView:PointArray:
3、UIImage+KJProcessing 新增不规则图形切图 kj_anomalyCaptureImageWithView:BezierPath
4、UIImage+KJCompressJoint 新增图片拼接处理
5、CALayer+KJReflection 新增倒影处理

#### Add 4.6.4
1、UIView+KJShadow 新增一套计算阴影角度的算法
2、UIView+KJShadow 修改内发光kj_aroundInnerShine

#### Add 4.6.3
1、UIButton+KJCountDown 新增倒计时按钮
2、UITextView+KJHyperlink 返回超链接数据
3、UIButton+KJEnlargeTouchArea 新增touchAreaInsets扩大点击域属性
4、UIView+KJShadow 阴影相关操作

#### Add 4.6.2
1、UIButton+KJEmitter 新增设置粒子图片属性
2、UIColor+KJExtension 新增颜色相关扩展 - 渐变色处理
3、UIImage+KJRemoteSize 新增获取网络图片尺寸 - 来源作者shaojiankui

#### Add 4.6.0
1、UIViewController+KJFullScreen 解决ios13以后 presentViewController 过去的控制器可以滑动和顶部少一截问题
2、UISegmentedControl+KJCustom 解决ios13以后 修改不了 backgroundColor 和 tintColor 问题
3、UIImage+KJProcessing 新增 kj_captureScreen 指定位置屏幕截图
4、UIImage+KJProcessing 新增图片压缩方法 kj_compressImage:TargetByte:
5、UIButton+KJEmitter 新增一款粒子点赞效果 kj_openButtonEmitter是否开启点赞粒子
6、NSObject+KJMath 新增数学方程式扩展
7、UITextView+KJHyperlink 新增超链接处理

#### Add 4.5.4
1、KJEmitterLayer 重新整理封装一款图片粒子动画 - 来源作者xx
2、UIImage+KJProcessing 新增 kj_cutImageWithImage 根据特定的区域对图片进行裁剪
3、UIImage+KJProcessing 新增 kj_calulateImageFileSize 获取图片
4、UIButton+KJBlock 新增 接受点击事件的时间间隔属性 kj_AcceptEventTime
5、新增常用方法函数 _KJINLINE

#### Add 4.5.3
1、UIImage+KJProcessing 新增 kj_jointImageWithMasterImage 拼接图片
2、UIImage+KJProcessing 新增 kj_imageCompoundWithLocalImage 图片多次合成处理
3、UIImage+KJProcessing 新增 kj_rotationImageWithOrientation 图片旋转

#### Add 4.5.0
1、NSArray+ElementDeal 新增对数组元素的处理 包括排序、查找、去重等等
2、整理富文本扩展 UILabel+KJAttributedString

#### Add 4.4.5
1、修改bug，修改更明显的提示内容

#### Add 4.3.9
1、修改Bug
2、NSMutableArray当中新增 处理空对象方法交换
3、Function文件夹中新增 NSString+KJStringDebug 解决字典 或者 数组 每次都崩溃到 Main函数，无法定位到位置的问题

#### Add 4.3.8
1、Function文件夹中新增 NSDictionary+KJNilSafe 字典防止键和值为空的时候崩溃
2、Function文件夹中新增 NSArray+KJOverstep 数组解决数组越界异常崩溃问题
3、Function文件夹中新增 NSNull+KJSafe 解决后台返回数据为空造成程序崩溃

#### Add 4.3.7
1、新增画一些指定图形 UIView+KJAppointView （直线、虚线、五角星、六边形、八边形）

#### Add 4.3.5
1、新增改变UIButton的响应区域 扩大点击域 UIButton+KJEnlargeTouchArea
2、重新将宏转移到 _KJMacros 文件
3、全部文件都引入 NS_ASSUME_NONNULL_BEGIN 宏
4、UIView+KJXib 新增高效查找子视图方法 kj_FindSubviewRecursively

#### Add 4.3.3
1、修改单例宏  kSingletonImplementation_H
2、添加一些宏的高级用法
3、新增手势Block UIView+KJGestureBlock

#### Add 4.3.0
1、KJMacros 重新整理放入 KJEmitterHeader当中
2、KJEmitterHeader 新增一些好用的方法

#### Add 4.2.2
1、引入自己常用宏 KJMacros

#### Add 4.2.1
1、暂时移出UIView+KJXib中布局相关
2、移出UINavigationController+FDFullscreenPopGesture
3、默认只引入Kit里面的文件
4、重新整理Control、Classes和Foundation独立为文件夹

#### Add 4.1.0
1、整理新增控件类 Control
2、KJSelectControl   自定义一款动画选中控件 - 来源参考作者Creativedash's Dribbble
3、KJSwitchControl   自定义一款可爱的动画Switch控件 - 来源作者FunnySwitch
4、KJMarqueeLabel    自定义一款跑马灯Label
5、UINavigationController+FDFullscreenPopGesture 侧滑返回扩展

##### Add 4.0.0
1、加入弱引用宏 kWeakObject 和 kStrongObject
2、新增扩展 UIButton+KJBlock 点击事件ButtonBlock
3、新增扩展 UILabel+KJAttributedString   富文本
4、UIView+KJFrame   新增一些轻量级布局链式属性
5、UIView+KJRectCorner  新增方法  虚线边框  kj_DashedLineColor

备注：部分资料来源于网络～  就不一一指出道谢，整理起来方便自己和大家使用
```
#### <a id="效果图"></a>效果图
<p align="left">
<img src="https://upload-images.jianshu.io/upload_images/1933747-2200e0b4cf71f88f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" width="300" hspace="1px">
</p>

#### 温馨提示
#####1、使用第三方库Xcode报错  
Cannot synthesize weak property because the current deployment target does not support weak references  
可在`Podfile`文件底下加入下面的代码，'8.0'是对应的部署目标（deployment target） 删除库重新Pod  
不支持用weak修饰属性，而weak在使用ARC管理引用计数项目中才可使用  
遍历每个develop target，将target支持版本统一设成一个支持ARC的版本

```
##################加入代码##################
# 使用第三方库xcode报错Cannot synthesize weak property because the current deployment target does not support weak references
post_install do |installer|
installer.pods_project.targets.each do |target|
target.build_configurations.each do |config|
config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '8.0'
end
end
end
##################加入代码##################
```
#####2、若搜索不到库
- 方案1：可执行 pod repo update
- 方案2：使用 rm ~/Library/Caches/CocoaPods/search_index.json 移除本地索引然后再执行安装
- 方案3：更新一下 CocoaPods 版本


#### <a id="打赏作者"></a>打赏作者
* 如果你觉得有帮助，还请为我Star
* 如果在使用过程中遇到Bug，希望你能Issues，我会及时修复
* 大家有什么需要添加的功能，也可以给我留言，有空我将补充完善
* 谢谢大家的支持 - -！

[![谢谢老板](https://upload-images.jianshu.io/upload_images/1933747-879572df848f758a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)](https://github.com/yangKJ/KJPlayerDemo)

#### 救救孩子吧，谢谢各位老板～～～～

