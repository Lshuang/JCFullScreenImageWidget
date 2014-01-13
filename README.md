JCFullScreenImageWidget
=======================

一个寄生在图片视图上，为寄主提供点击看多图全屏大图功能的控件。

------ 原因 ------

1、为了实现类似微博单图和多图的点按看大图功能。

2、由于比较多地方需要这个样的全屏看大图功能，所以把这个功能独立出来，只需输入图片视图和大图URL，就可使宿主视图拥有这个功能。

------ 介绍 ------

1、使用了 RemoteImgListOperator 进行图片下载。 https://github.com/jimple/RemoteImgListOperator

2、原理如下：

- 使用 page scroll view 显示可放大缩小的图片。
- 大图的下载放在每一图片页内，宿主视图不需处理。
- 在控件内为宿主视图添加点按手势，响应点按手势，显示全屏的图片。
3、需注意的地方：

- 重用时可用clear函数（ - (void)clearHost; ）清空。但函数内会将宿主视图的全部手势清除！
------ 用法 ------

以Demo为例：

1、单图：

创建一个显示单图缩略图的UIImageView，为ImageView添加全屏大图控件。

_objFullScreenSingleImg = [[JCFullScreenImgWidget alloc] init];

[_objFullScreenSingleImg clearHost];
[_objFullScreenSingleImg setHostImgView:_imgViewSingleImg
                      singleLargeImgURL:_strSingleLargeImgURL
                      remoteImgListOper:_objImgListOper];
2、多图：

创建一个显示九宫格缩略图的视图，为各个子视图添加全屏大图控件。

_objFullScreenMultiImg = [[JCFullScreenImgWidget alloc] init];

[_objFullScreenMultiImg clearHost];
[_objFullScreenMultiImg setHostImgViews:[_mosaicImgView allImgViews]
                    multiLargeImgURLArr:arrLargeImgURL
                      remoteImgListOper:_objImgListOper];
