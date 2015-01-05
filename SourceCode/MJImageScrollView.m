//
//  UIImageScrollView.m
//
//  Created by Joan Martin on 4/18/13.
//  Copyright (c) Mobile Jazz. All rights reserved.
//

#import "MJImageScrollView.h"

@interface MJImageScrollView () <UIScrollViewDelegate>

@end

@implementation MJImageScrollView
{
    UIImageView *_zoomView;
    CGSize _imageSize;
    
    CGPoint _pointToCenterAfterResize;
    CGFloat _scaleToRestoreAfterResize;
    
    UITapGestureRecognizer *_tapGestureRecognizer;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame andImage:nil];
}

- (id)initWithFrame:(CGRect)frame andImage:(UIImage*)image
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self mjz_doInit];
        [self setImage:image];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self mjz_doInit];
    }
    return self;
}

- (void)setContentSize:(CGSize)size
{
    CGSize frameSize = self.frame.size;
    CGPoint centerPoint;
    
    if (self.zoomScale >= self.minimumZoomScale)
    {
        CGSize lImageSize = _zoomView.bounds.size;
        CGFloat newHeight = lImageSize.height * self.zoomScale;
        
        if (newHeight < frameSize.height)
            newHeight = frameSize.height;
        
        size.height = newHeight;
        
        CGFloat newWidth = lImageSize.width * self.zoomScale;
        
        if (newWidth < frameSize.width)
            newWidth = frameSize.width;
        
        size.width = newWidth;
        centerPoint = CGPointMake(floorf(size.width/2), floorf(size.height/2));
    }
    else
    {
        centerPoint = CGPointMake(floorf(frameSize.width/2), floorf(frameSize.height/2));
    }

    _zoomView.center = centerPoint;
    
    [super setContentSize:size];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark Properties

- (void)setFrame:(CGRect)frame
{
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    if (sizeChanging)
        [self mjz_prepareToResize];
    
    [super setFrame:frame];
    
    if (sizeChanging)
        [self mjz_recoverFromResizing];
}

- (void)setBounds:(CGRect)bounds
{
    BOOL sizeChanging = !CGSizeEqualToSize(bounds.size, self.bounds.size);
    
    if (sizeChanging)
        [self mjz_prepareToResize];
    
    [super setBounds:bounds];
    
    if (sizeChanging)
        [self mjz_recoverFromResizing];
}

- (void)setImage:(UIImage *)image
{
    [self mjz_displayImage:image];
}

- (UIImage*)image
{
    return _zoomView.image;
}

- (void)setDoubleTapForZoomEnabled:(BOOL)doubleTapForZoomEnabled
{
    if (doubleTapForZoomEnabled == _doubleTapForZoomEnabled)
        return;
    
    if (doubleTapForZoomEnabled)
    {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mjz_tapGestureRecognized:)];
        _tapGestureRecognizer.numberOfTapsRequired = 2;
        
        [self addGestureRecognizer:_tapGestureRecognizer];
    }
    else
    {
        [self removeGestureRecognizer:_tapGestureRecognizer];
        _tapGestureRecognizer = nil;
    }
}

- (void)setMaxScaleFactor:(CGFloat)maxScaleFactor
{
    _maxScaleFactor = maxScaleFactor;
    
    if (_zoomView.image)
        [self mjz_configureForImageSize:_zoomView.image.size];
}

#pragma mark Public Methods

- (void)resetZoom
{
    if (self.image)
    {
        self.zoomScale = 1.0f;
        [self mjz_configureForImageSize:self.image.size];
    }
}

#pragma mark Private Methods

- (void)mjz_doInit
{
    // Configuring instance
    _maxScaleFactor = 2.0f;
    _autoadjustToHeight = NO;
    _dragingNotEnabledWhenDefaultZoom = YES;
    self.doubleTapForZoomEnabled = YES;
    
    // Configuring UIScrollView
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.bouncesZoom = YES;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.delegate = self;
}

