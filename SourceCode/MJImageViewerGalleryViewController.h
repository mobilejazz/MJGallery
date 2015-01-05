//
//  MJImageViewerGalleryViewController.h
//
//  Created by Joan Martin on 05/01/15.
//  Copyright (c) 2015 Mobile Jazz. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Shows a list of images in a page view controller style.
 **/
@interface MJImageViewerGalleryViewController : UIViewController

/**
 * An array of images.
 * @param images The array of images.
 * @return An initialized instance.
 * @discussion The array can contain instances of NSURL, NSString or UIImage.
 **/
- (id)initWithImages:(NSArray*)images;

/**
 * The array of images to display.
 **/
@property (nonatomic, strong) NSArray *images;

/**
 * The current selected index.
 **/
@property (nonatomic, assign) NSInteger currentImageIndex;

/**
 * Set a custom preferrd status bar style.
 * @param preferredStatusBarStyle The preferred status bar style.
 **/
- (void)setPreferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle;

@end
