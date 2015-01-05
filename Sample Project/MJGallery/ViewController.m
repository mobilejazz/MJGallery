//
//  ViewController.m
//  MJGallery
//
//  Created by Joan Martin on 05/01/15.
//  Copyright (c) 2015 Mobile Jazz. All rights reserved.
//

#import "ViewController.h"

#import <UIColor+Additions/UIColor+Additions.h>
#import <UIImage+Additions/UIImage+Additions.h>

#import "MJImageViewerGalleryViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Private Methods

- (NSArray*)mjz_arrayOfImages
{
    NSArray *images = @[@"forest1",
                        [[NSBundle mainBundle] pathForResource:@"forest2" ofType:@"jpg"],
                        [[NSBundle mainBundle] URLForResource:@"forest3" withExtension:@"jpg"],
                        @"http://assets.worldwildlife.org/photos/946/images/carousel_small/forests-why-matter_63516847.jpg",
                        [NSURL URLWithString:@"http://assets.worldwildlife.org/photos/946/images/carousel_small/forests-why-matter_63516847.jpg"],
                        [UIImage imageWithColor:[UIColor purpleColor] size:CGSizeMake(3000, 1000)],
                        [UIImage imageWithColor:[UIColor brownColor] size:CGSizeMake(1000, 3000)],
                        ];
    return images;
}

#pragma mark IBActions

- (IBAction)mjz_openImageGalleryProgramatically:(id)sender
{
    NSArray *images = [self mjz_arrayOfImages];
    MJImageViewerGalleryViewController *gallery = [[MJImageViewerGalleryViewController alloc] initWithImages:images];
    [self.navigationController pushViewController:gallery animated:YES];
}

@end
