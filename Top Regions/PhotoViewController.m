//
//  PhotoViewController.m
//  Top Places
//
//  Created by Skylar Peterson on 11/6/13.
//  Copyright (c) 2013 Class Apps. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation PhotoViewController

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    
    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    [self.activityIndicator stopAnimating];
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    
    _scrollView.minimumZoomScale = 0.5;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self downloadImage];
}

- (void)downloadImage
{
    self.image = nil;
    if (self.imageURL) {
        [self.activityIndicator startAnimating];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
        
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error){
                                                            if (!error) {
                                                                if ([request.URL isEqual:self.imageURL]) {
                                                                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                        self.image = image;
                                                                    });
                                                                }
                                                            }
                                                        }];
        [task resume];
    }
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    UINavigationController *navController = [self.splitViewController.viewControllers objectAtIndex:0];
    UIViewController *masterViewController = [[navController viewControllers]objectAtIndex: 0];
    barButtonItem.title = masterViewController.title;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}

@end
