//
//  PicturesView.h
//  ZSTest
//
//  Created by zhoushuai on 16/3/9.
//  Copyright © 2016年 zhoushuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AdjustPicturesViewChangeDelegate <NSObject>
//图片视图变化之后，可以使用代理方法调整其所在视图的视图位置
- (void)resetForPicturesViewChange:(CGFloat)picturesViewHeight;

@end


@interface PicturesView : UIView<UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>

//图片数组
@property (nonatomic,strong)NSMutableArray *imageArray;
//图片的宽高
@property(strong,nonatomic)NSMutableDictionary *imgPropertyDic;
//图片的链接
@property(strong,nonatomic)NSMutableDictionary *imageLinkDic;

//添加图片的视图，视图的宽度
@property (assign,nonatomic)CGFloat imageWidth;
//每行的图片的个数
@property (assign,nonatomic)NSInteger rowItemCount;
//制定图片之间的间距
@property(assign,nonatomic)NSInteger cellPadding;

//至少上传图片的个数
@property(assign,nonatomic)NSInteger upLoadLimit_min;
//最多上传图片的个数
@property(assign,nonatomic)NSInteger upLoadLimit_max;

//当前正在操作的图片
@property(assign,nonatomic)NSInteger imgageCurrentIndex;
//所在视图控制器
@property (strong,nonatomic)UIViewController *supVC;


@property (assign,nonatomic)id<AdjustPicturesViewChangeDelegate>  delegate;



- (void)resetSubViewsWith:(NSMutableArray *)imageArray;

@end
