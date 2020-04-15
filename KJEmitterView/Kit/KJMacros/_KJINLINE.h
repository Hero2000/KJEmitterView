//
//  _KJINLINE.h
//  KJEmitterView
//
//  Created by 杨科军 on 2019/10/10.
//  Copyright © 2019 杨科军. All rights reserved.
//

#ifndef _KJINLINE_h
#define _KJINLINE_h

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>

/** 这里只适合放简单的函数 */
NS_ASSUME_NONNULL_BEGIN

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

/** 自定提醒窗口 */
NS_INLINE UIAlertView * kAlertView(NSString *title, NSString *message, id delegate, NSString *cancelTitle, NSString *otherTitle){
    __block UIAlertView *alerView;
    dispatch_async(dispatch_get_main_queue(), ^{
        alerView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelTitle otherButtonTitles:otherTitle, nil];
        [alerView show];
    });
    return alerView;
}

/** 自定提醒窗口，自动消失 */
NS_INLINE void kAlertViewAutoDismiss(NSString *message, CGFloat delay){
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alerView show];
        [alerView performSelector:@selector(dismissWithClickedButtonIndex:animated:) withObject:@[@0, @1] afterDelay:delay];
    });
}

/** 校正ScrollView在iOS11上的偏移问题 */
NS_INLINE void kAdjustsScrollViewInsetNever(UIViewController *viewController, __kindof UIScrollView *tableView) {
#if __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        viewController.automaticallyAdjustsScrollViewInsets = false;
    }
#else
    viewController.automaticallyAdjustsScrollViewInsets = false;
#endif
}

// 字符串转换为非空
NS_INLINE NSString * kStringChangeNotNil(NSString *string){
    return (string ?: @"");
}

/// 随机颜色
NS_INLINE UIColor * kRandomColor(){
    return [UIColor colorWithRed:((float)arc4random_uniform(256)/255.0) green:((float)arc4random_uniform(256)/255.0) blue:((float)arc4random_uniform(256)/255.0) alpha:1.0];
}

/** 系统加载动效 */
NS_INLINE void kNetworkActivityIndicatorVisible(BOOL visible) {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = visible;
}

/** 通过xib名称加载cell */
NS_INLINE id kLoadNibWithName(NSString *name, id owner){
   return [[NSBundle mainBundle] loadNibNamed:name owner:owner options:nil].firstObject;
}

// 加载xib
NS_INLINE id kLoadNib(NSString *nibName){
    return [UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]];
}

/* 根据当前view 找所在tableview 里的 indexpath */
NS_INLINE NSIndexPath * kIndexpathSubviewTableview(UIView *subview, UITableView *tableview){
    CGRect subviewFrame = [subview convertRect:subview.bounds toView:tableview];
    return [tableview indexPathForRowAtPoint:subviewFrame.origin];
}

/* 根据当前view 找所在collectionview 里的 indexpath */
NS_INLINE NSIndexPath * kIndexpathSubviewCollectionview(UIView *subview, UICollectionView *collectionview){
    CGRect subviewFrame = [subview convertRect:subview.bounds toView:collectionview];
    return [collectionview indexPathForItemAtPoint:subviewFrame.origin];
}

/* 根据当前view 找所在tableview 里的 tableviewcell */
NS_INLINE UITableViewCell * kCellSubviewTableview(UIView *subview, UITableView *tableview){
    CGRect subviewFrame = [subview convertRect:subview.bounds toView:tableview];
    NSIndexPath *indexPath = [tableview indexPathForRowAtPoint:subviewFrame.origin];
    return [tableview cellForRowAtIndexPath:indexPath];
}

/** 主线程do */
NS_INLINE void KJ_GCD_main(dispatch_block_t block) {
    if (![[NSThread currentThread] isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), block);
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}
/** 交换方法的实现 */
NS_INLINE void KJ_method_swizzling(Class clazz, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector);
    if (class_addMethod(clazz, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(clazz, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


#pragma clang diagnostic pop

NS_ASSUME_NONNULL_END
#endif

#endif /* _KJINLINE_h */
