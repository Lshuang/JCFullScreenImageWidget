//
//  JCRemoteImgScrlPageView.m
//  JCFullScreenImageWidgetDemo
//
//  Created by jimple on 14-1-13.
//  Copyright (c) 2014年 Jimple Chen. All rights reserved.
//

#import "JCRemoteImgScrlPageView.h"
#import "GlobalDefine.h"
#import "DACircularProgressView.h"
#import "RemoteImgListOperator.h"


#define STR_ClickToReloadFullScreenImgBtn                               @"下载失败，点击重新下载"


@interface JCRemoteImgScrlPageView ()
<
    UIScrollViewDelegate
>

@property (nonatomic, readonly, copy) NSString *m_strImgURL;
@property (nonatomic, readonly) UIScrollView *m_scrlView;
@property (nonatomic, readonly) UIImageView *m_imgViewImg;
@property (nonatomic, readonly) RemoteImgListOperator *m_objImgListOper;
@property (nonatomic, readonly) DACircularProgressView *m_viewProgress;
@property (nonatomic, readonly) UIButton *m_btnReloadImg;

@end


@implementation JCRemoteImgScrlPageView
@synthesize m_strImgURL = _strImgURL;
@synthesize m_scrlView = _scrlView;
@synthesize m_imgViewImg = _imgViewImg;
@synthesize m_objImgListOper = _objImgListOper;
@synthesize m_viewProgress = _viewProgress;
@synthesize m_btnReloadImg = _btnReloadImg;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _scrlView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrlView.backgroundColor = [UIColor clearColor];
        _scrlView.delegate = self;
        [self addSubview:_scrlView];
        
        _imgViewImg = [[UIImageView alloc] initWithFrame:_scrlView.bounds];
        _imgViewImg.contentMode = UIViewContentModeCenter;
        _imgViewImg.backgroundColor = [UIColor clearColor];
        
        [_scrlView addSubview:_imgViewImg];
        
        _viewProgress = [[DACircularProgressView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
        _viewProgress.progress = 0.02f;
        _viewProgress.trackTintColor = [UIColor darkGrayColor];
        _viewProgress.progressTintColor = [UIColor whiteColor];
        [_viewProgress setHidden:YES];
        [_viewProgress setCenter:CGPointMake(_scrlView.frame.size.width/2, _scrlView.frame.size.height/2)];
        [self addSubview:_viewProgress];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)dealloc
{
    if (_objImgListOper && _viewProgress)
    {
        [_objImgListOper removeProgressDelegate:_viewProgress];
    }else{}
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForReuse
{
    if (_objImgListOper && _viewProgress)
    {
        [_objImgListOper removeProgressDelegate:_viewProgress];
    }else{}
    
    _strImgURL = @"";
    _imgViewImg.image = nil;
    _viewProgress.hidden = YES;
    _viewProgress.progress = 0.02f;
    
    if (_btnReloadImg)
    {
        [_btnReloadImg removeFromSuperview];
        _btnReloadImg = nil;
    }else{}
}

- (void)resetImg:(NSString *)strImgURL
{
    _strImgURL = strImgURL ? [strImgURL copy] : @"";
    
    [_scrlView setMinimumZoomScale:1.0f];
    [_scrlView setMaximumZoomScale:2.0f];
    [_scrlView setZoomScale:1.0f];
    
    if (_strImgURL && (_strImgURL.length > 0))
    {
        _viewProgress.hidden = NO;
        
        __block NSString *blockLargeImgURL = [_strImgURL copy];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                __block NSData *blockDataLargeImg;
                
                // 若有本地缓存图片，可先取缓存直接显示
                // ...
                
                if (blockDataLargeImg)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (_strImgURL && [_strImgURL isEqualToString:blockLargeImgURL])
                        {
                            _imgViewImg.image = [UIImage imageWithData:blockDataLargeImg];
                            [self resetImgScale];
                            _viewProgress.hidden = YES;
                        }else{}
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (_strImgURL && [_strImgURL isEqualToString:blockLargeImgURL])
                        {
                            if (_objImgListOper)
                            {
                                [_objImgListOper getRemoteImgByURL:blockLargeImgURL withProgress:_viewProgress];
                            }else{APP_ASSERT_STOP}
                        }
                    });
                }
                
            });
        });
    }else{}
}

