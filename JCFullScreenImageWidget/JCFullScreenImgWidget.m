//
//  JCFullScreenImgWidget.m
//  JCFullScreenImageWidgetDemo
//
//  Created by jimple on 14-1-13.
//  Copyright (c) 2014年 Jimple Chen. All rights reserved.
//

#import "JCFullScreenImgWidget.h"
#import "GlobalDefine.h"
#import "RemoteImgListOperator.h"
#import "JCMultiFullScreenImgView.h"


@interface JCFullScreenImgWidget ()
<JCMultiFullScreenImgViewDelegate>

@property (nonatomic, readonly) RemoteImgListOperator *m_objImgListOper;
@property (nonatomic, readonly) NSMutableArray *m_arrHostView;
@property (nonatomic, readonly) NSMutableArray *m_arrImgURL;
@property (nonatomic, readonly) JCMultiFullScreenImgView *m_viewFullScreenImg;


@end

@implementation JCFullScreenImgWidget
@synthesize m_objImgListOper = _objImgListOper;
@synthesize m_arrHostView = _arrHostView;
@synthesize m_arrImgURL = _arrImgURL;
@synthesize m_viewFullScreenImg = _viewFullScreenImg;

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }else{}
    return self;
}

- (void)dealloc
{
}

- (void)clearHost
{
    if (_arrHostView)
    {
        for (UIView *viewHost in _arrHostView)
        {
            //  -- ! -- 这里会把所有手势都移除，若寄主view有定义其它手势，则需修改为只移除点按手势。
            NSArray *arrGesture = [NSArray arrayWithArray:viewHost.gestureRecognizers];
            for (UIGestureRecognizer *gesture in arrGesture)
            {
                [viewHost removeGestureRecognizer:gesture];
            }
        }
    }else{}
    
    _viewFullScreenImg = nil;
    _arrHostView = nil;
    _arrImgURL = nil;
    _objImgListOper = nil;
}

- (void)setHostImgView:(UIImageView *)imgView singleLargeImgURL:(NSString *)strImgURL remoteImgListOper:(RemoteImgListOperator *)objImgListOper
{
    if (imgView && strImgURL && objImgListOper)
    {
        [self setHostImgViews:@[imgView] multiLargeImgURLArr:@[strImgURL] remoteImgListOper:objImgListOper];
    }else{APP_ASSERT_STOP}
}

- (void)setHostImgViews:(NSArray *)arrImgView multiLargeImgURLArr:(NSArray *)arrImgURL remoteImgListOper:(RemoteImgListOperator *)objImgListOper
{
    if (arrImgView && arrImgURL && objImgListOper
        && (arrImgView.count == arrImgURL.count))
    {
        APP_ASSERT(arrImgView.count > 0);
        [self clearHost];
        
        _arrHostView = [[NSMutableArray alloc] initWithArray:arrImgView];
        _arrImgURL = [[NSMutableArray alloc] initWithArray:arrImgURL];
        
        _objImgListOper = objImgListOper;
        
        [self addTapGestureToHost];
    }else{APP_ASSERT_STOP}
}

#pragma mark MultiFullScreenImgViewDelegate
- (void)fullScreenViewNeedClose:(JCMultiFullScreenImgView *)view
{
    [self closeFullScreenImg];
}

#pragma mark -
- (void)addTapGestureToHost
{
    APP_ASSERT(_arrHostView && _arrImgURL && (_arrHostView.count == _arrImgURL.count));
    for (UIView *view in _arrHostView)
    {
        view.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapHostView:)];
        [view addGestureRecognizer:tapGesture];
    }
}

- (void)handleTapHostView:(UITapGestureRecognizer *)gesture
{
    NSInteger iNum = [self viewIndex:gesture.view inArr:_arrHostView];
    if (iNum >= 0)
    {
        if (!_viewFullScreenImg)
        {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            if (!window)
            {
                window = [[UIApplication sharedApplication].windows objectAtIndex:0];
            }else{}
            _viewFullScreenImg = [[JCMultiFullScreenImgView alloc] initWithFrame:window.bounds];
            _viewFullScreenImg.delegate = self;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToClose:)];
            [_viewFullScreenImg addGestureRecognizer:tap];
            
            [window addSubview:_viewFullScreenImg];
        }else{}
        
        _viewFullScreenImg.alpha = 1.0f;
        [_viewFullScreenImg showImgs:_arrImgURL atIndex:iNum remoteImgStackOper:_objImgListOper];
    }else{}
}

- (NSInteger)viewIndex:(UIView *)view inArr:(NSArray *)arrViews
{
    NSInteger iRet = -1;
    
    if (view && arrViews)
    {
        for (int i = 0; i < arrViews.count; i++)
        {
            if (view == arrViews[i])
            {
                iRet = i;
                break;      // ! break loop
            }else{}
        }
    }else{APP_ASSERT_STOP}
    return iRet;
}

- (void)handleTapToClose:(id)sender
{
    [self closeFullScreenImg];
}

- (void)closeFullScreenImg
{
    [UIView animateWithDuration:0.2f animations:^()
     {
         _viewFullScreenImg.alpha = 0.01f;
     }completion:^(BOOL f)
     {
         if (_viewFullScreenImg)
         {
             [_viewFullScreenImg removeFromSuperview];
             _viewFullScreenImg = nil;
         }else{}
     }];
}





@end
