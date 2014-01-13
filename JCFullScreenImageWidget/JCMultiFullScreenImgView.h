//
//  JCMultiFullScreenImgView.h
//  JCFullScreenImageWidgetDemo
//
//  Created by jimple on 14-1-13.
//  Copyright (c) 2014年 Jimple Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JCMultiFullScreenImgView;
@protocol JCMultiFullScreenImgViewDelegate <NSObject>

- (void)fullScreenViewNeedClose:(JCMultiFullScreenImgView *)view;

@end

@class RemoteImgListOperator;
@interface JCMultiFullScreenImgView : UIView
@property (unsafe_unretained) id<JCMultiFullScreenImgViewDelegate> delegate;


- (void)showImgs:(NSArray *)arrImgURL atIndex:(NSInteger)iIndex remoteImgStackOper:(RemoteImgListOperator *)objImgListOper;



@end