- (void)mjz_displayImage:(UIImage *)image
{
    // clear the previous image
    [_zoomView removeFromSuperview];
    _zoomView = nil;
    
    // reset  zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0f;
    
    if (image)
    {
        // make a new UIImageView for the new image
        _zoomView = [[UIImageView alloc] initWithImage:image];
        
        [self addSubview:_zoomView];
        [self mjz_configureForImageSize:image.size];
    }
}

- (void)mjz_configureForImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    self.contentSize = imageSize;
    
    [self mjz_setMaxMinZoomScalesForCurrentBounds];
    
    CGFloat zoom = _autoadjustToHeight ? [self mjz_zoomFactorForFullHeight] : self.minimumZoomScale;
    
    if (self.maximumZoomScale < zoom)
        self.maximumZoomScale = zoom;
    
    self.zoomScale = zoom;
}

- (CGFloat)mjz_zoomFactorForFullHeight
{
    CGSize boundsSize = self.bounds.size;
    //CGFloat xScale = boundsSize.width / _imageSize.width;   // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / _imageSize.height;   // the scale needed to perfectly fit the image height-wise
    
    return yScale;
}

- (void)mjz_setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = self.bounds.size;
    
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width  / _imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / _imageSize.height;   // the scale needed to perfectly fit the image height-wise
    
    // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
//    BOOL imagePortrait = _imageSize.height > _imageSize.width;
//    BOOL phonePortrait = boundsSize.height > boundsSize.width;
//    
//    CGFloat minScale = imagePortrait == phonePortrait ? xScale : MIN(xScale, yScale);
    
    CGFloat minScale = MIN(xScale, yScale);
    
    // In order to not touch the border of the superview
//    minScale *= 0.95;
    
    CGFloat maxScale = 0;
    
    if (_maxScaleFactor == 0.0f)
    {
        CGFloat imageScale = _zoomView.image.scale;
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        
        // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
        maxScale =  imageScale / screenScale;
    }
    else
        maxScale = MAX(MAX(xScale, yScale), _maxScaleFactor);
    
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
    if (minScale > maxScale)
        minScale = maxScale;

    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
}

#pragma mark Rotation support

- (void)mjz_prepareToResize
{
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _pointToCenterAfterResize = [self convertPoint:boundsCenter toView:_zoomView];
    
    _scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON)
        _scaleToRestoreAfterResize = 0;
}

- (void)mjz_recoverFromResizing
{
    [self mjz_setMaxMinZoomScalesForCurrentBounds];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    CGFloat maxZoomScale = MAX(self.minimumZoomScale, _scaleToRestoreAfterResize);
    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:_pointToCenterAfterResize fromView:_zoomView];
    
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self mjz_maximumContentOffset];
    CGPoint minOffset = [self mjz_minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);

    self.contentOffset = offset;
}

- (CGPoint)mjz_maximumContentOffset
{
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)mjz_minimumContentOffset
{
    return CGPointZero;
}

- (void)mjz_tapGestureRecognized:(UITapGestureRecognizer*)recognizer
{
    if (fabs(self.zoomScale - self.minimumZoomScale) < FLT_EPSILON)
    {
        CGFloat newScale = self.maximumZoomScale;
        CGRect zoomRect = [self mjz_zoomRectForScale:newScale withCenter:[recognizer locationInView:recognizer.view]];
        [self zoomToRect:zoomRect animated:YES];
    }
    else
    {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
}

- (CGRect)mjz_zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    
    zoomRect.size.height = _zoomView.frame.size.height / scale;
    zoomRect.size.width  = _zoomView.frame.size.width  / scale;
    
    center = [_zoomView convertPoint:center fromView:self];
    
    zoomRect.origin.x = center.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y = center.y - ((zoomRect.size.height / 2.0));
    
    return zoomRect;
}

#pragma mark - Protocols
#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _zoomView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (_autoadjustToHeight)
    {
        if (_dragingNotEnabledWhenDefaultZoom)
        {
            if (fabs([self mjz_zoomFactorForFullHeight] - scrollView.zoomScale) < FLT_EPSILON)
                self.scrollEnabled = NO;
            else
                self.scrollEnabled = YES;
        }
    }
}

@end