- (void)setImgListOper:(RemoteImgListOperator *)objOper
{
    if (_objImgListOper != objOper)
    {
        if (_objImgListOper)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:_objImgListOper.m_strSuccNotificationName object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:_objImgListOper.m_strFailedNotificationName object:nil];
        }else{}
        
        _objImgListOper = objOper;
        
        if (_objImgListOper)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(remoteImgSucc:)
                                                         name:_objImgListOper.m_strSuccNotificationName
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(remoteImgFailed:)
                                                         name:_objImgListOper.m_strFailedNotificationName
                                                       object:nil];
        }else{}
    }else{}
}

#pragma mark - RemoteImgOperStack notification
- (void)remoteImgSucc:(NSNotification *)noti
{
    if (noti && noti.userInfo && noti.userInfo.allKeys && (noti.userInfo.allKeys.count > 0))
    {
        NSString *strURL;
        NSData *dataImg;
        
        strURL = [noti.userInfo.allKeys objectAtIndex:0];
        dataImg = [noti.userInfo objectForKey:strURL];
        
        // 显示
        if ([strURL isEqualToString:_strImgURL])
        {
            if (_viewProgress) {_viewProgress.hidden = YES;}
            
            _imgViewImg.image = [UIImage imageWithData:dataImg];
            [self resetImgScale];
        }
        else{}
        
    }else{APP_ASSERT_STOP}
}

- (void)remoteImgFailed:(NSNotification *)noti
{
    if (noti && noti.userInfo && noti.userInfo.allKeys && (noti.userInfo.allKeys.count > 0))
    {
        NSString *strURL;
        
        strURL = [noti.userInfo.allKeys objectAtIndex:0];
        
        if ([strURL isEqualToString:_strImgURL])
        {
            if (_viewProgress) {_viewProgress.hidden = YES;}
            _btnReloadImg = [UIButton buttonWithType:UIButtonTypeCustom];
            _btnReloadImg.frame = Rect(40.0f, 220.0f, 240.0f, 50.0f);
            _btnReloadImg.layer.borderColor = [UIColor lightGrayColor].CGColor;
            _btnReloadImg.layer.borderWidth = 2.0f;
            _btnReloadImg.backgroundColor = [UIColor clearColor];
            _btnReloadImg.titleLabel.font = [UIFont systemFontOfSize:13.0f];
            [_btnReloadImg setTitle:STR_ClickToReloadFullScreenImgBtn forState:UIControlStateNormal];
            [_btnReloadImg addTarget:self action:@selector(btnReload:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_btnReloadImg];
        }else{}
    }else{}
}

- (void)btnReload:(id)sender
{
    [_btnReloadImg removeFromSuperview];
    _btnReloadImg = nil;
    [self resetImg:_strImgURL];
}

#pragma mark - Remote request obj stack
- (void)getRemoteImgByURL:(NSString *)strURL
{
    [self getRemoteImgByURL:strURL withProgress:nil];
}

- (void)getRemoteImgByURL:(NSString *)strURL withProgress:(id)progress
{
    if (_objImgListOper)
    {
        [_objImgListOper getRemoteImgByURL:strURL withProgress:progress];
    }else{APP_ASSERT_STOP}
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imgViewImg;
}

//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
//{
//    [scrollView setZoomScale:scale+0.01 animated:NO];
//    [scrollView setZoomScale:scale animated:NO];
//}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0f;
    _imgViewImg.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                     scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - Private
- (void)resetImgScale
{
    if (_imgViewImg.image)
    {
        _imgViewImg.contentMode = UIViewContentModeCenter;
        
        _imgViewImg.frame = Rect(0.0f, 0.0f, _imgViewImg.image.size.width, _imgViewImg.image.size.height);
        _scrlView.contentSize = _imgViewImg.frame.size;
        
        // choose minimum scale so image width fits screen
        float minScale  = [_scrlView frame].size.width/_imgViewImg.image.size.width;
        [_scrlView setMinimumZoomScale:minScale];
        [_scrlView setMaximumZoomScale:1.5];
        [_scrlView setZoomScale:minScale];
    }else{}
}








@end
