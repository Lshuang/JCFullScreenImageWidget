//
//  JCRemoteImgScrlPageView.h
//  JCFullScreenImageWidgetDemo
//
//  Created by jimple on 14-1-13.
//  Copyright (c) 2014年 Jimple Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RemoteImgListOperator;
@interface JCRemoteImgScrlPageView : UIView


- (void)prepareForReuse;
- (void)setImgListOper:(RemoteImgListOperator *)objOper;

- (void)resetImg:(NSString *)strImgURL;








@end
