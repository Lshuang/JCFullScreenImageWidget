//
//  JCFullScreenImgWidget.h
//  JCFullScreenImageWidgetDemo
//
//  Created by jimple on 14-1-13.
//  Copyright (c) 2014年 Jimple Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RemoteImgListOperator;
@interface JCFullScreenImgWidget : NSObject

// 单图
- (void)setHostImgView:(UIImageView *)imgView singleLargeImgURL:(NSString *)strImgURL remoteImgListOper:(RemoteImgListOperator *)objImgListOper;

// 多图
// 视图数组与图片URL数组中，视图与URL序号应该一一对应。
- (void)setHostImgViews:(NSArray *)arrImgView multiLargeImgURLArr:(NSArray *)arrImgURL remoteImgListOper:(RemoteImgListOperator *)objImgListOper;

// 清除寄主，用于TableViewCell中重用Cell。
- (void)clearHost;



@end
