//
//  ViewController.m
//  JCFullScreenImageWidgetDemo
//
//  Created by jimple on 14-1-13.
//  Copyright (c) 2014年 Jimple Chen. All rights reserved.
//

#import "ViewController.h"
#import "GlobalDefine.h"
#import "JCMosaicImgView.h"
#import "RemoteImgListOperator.h"
#import "JCFullScreenImgWidget.h"

@interface ViewController ()

@property (nonatomic, readonly) RemoteImgListOperator *m_objImgListOper;
@property (nonatomic, readonly) JCMosaicImgView *m_mosaicImgView;
@property (nonatomic, readonly) UIImageView *m_imgViewSingleImg;
@property (nonatomic, readonly) JCFullScreenImgWidget *m_objFullScreenSingleImg;
@property (nonatomic, readonly) JCFullScreenImgWidget *m_objFullScreenMultiImg;
@property (nonatomic, readonly, copy) NSString *m_strSingleThumgImgURL;
@property (nonatomic, readonly, copy) NSString *m_strSingleLargeImgURL;


@end

@implementation ViewController
@synthesize m_objImgListOper = _objImgListOper;
@synthesize m_mosaicImgView = _mosaicImgView;
@synthesize m_imgViewSingleImg = _imgViewSingleImg;
@synthesize m_objFullScreenSingleImg = _objFullScreenSingleImg;
@synthesize m_objFullScreenMultiImg = _objFullScreenMultiImg;
@synthesize m_strSingleThumgImgURL = _strSingleThumgImgURL;
@synthesize m_strSingleLargeImgURL = _strSingleLargeImgURL;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = RGB(240.0f, 240.0f, 240.0f);
    
    // 使用 JCRemoteImgListOperator 进行图片下载
    // https://github.com/jimple/RemoteImgListOperator
    _objImgListOper = [[RemoteImgListOperator alloc] init];
    [_objImgListOper resetListSize:20];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(remoteImgSucc:)
                                                 name:_objImgListOper.m_strSuccNotificationName
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(remoteImgFailed:)
                                                 name:_objImgListOper.m_strFailedNotificationName
                                               object:nil];
    
/////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // 单图
    
    _strSingleThumgImgURL = @"http://ww1.sinaimg.cn/small/6deee36fgw1eby2bh3bxlj20bh0hajsu.jpg";
    _strSingleLargeImgURL = @"http://ww1.sinaimg.cn/large/6deee36fgw1eby2bh3bxlj20bh0hajsu.jpg";
    _imgViewSingleImg = [[UIImageView alloc] initWithFrame:Rect(40.0f, 60.0f, 100.0f, 100.0f)];
    _imgViewSingleImg.backgroundColor = RGB(230.0f, 230.0f, 230.0f);
    _imgViewSingleImg.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imgViewSingleImg];
    
    // 加载图片
    __block NSString *strImgURLBlock  = [_strSingleThumgImgURL copy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (strImgURLBlock && (strImgURLBlock.length > 0))
            {
                __block NSData *dataItemImgBlock;
                
                // 可先从本地缓存中获取图片
                // ...
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (strImgURLBlock)
                    {
                        if (dataItemImgBlock)
                        {// 本地缓存了图片则直接使用本地缓存
                            _imgViewSingleImg.image = [UIImage imageWithData:dataItemImgBlock];
                        }
                        else
                        {// 从网络下载
                            if (_objImgListOper)
                            {
                                [_objImgListOper getRemoteImgByURL:strImgURLBlock withProgress:nil];
                            }else{}
                        }
                    }else{}
                });
            }else{}
        });
    });
    
    _objFullScreenSingleImg = [[JCFullScreenImgWidget alloc] init];

    /********************************/
    /*                              */
    /*  -------  添加全屏控件 ------- */
    /*                              */
    /********************************/
    [_objFullScreenSingleImg clearHost];
    [_objFullScreenSingleImg setHostImgView:_imgViewSingleImg
                          singleLargeImgURL:_strSingleLargeImgURL
                          remoteImgListOper:_objImgListOper];
    
    
