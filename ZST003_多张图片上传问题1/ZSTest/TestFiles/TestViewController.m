//
//  TestViewController.m
//  Test
//
//  Created by zhoushuai on 16/3/7.
//  Copyright © 2016年 zhoushuai. All rights reserved.
//

#import "TestViewController.h"
#import "PicturesView.h"

@interface TestViewController ()<UIScrollViewDelegate,AdjustPicturesViewChangeDelegate>
//水平和垂直间距
@property (assign,nonatomic)CGFloat horizontalPadding;
@property (assign,nonatomic)CGFloat verticalPadding;

//已将添加的图片构成的数组
@property (strong, nonatomic) NSMutableArray *imageArray;


@property (strong,nonatomic)PicturesView *picturesView;
@property (strong,nonatomic)UIButton *publishBtn;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"测试图片多选";
    self.view.backgroundColor = [UIColor purpleColor];
    self.navigationController.navigationBar.translucent = NO;
    //初始化设置
    [self _initViews];
}



- (void)_initViews{
    //滑动视图
    _mainScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _mainScrollView.backgroundColor = [UIColor whiteColor];
    _mainScrollView.showsHorizontalScrollIndicator =NO;
    _mainScrollView.showsVerticalScrollIndicator = NO;
    _mainScrollView.delegate =self;
    [self.view addSubview:_mainScrollView];


    _horizontalPadding = 20;
    _verticalPadding = 20;
    
    _imageArray = [NSMutableArray array];

     //显示图片的视图的宽度
     //可以根据pad和iphone的不同使用情况，调整添加图片一行显示多少个图片
    CGFloat rowItemCout = 0;
    CGFloat imageWidth = 0;
     if (kDeviceWidth==320) {
         //每行行显示3个
         rowItemCout = 3;
         imageWidth = (kDeviceWidth -(_horizontalPadding*2) -4*10)/3;
      }else{
        rowItemCout = 4;
        imageWidth = (kDeviceWidth -(_horizontalPadding*2) -5*10)/4;
      }
    
    _picturesView = [[PicturesView alloc] initWithFrame:CGRectMake(_horizontalPadding , _verticalPadding,kDeviceWidth-_horizontalPadding*2, imageWidth +10*2)];
    _picturesView.backgroundColor = [UIColor orangeColor];
    //设定每行的个数
    _picturesView.rowItemCount = rowItemCout;
    //最多上传的个数
    _picturesView.upLoadLimit_max = 12;
    //设置图片之间的间距
    _picturesView.cellPadding = 10;
    //设置所在视图控制器
    _picturesView.supVC = self;
    _picturesView.delegate = self;
    _picturesView.layer.cornerRadius = 5;
    _picturesView.layer.masksToBounds = YES;
    [_mainScrollView addSubview:_picturesView];
    //初始没有图片数据
    [_picturesView resetSubViewsWith:_imageArray];
    
    _publishBtn = [[UIButton alloc] initWithFrame:CGRectMake((kDeviceWidth -100)/2, _picturesView.frame.origin.y+_picturesView.frame.size.height + 50, 100, 50)];
    [_publishBtn setTitle:@"发布" forState:UIControlStateNormal];
    [_publishBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [_publishBtn addTarget:self action:@selector(publishBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_mainScrollView addSubview:_publishBtn];
    
}



#pragma mark -  响应事件
- (void)publishBtnClick:(UIButton *)btn{
    NSLog(@"得到选中图片%@",_picturesView.imageArray);
}



#pragma mark - 代理，调整布局
- (void)resetForPicturesViewChange:(CGFloat)picturesViewHeight{
    _imageArray = self.picturesView.imageArray;
    _publishBtn.frame = CGRectMake((kDeviceWidth -100)/2, _picturesView.frame.origin.y +picturesViewHeight +50, 100, 50);
}



 @end
