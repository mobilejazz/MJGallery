//
//  MJImageViewerGalleryViewController.m
//
//  Created by Joan Martin on 05/01/15.
//  Copyright (c) 2015 Mobile Jazz. All rights reserved.
//

#import "MJImageViewerGalleryViewController.h"
#import "MJImageViewerViewController.h"

#import <Lyt/Lyt.h>

@interface MJImageViewerGalleryViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@end

@implementation MJImageViewerGalleryViewController
{
    UIPageViewController *_pageViewController;
    UIStatusBarStyle _customPreferredStatusBarStyle;
}

- (id)initWithImages:(NSArray*)images
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _images = images;
        _currentImageIndex = _images.count > 0 ? 0 : NSNotFound;
        _customPreferredStatusBarStyle = UIStatusBarStyleDefault;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   self.view.backgroundColor = [UIColor blackColor];
    
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    _pageViewController.automaticallyAdjustsScrollViewInsets = NO;

    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [_pageViewController didMoveToParentViewController:self];
    
    _pageViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [_pageViewController.view lyt_alignToParent];
    
    UIViewController *vc = [self mjz_viewControllerForImageAtIndex:_currentImageIndex];
    if (vc)
        [_pageViewController setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mjz_tapGestureRecognized:)];
    recognizer.delaysTouchesBegan = YES;
    [self.view addGestureRecognizer:recognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return _customPreferredStatusBarStyle;
}

#pragma mark Properties

- (void)setImages:(NSArray *)images
{
    _images = images;
    
    [self willChangeValueForKey:@"currentImageIndex"];
    _currentImageIndex = _images.count > 0 ? 0 : NSNotFound;
    [self didChangeValueForKey:@"currentImageIndex"];
    
    UIViewController *vc = [self mjz_viewControllerForImageAtIndex:_currentImageIndex];
    if (vc)
        [_pageViewController setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    else
        [_pageViewController setViewControllers:nil direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)setCurrentImageIndex:(NSInteger)currentImageIndex
{
    _currentImageIndex = currentImageIndex;
    
    if (self.isViewLoaded)
    {
        UIViewController *vc = [self mjz_viewControllerForImageAtIndex:_currentImageIndex];
        if (vc)
            [_pageViewController setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
}

#pragma mark Public Methods

- (void)setPreferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle
{
    _customPreferredStatusBarStyle = preferredStatusBarStyle;
}

#pragma mark Private Methods

- (UIViewController*)mjz_viewControllerForImageAtIndex:(NSInteger)index
{
    if (index < 0 || index >= _images.count)
        return nil;
    
    MJImageViewerViewController *imageVC = [[MJImageViewerViewController alloc] initWithImage:_images[index]];
    imageVC.preferredStatusBarStyle = _customPreferredStatusBarStyle;
    imageVC.index = index;
    
    return imageVC;
}

- (void)mjz_tapGestureRecognized:(UITapGestureRecognizer*)recognizer
{
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait)
    {
        BOOL barHidden = self.navigationController.navigationBarHidden;
        [self.navigationController setNavigationBarHidden:!barHidden animated:YES];
    }
}

#pragma mark - Protocols
#pragma mark UIPageViewControllerDataSource

- (UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger currentIndex = [(MJImageViewerViewController*)viewController index];
    
    if (currentIndex == NSNotFound)
        return nil;
    
    return [self mjz_viewControllerForImageAtIndex:currentIndex+1];
}

- (UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger currentIndex = [(MJImageViewerViewController*)viewController index];
    
    if (currentIndex == NSNotFound)
        return nil;
    
    return [self mjz_viewControllerForImageAtIndex:currentIndex-1];
}

#pragma mark UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed)
    {
        [self willChangeValueForKey:@"currentImageIndex"];
        _currentImageIndex = [_pageViewController.viewControllers.firstObject index];
        [self didChangeValueForKey:@"currentImageIndex"];
    }
}

@end
