//
//  JCMultiFullScreenImgView.m
//  JCFullScreenImageWidgetDemo
//
//  Created by jimple on 14-1-13.
//  Copyright (c) 2014年 Jimple Chen. All rights reserved.
//

#import "JCMultiFullScreenImgView.h"
#import "GlobalDefine.h"
#import "RemoteImgListOperator.h"
#import "JCRemoteImgScrlPageView.h"

#define STR_Close                                           @"关闭"

@interface JCMultiFullScreenImgView ()
<UIScrollViewDelegate>

@property (nonatomic, readonly) UIScrollView *m_sclView;
@property (nonatomic, readonly) UIView *m_viewHeader;
//@property (nonatomic, readonly) UIButton *m_btnClose;
@property (nonatomic, readonly) UILabel *m_labelTitle;

@property (nonatomic, readonly) NSArray *m_arrImgURL;
@property (nonatomic, readonly) NSInteger m_iCurrPage;
@property (nonatomic, readonly) NSMutableArray *m_arrImgView;
@property (nonatomic, readonly) RemoteImgListOperator *m_objImgListOper;

@end

@implementation JCMultiFullScreenImgView
@synthesize delegate;
@synthesize m_sclView = _sclView;
@synthesize m_viewHeader = _viewHeader;
//@synthesize m_btnClose = _btnClose;
@synthesize m_labelTitle = _labelTitle;
@synthesize m_arrImgURL = _arrImgURL;
@synthesize m_iCurrPage = _iCurrPage;
@synthesize m_arrImgView = _arrImgView;
@synthesize m_objImgListOper = _objImgListOper;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self initUI];
        
    }
    return self;
}

- (void)dealloc
{
    delegate = nil;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)showImgs:(NSArray *)arrImgURL atIndex:(NSInteger)iIndex remoteImgStackOper:(RemoteImgListOperator *)objImgListOper
{
    if (arrImgURL && (iIndex >= 0) && (arrImgURL.count > iIndex)
        && objImgListOper)
    {
        _arrImgURL = [NSArray arrayWithArray:arrImgURL];
        _iCurrPage = iIndex;
        _objImgListOper = objImgListOper;
        
        CGSize szScrlContent = CGSizeMake(arrImgURL.count * _sclView.bounds.size.width, _sclView.bounds.size.height);
        [_sclView setContentSize:szScrlContent];
        
        _labelTitle.hidden = (arrImgURL.count == 1);
        _labelTitle.text = [NSString stringWithFormat:@"%d/%d", _iCurrPage+1, _arrImgURL.count];
        
        [self performSelector:@selector(initSubImgPage) withObject:nil afterDelay:0.001f];
        
        self.backgroundColor = RGBA(0.0f, 0.0f, 0.0f, 0.01f);
        [UIView animateWithDuration:0.2f animations:^()
         {
             self.backgroundColor = RGBA(0.0f, 0.0f, 0.0f, 0.9f);
         }completion:^(BOOL f)
         {
         }];
        
        _sclView.alpha = 0.0f;
        [UIView animateWithDuration:0.15f delay:0.1f options:UIViewAnimationOptionCurveEaseIn animations:^()
         {
             _sclView.alpha = 1.0f;
         }completion:^(BOOL f){}];
        
    }else{APP_ASSERT_STOP}
}

- (void)initUI
{
    CGRect rc = self.bounds;
    if (!IsiOS7Later)
    {// ios 7以下图片不显示到状态栏下面
        rc.origin.y = StatusBarHeight;
        rc.size.height -= rc.origin.y;
    }else{}
    _sclView = [[UIScrollView alloc] initWithFrame:rc];
    _sclView.delegate = self;
    _sclView.pagingEnabled = YES;
    [self addSubview:_sclView];
    
    _viewHeader = [[UIView alloc] initWithFrame:Rect(0.0f, 0.0f, self.bounds.size.width, NaviBarHeight + StatusBarHeight)];
    _viewHeader.backgroundColor = RGBA(0.0f, 0.0f, 0.0f, 0.2f);
    [self addSubview:_viewHeader];
    
//    _btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_btnClose setTitle:STR_Close forState:UIControlStateNormal];
//    [_btnClose addTarget:self action:@selector(btnClose:) forControlEvents:UIControlEventTouchUpInside];
//    _btnClose.frame = Rect(0.0f, StatusBarHeight, 50.0f, NaviBarHeight);
//    [_viewHeader addSubview:_btnClose];
    
    _labelTitle = [[UILabel alloc] initWithFrame:Rect(60.0f, StatusBarHeight, 200.0f, NaviBarHeight)];
    _labelTitle.textColor = RGB(255.0f, 255.0f, 255.0f);
    _labelTitle.font = [UIFont boldSystemFontOfSize:SIZE_TextTitleNormal];
    _labelTitle.textAlignment = NSTextAlignmentCenter;
    _labelTitle.backgroundColor = [UIColor clearColor];
    [_viewHeader addSubview:_labelTitle];
    
    self.backgroundColor = [UIColor blackColor];
    _sclView.backgroundColor = [UIColor clearColor];
}

//- (void)btnClose:(id)sender
//{
//    if (delegate && [delegate respondsToSelector:@selector(fullScreenViewNeedClose:)])
//    {
//        [delegate fullScreenViewNeedClose:self];
//    }else{APP_ASSERT_STOP}
//}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView*)sender
{
    if (_arrImgURL)
    {
        CGFloat pageWidth = _sclView.frame.size.width;
        
        _iCurrPage = floor((_sclView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        _labelTitle.text = [NSString stringWithFormat:@"%d/%d", _iCurrPage+1, _arrImgURL.count];
    }else{}
}

#pragma mark -
- (void)initSubImgPage
{
    CGRect rcToDisplay = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    _arrImgView = [[NSMutableArray alloc] init];
    for (int i = 0; i < _arrImgURL.count; i++)
    {
        NSString *strLargeImgURL = [_arrImgURL objectAtIndex:i];
        
        CGRect rcPage = _sclView.bounds;
        rcPage.origin.x = i * _sclView.bounds.size.width;
        
        JCRemoteImgScrlPageView *pageView = [[JCRemoteImgScrlPageView alloc] initWithFrame:rcPage];
        [pageView setImgListOper:_objImgListOper];
        [_sclView addSubview:pageView];
        [pageView resetImg:strLargeImgURL];
        
        if (i == _iCurrPage)
        {
            rcToDisplay = rcPage;
        }else{}
    }
    [_sclView scrollRectToVisible:rcToDisplay animated:NO];
    
    [self bringSubviewToFront:_viewHeader];
}









@end
