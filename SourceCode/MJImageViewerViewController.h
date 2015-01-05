//
//  MJImageGalleryViewController.h
//
//  Created by Joan Martin on 12/12/14.
//  Copyright (c) 2014 Mobile Jazz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MJImageScrollView.h"

/**
 * Shows a single images in a scroll view container. The image can be zoomed by panning or by double tapping.
 **/
@interface MJImageViewerViewController : UIViewController

/**
 * Default initializer.
 * @param image An NSURL, NSString or UIImage instance.
 * @return An initialized instance.
 **/
- (id)initWithImage:(id)image;

/**
 * The image.
 **/
@property (nonatomic, strong, readonly) id image;

/**
 * The scroll view used to display the image.
 **/
@property (nonatomic, strong, readonly) MJImageScrollView *imageScrollView;

/**
 * Set a custom preferrd status bar style.
 * @param preferredStatusBarStyle The preferred status bar style.
 **/
- (void)setPreferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle;

/**
 * Auxiliar property used by the MJImageViewerGalleryViewController
 **/
@property (nonatomic, assign) NSInteger index;

@end
