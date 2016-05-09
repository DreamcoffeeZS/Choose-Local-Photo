//
//  PicturesView.m
//  ZSTest
//
//  Created by zhoushuai on 16/3/9.
//  Copyright © 2016年 zhoushuai. All rights reserved.
//

#import "PicturesView.h"

@implementation PicturesView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initViews];
    }
    return self;
}

//初始化视图组件
- (void)_initViews{
    
}


//得到新的数据,重新设置视图
- (void)resetSubViewsWith:(NSMutableArray *)imageArray{
    _imageArray = imageArray;
    [self resetAddViewItems];
}


- (void)resetAddViewItems
{
    //清空所有子视图
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    //计算单个视图的宽度
    CGFloat viewWidth = self.frame.size.width;
    _imageWidth = (viewWidth - _cellPadding *(_rowItemCount +1))/_rowItemCount;
    
    //没有图片,显示一个可以点击的按钮
    if (_imageArray.count==0) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(_cellPadding, _cellPadding, _imageWidth, _imageWidth)];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.image = [UIImage imageNamed:@"activityAddImg"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 0;
        [button setFrame:imgView.frame];
        [button addTarget:self action:@selector(addImageBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:imgView];
        [self addSubview:button];
        
    }else {
        NSInteger imagesCount  = self.imageArray.count;
        //如果没有达到最大数就要在最后显示一个增加图片的按钮
        NSInteger viewsCount =imagesCount;
        if(imagesCount<_upLoadLimit_max){
            viewsCount = viewsCount +1;
        }
        //计算行与列
        NSInteger row = 0;
        NSInteger col = 0;
        if ((viewsCount % _rowItemCount) == 0) {
            row = viewsCount/_rowItemCount;
        }else{
            row = viewsCount/_rowItemCount +1;
        }
        
        //确认添加图片的视图的大小
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width,_cellPadding +row*(_imageWidth +_cellPadding));
        
        
        //开始添加图片
        row = 0;
        col = 0;
        for (NSInteger i = 0; i<viewsCount; i++) {
            //当前的行数
            if((i%_rowItemCount) == 0){
                row ++;
            }
            //当前列
            col =i %_rowItemCount;
            
            //显示图片
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(col*(_imageWidth +_cellPadding)+_cellPadding, (row -1) *(_imageWidth +_cellPadding)+_cellPadding, _imageWidth, _imageWidth)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            //最后一张添加图片
            if (i == self.imageArray.count) {
                //如果是用于添加图片的按钮
                imageView.image = [UIImage imageNamed:@"activityAddImg"];
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.tag = self.imageArray.count;
                [button setFrame:imageView.frame];
                [button addTarget:self action:@selector(addImageBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:imageView];
                [self addSubview:button];
                return;
            }
            
            //否则显示正常的图片
            UIImage *image = self.imageArray[i];
            imageView.image = image;
            [self addSubview:imageView];
            //同时正常图片也可点击更换
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:imageView.frame];
            button.tag = i;
            [button addTarget:self action:@selector(addImageBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:imageView];
            [self addSubview:button];
        }
    }
}



#pragma mark - 代理方法：UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    NSLog(@"UIImage:width：%f,height:%f",image.size.width,image.size.height);
    if (_imgageCurrentIndex == 0) {
        if(_imageArray.count == 0){
            //保存图片对象
            [self.imageArray addObject:image];
            //上传图片,保存图片的链接
            [self uploadSelectedImage:image withIndex:0];
        }else{
            //删除原来的图片，插入新图片
            [self.imageArray removeObjectAtIndex:0];
            [self .imageArray insertObject:image atIndex:0];
            [self uploadSelectedImage:image withIndex:0];
        }
        
    }else if(_imgageCurrentIndex == [_imageArray count]){
        //点击了最后一个添加按钮
        [self.imageArray addObject:image];
        //上传图片,保存图片的链接
        [self uploadSelectedImage:image withIndex:self.imageArray.count -1];
    }else{
        //中间的图片
        [self.imageArray removeObjectAtIndex:_imgageCurrentIndex];
        [self.imageArray insertObject:image atIndex:_imgageCurrentIndex];
        [self uploadSelectedImage:image withIndex:_imgageCurrentIndex];
    }
    
    [self resetSubViewsWith:_imageArray];
    if([self.delegate respondsToSelector:@selector(resetForPicturesViewChange:)]){
        [self.delegate resetForPicturesViewChange:self.frame.size.height];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.supVC dismissViewControllerAnimated:YES completion:nil];
}





- (void)addImageBtnClick:(UIButton *)btn
{
    _imgageCurrentIndex = btn.tag;
    UIActionSheet *choosePhotoActionSheet;
    choosePhotoActionSheet = [[UIActionSheet alloc] initWithTitle:@"选择照片" delegate:self
                                                cancelButtonTitle:@"取消"
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:@"拍照", @"相册", nil];
    
    [choosePhotoActionSheet showInView:self.supVC.view];
}

//UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUInteger sourceType = 0;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] || [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        switch (buttonIndex) {
            case 0:
                if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                else{
                    //                    [NotificationManager notificationWithMessage:@"您的设备不支持照相功能"];
                    return;
                }
                break;
            case 1:
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            case 2:
                return;
        }
    } else {
        if (buttonIndex == 1) {
            return;
        } else {
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    [self.supVC presentViewController:imagePickerController animated:NO completion:nil];
}






#pragma mark - 有关网络部分的操作
//选择图片之后上传图片
- (void)uploadSelectedImage:(UIImage *)image withIndex:(NSInteger)index{
    {
        //避免图片太大，对图片压缩
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        NSLog(@"\n\n\n%.1luKB\n\n\n",(unsigned long)imageData.length/1024);
        //    //2M以下不压缩
        while (imageData.length/1024 > 2048) {
            imageData = UIImageJPEGRepresentation(image, 0.8);
            self.imageArray[index] = [UIImage imageWithData:imageData];
        }
        
    /*
        NSDictionary *dict = [AFParamFormat formatPostUploadParamWithFile:@"file"];
        [AFNetwork uploadPhoto:dict fileData:imageData success:^(id data){
            NSLog(@"uploadPhoto:%@ test SVN",data);
            //successCount++;
            //1.上传图片成功，得到图片链接，图片的宽和高
            NSDictionary *dic = data[@"data"];
            NSString *dictionURL = [NSString stringWithFormat:@"%@",dic[@"url"]];
            //2.保存图片链接
            [_imgLinkDic setObject:dictionURL forKey:[NSNumber numberWithInteger:index]];
            //3.以图片链接为key,保存图片的宽和高
            NSDictionary *tempDic = @{@"width":dic[@"width"],@"height":dic[@"height"]};
            [_imgPropertyDic setObject:tempDic forKey:dictionURL];
        }failed:^(NSError *error){
            // successCount++;
            NSLog(@"上传图片失败");
        }];
        
        */
        
    }
    
}

//重新布局
- (void)layoutSubviews{
    [super layoutSubviews];
    
}



@end
