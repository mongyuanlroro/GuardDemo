//
//  ViewController.m
//  GuardDemo
//
//  Created by mongyuan on 16/8/23.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "ViewController.h"
#import "MainViewController.h"

#define KImageCount 4

// 适配及屏幕宽高
#define kScreenWH ([UIScreen mainScreen].bounds.size.width / 320.0)
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController () <UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    UIPageControl      *_pageControl;
    int                 _currentPage;// 当前的页码
    
    CGPoint             _beginPoint;
    CGPoint             _movePoint;
    NSString           *_directionString;
}

@property (nonatomic, strong) NSMutableArray *imageArrM;
@property (nonatomic, strong) UIView         *mainScrollView;

@end

@implementation ViewController


#pragma mark - 懒加载
- (NSMutableArray *)imageArrM
{
    if (_imageArrM == nil) {
        _imageArrM = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _imageArrM;
}
- (UIView *)mainScrollView
{
    if (_mainScrollView == nil) {
        _mainScrollView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    }
    
    return _mainScrollView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createScrollView];
    [self createPageControl];
}

- (void)createPageControl
{
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.center = CGPointMake(ScreenWidth * 0.5, ScreenHeight * 0.85);
    pageControl.numberOfPages = KImageCount;
    pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
    pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    
    [self.view addSubview:pageControl];
    _pageControl = pageControl;
}

// 创建图片
- (void)createScrollView
{
    for (int i = 0; i < KImageCount; i ++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%i.jpg",i + 10]];
        
        if (i == 0) {
            imageView.alpha = 1;
        }else {
            imageView.alpha = 0;
        }
        imageView.tag = i;
        imageView.userInteractionEnabled = NO;
        
        [self.view addSubview:imageView];
        [self.imageArrM addObject:imageView];
        [self.view insertSubview:imageView atIndex:0];
    }
    
    
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipe.delegate = self;
//    swipe.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipe];
    
    UISwipeGestureRecognizer *swipe1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe1:)];
    swipe1.delegate = self;
    swipe1.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipe1];
    
    [pan requireGestureRecognizerToFail:swipe];//UISwipeGestureRecognizer失效时才判断UIPanGestureRecognizer
    [pan requireGestureRecognizerToFail:swipe1];
}

- (void)gotoMainControlller
{
    MainViewController *tabBarController = [[MainViewController alloc] init];
    [self.navigationController pushViewController:tabBarController animated:YES];
}

- (void)swipe:(UISwipeGestureRecognizer *)swipe
{
    switch (swipe.state) {
        case UIGestureRecognizerStateEnded:
            switch (swipe.direction) {
                case UISwipeGestureRecognizerDirectionRight:// 右划
                {
                    if (_currentPage != 0) {
                        UIImageView *currImageView = self.imageArrM[_currentPage];
                        UIImageView *moveImageView = self.imageArrM[_currentPage - 1];
                        currImageView.alpha = 0;
                        moveImageView.alpha = 1;
                        _currentPage --;
                    }
                }
                    break;
                    
                default:
                    break;
            }
            _pageControl.currentPage = _currentPage;
            break;
            
        default:
            break;
    }
}

- (void)swipe1:(UISwipeGestureRecognizer *)swipe1
{
    switch (swipe1.state) {
        case UIGestureRecognizerStateEnded:
            switch (swipe1.direction) {
                case UISwipeGestureRecognizerDirectionLeft:// 左划
                {
                    if (_currentPage != 3) {
                        UIImageView *currImageView = self.imageArrM[_currentPage];
                        UIImageView *moveImageView = self.imageArrM[_currentPage + 1];
                        currImageView.alpha = 0;
                        moveImageView.alpha = 1;
                        _currentPage ++;
                    }
                }
                    break;
                default:
                    break;
            }
            _pageControl.currentPage = _currentPage;
            break;
            
        default:
            break;
    }
}


- (void)pan:(UIPanGestureRecognizer *)pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            _beginPoint = [pan locationInView:self.view];
            _directionString = nil;
            break;
        case UIGestureRecognizerStateChanged:
            _movePoint = [pan locationInView:self.view];
            if (_directionString == nil) {
                if (fabs(_movePoint.y - _beginPoint.y) > fabs(_movePoint.x - _beginPoint.x) && fabs(_movePoint.y - _beginPoint.y) > 20) {
                    _directionString = @"1";// 竖直
                }else if (fabs(_movePoint.x - _beginPoint.x) > fabs(_movePoint.y - _beginPoint.y) && fabs(_movePoint.x - _beginPoint.x) > 20) {
                    _directionString = @"0";// 水平
                }
            }else {
                if ([_directionString isEqualToString:@"0"]) { // 水平
                    if (_movePoint.x - _beginPoint.x < 0) { // 向左滑
                        CGFloat offsetX = _beginPoint.x - _movePoint.x;
                        CGFloat temp = offsetX / (ScreenWidth * 0.6);
                        UIImageView *currImageView = self.imageArrM[_currentPage];
                        if (_currentPage != 3) {
                            UIImageView *moveImageView = self.imageArrM[_currentPage + 1];
                            currImageView.alpha = 1 - temp;
                            moveImageView.alpha = temp;
                        }else {
                            currImageView.alpha = 1 - temp <= 0.7 ? 0.7 : 1 - temp;
                        }
                    }else {
                        CGFloat offsetX = _movePoint.x - _beginPoint.x;
                        CGFloat temp = offsetX / (ScreenWidth * 0.6);
                        UIImageView *currImageView = self.imageArrM[_currentPage];
                        if (_currentPage != 0) {
                            UIImageView *moveImageView = self.imageArrM[_currentPage - 1];
                            currImageView.alpha = 1 - temp;
                            moveImageView.alpha = temp;
                        }else {
                            currImageView.alpha = 1 - temp <= 0.7 ? 0.7 : 1 - temp;
                        }
                    }
                }
            }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if ([_directionString isEqualToString:@"0"]) {
                if (_movePoint.x - _beginPoint.x < 0) { // 向左滑
                    if (_currentPage != 3) { // 不是最后一张图片
                        UIImageView *currImageView = self.imageArrM[_currentPage];
                        UIImageView *moveImageView = self.imageArrM[_currentPage + 1];
                        if (_beginPoint.x - _movePoint.x > ScreenWidth / 2) {
                            currImageView.alpha = 0;
                            moveImageView.alpha = 1;
                            _currentPage ++;
                        }else {
                            currImageView.alpha = 1;
                            moveImageView.alpha = 0;
                        }
                    }else {
                        UIImageView *currImageView = self.imageArrM[_currentPage];
                        currImageView.alpha = 1;
                    }
                }else {
                    if (_currentPage != 0) { // 不是第一张图片
                        UIImageView *currImageView = self.imageArrM[_currentPage];
                        UIImageView *moveImageView = self.imageArrM[_currentPage - 1];
                        if (_movePoint.x - _beginPoint.x  > ScreenWidth / 2) {
                            currImageView.alpha = 0;
                            moveImageView.alpha = 1;
                            _currentPage --;
                        }else {
                            currImageView.alpha = 1;
                            moveImageView.alpha = 0;
                        }
                    }else {
                        UIImageView *currImageView = self.imageArrM[_currentPage];
                        currImageView.alpha = 1;
                    }
                }
            }
            _pageControl.currentPage = _currentPage;
        }
            break;
        default:
            break;
    }
    [pan setTranslation:CGPointMake(0, 0) inView:self.view];
}

@end
