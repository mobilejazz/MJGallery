//
//  MJImageGalleryViewController.m
//
//  Created by Joan Martin on 12/12/14.
//  Copyright (c) 2014 Mobile Jazz. All rights reserved.
//

#import "MJImageViewerViewController.h"
#import "MJImageScrollView.h"

#import <Haneke/Haneke.h>
#import <Lyt/Lyt.h>

@interface MJImageViewerViewController ()

@end

@implementation MJImageViewerViewController
{
    HNKCacheFormat *_format;
    UIActivityIndicatorView *_activityIndicatorView;
    UIStatusBarStyle _customPreferredStatusBarStyle;
}

@synthesize imageScrollView = _imageScrollView;

- (id)initWithImage:(id)image
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _index = NSNotFound;
        _image = image;
        _customPreferredStatusBarStyle = UIStatusBarStyleDefault;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicatorView.hidesWhenStopped = YES;
    [self.view addSubview:_activityIndicatorView];
    _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [_activityIndicatorView lyt_centerInParent];
    
    _imageScrollView = [[MJImageScrollView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_imageScrollView];
    _imageScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [_imageScrollView lyt_alignToParent];

    self.view.backgroundColor = [UIColor blackColor];
    
    if ([_image isKindOfClass:UIImage.class])
    {
        _imageScrollView.image = _image;
    }
    else
    {
        BOOL done = NO;
        
        if ([_image isKindOfClass:NSString.class])
        {
            UIImage *image = [UIImage imageNamed:_image];
            if (image)
            {
                _imageScrollView.image = image;
                done = YES;
            }
        }
        else if ([_image isKindOfClass:NSURL.class])
        {
            NSURL *url = _image;
            
            if (url.isFileURL)
            {
                UIImage *image = [UIImage imageNamed:url.path];
                if (image)
                {
                    _imageScrollView.image = image;
                    done = YES;
                }
            }
        }
        
        // otherwise, lets attemp to fetch the image
        if (!done)
        {
            NSURL *url = nil;
            
            if ([_image isKindOfClass:NSURL.class])
                url = _image;
            else if ([_image isKindOfClass:NSString.class])
                url = [NSURL URLWithString:_image];
            
            if (url && [url.scheme isEqualToString:@"http"])
            {
                BOOL const done = [self mjz_fetchImageAtURL:url success:^(UIImage *image) {
                    [_activityIndicatorView stopAnimating];
                    _imageScrollView.image = image;
                    
                    [_imageScrollView setNeedsLayout];
                    [_imageScrollView layoutIfNeeded];
                    
                } failure:^(NSError *error) {
                    [_activityIndicatorView stopAnimating];
                }];
                
                if (!done)
                    [_activityIndicatorView startAnimating];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    BOOL isPortrait = size.width < size.height;
    
    // Hide the navigation bar if landscape
    [self.navigationController setNavigationBarHidden:!isPortrait animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return _customPreferredStatusBarStyle;
}

#pragma mark Properties

- (MJImageScrollView*)imageScrollView
{
    if (!self.isViewLoaded)
    {
        UIView *view = self.view;
        (void)view;
    }
    
    return _imageScrollView;
}

#pragma mark Public Methods

- (void)setPreferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle
{
    _customPreferredStatusBarStyle = preferredStatusBarStyle;
}

#pragma mark Private Methods

- (HNKCacheFormat*)mjz_cacheFormat
{
    if (!_format)
    {
        _format = [[HNKCacheFormat alloc] initWithName:@"com.tapformenu.orignal"];
        _format.scaleMode = HNKScaleModeNone;
        _format.diskCapacity = 1024*1024*10; // 10 MB
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[HNKCache sharedCache] registerFormat:_format];
        });
    }
    
    return _format;
}

- (BOOL)mjz_fetchImageAtURL:(NSURL*)url success:(void (^)(UIImage *image))successBlock failure:(void (^)(NSError *error))failureBlock
{
    id<HNKFetcher> fetcher = [[HNKNetworkFetcher alloc] initWithURL:url];
    HNKCacheFormat *format = self.mjz_cacheFormat;
    
    BOOL const synchronous = [[HNKCache sharedCache] fetchImageForFetcher:fetcher formatName:format.name success:^(UIImage *image) {
        if (successBlock)
            successBlock(image);
        
    } failure:^(NSError *error) {
        if (failureBlock)
            failureBlock(error);
    }];
    
    return synchronous;
}

@end