/////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // 多图
    
    NSArray *arrThumbImgURL = @[@"http://ww1.sinaimg.cn/square/6deee36fgw1eby2bh3bxlj20bh0hajsu.jpg",
                                @"http://ww1.sinaimg.cn/small/6deee36fgw1eby2bhj5t2j20bh0hb0u5.jpg",
                                @"http://ww1.sinaimg.cn/square/749e7418jw1e6tiy08m52j20dc0hsgne.jpg",
                                @"http://ww1.sinaimg.cn/square/749e7418jw1e6tiy3nso4j20dc0hs3zs.jpg",
                                @"http://ww1.sinaimg.cn/square/5fae6c19jw1e6h04js4xej218g0xcju2.jpg",
                                @"http://ww1.sinaimg.cn/square/5fae6c19jw1e6h04llbhjj218g0xcgp5.jpg",
                                @"http://ww1.sinaimg.cn/square/6e109605jw1ec442eaq9nj20qo0f0q6m.jpg",
                                @"http://ww1.sinaimg.cn/square/6deee36fgw1eby2bfug1uj20bh07mmy4.jpg",
                                @"http://ww1.sinaimg.cn/small/7116d554gw1ecd41d9s9oj205k05k3ym.jpg"];
    NSArray *arrLargeImgURL = @[@"http://ww1.sinaimg.cn/large/6deee36fgw1eby2bh3bxlj20bh0hajsu.jpg",
                                @"http://ww1.sinaimg.cn/large/6deee36fgw1eby2bhj5t2j20bh0hb0u5.jpg",
                                @"http://ww1.sinaimg.cn/large/749e7418jw1e6tiy08m52j20dc0hsgne.jpg",
                                @"http://ww1.sinaimg.cn/large/749e7418jw1e6tiy3nso4j20dc0hs3zs.jpg",
                                @"http://ww1.sinaimg.cn/large/5fae6c19jw1e6h04js4xej218g0xcju2.jpg",
                                @"http://ww1.sinaimg.cn/large/5fae6c19jw1e6h04llbhjj218g0xcgp5.jpg",
                                @"http://ww1.sinaimg.cn/large/6e109605jw1ec442eaq9nj20qo0f0q6m.jpg",
                                @"http://ww1.sinaimg.cn/large/6deee36fgw1eby2bfug1uj20bh07mmy4.jpg",
                                @"http://ww1.sinaimg.cn/large/7116d554gw1ecd41d9s9oj205k05k3ym.jpg"];
    CGFloat fImgHeight = [JCMosaicImgView imgHeightByImg:arrThumbImgURL];
    CGFloat fImgWidth = [JCMosaicImgView imgWidthByImg:arrThumbImgURL];
    
    // 使用 JCMosaicImgView 显示九宫格图片
    // https://github.com/jimple/JCMosaicImgView
    // 1.创建对象   2.设置图片下载队列对象   3.输入图片URL数组。
    _mosaicImgView = [[JCMosaicImgView alloc] initWithFrame:Rect(40.0f, 180.0f, fImgWidth, fImgHeight)];
    [_mosaicImgView setImgListOper:_objImgListOper];
    [_mosaicImgView showWithImgURLs:arrThumbImgURL];
    
    [self.view addSubview:_mosaicImgView];
    
    _objFullScreenMultiImg = [[JCFullScreenImgWidget alloc] init];
    
    /********************************/
    /*                              */
    /*  -------  添加全屏控件 ------- */
    /*                              */
    /********************************/
    [_objFullScreenMultiImg clearHost];
    [_objFullScreenMultiImg setHostImgViews:[_mosaicImgView allImgViews]
                        multiLargeImgURLArr:arrLargeImgURL
                          remoteImgListOper:_objImgListOper];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        if ([strURL isEqualToString:_strSingleThumgImgURL])
        {
            _imgViewSingleImg.image = [UIImage imageWithData:dataImg];
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
        
        if ([strURL isEqualToString:_strSingleThumgImgURL])
        {
            // 下载失败
            // ...
        }else{}
    }else{}
}













@end
