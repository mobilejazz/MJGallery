//
//  UIImageScrollView.h
//
//  Created by Joan Martin on 4/18/13.
//  Copyright (c) Mobile Jazz. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * UIImageScrollView renders a UIImage inside an UIScrollView and add zooming feature.
 * Zoom can be configured by using the property `maxScaleFactor` and `doubleTappForZoomEnabled`.
 * For a list of images (similar to iOS photo app), use this class inside a UIViewController and paginate it with a UIPageViewController.
 */
@interface MJImageScrollView : UIScrollView

- (id)initWithFrame:(CGRect)frame andImage:(UIImage*)image;

/**
 * The image to display.
 */
@property (nonatomic, readwrite) UIImage *image;

/**
 * If YES double taps will trigger a zoom in/zoom out. Default value is YES.
 * @discussion When zooming in, the image is centering to the area of the touch.
 */
@property (nonatomic, assign) BOOL doubleTapForZoomEnabled;

/**
 * If NO, the minimum zoom scale layouts the image from side to side of the view, otherwise a small padding is added. Default value is YES.
 * @discussion If `imageLayoutsSideToSide` is YES, the image will only be rendered side to side if the applicable zoom is smaller or equal to `maxScaleFactor`.
 */
@property (nonatomic, assign) BOOL imageLayoutsSideToSide;

/**
 * The maximum scale factor. If 0, the max zoom scale matches the image size. Default value is 2.0.
 */
@property (nonatomic, assign) CGFloat maxScaleFactor;

/**
 * Returns the image to the default zoom by recomputing the max and min zoom from the view bounds.
 **/
- (void)resetZoom;

/**
 * If YES, dragging is not enabled when there is no ZOOM. Default is YES.
 **/
@property (nonatomic, assign) BOOL dragingNotEnabledWhenDefaultZoom;

/**
 * If YES, the image will be autadjusted to the total height of the screen. Default is YES.
 **/
@property (nonatomic, assign) BOOL autoadjustToHeight;


@end