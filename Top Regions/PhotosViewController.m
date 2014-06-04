//
//  PhotosViewController.m
//  Top Places
//
//  Created by Skylar Peterson on 11/6/13.
//  Copyright (c) 2013 Class Apps. All rights reserved.
//

#import "PhotosViewController.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"

#import "Photo.h"

@interface PhotosViewController ()

@end

#define MAX_RESULTS 50
@implementation PhotosViewController

- (void)setRegion:(Region *)region
{
    _region = region;
    if (self.managedObjectContext) [self loadFetchedResults];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (self.region) [self loadFetchedResults];
}

- (void)loadFetchedResults
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"region.name == %@", self.region.name];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

#define CELL_IDENTIFIER @"Photo Cell"
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    
    if (photo.thumbnailData == nil) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:photo.thumbnailURL]];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
        
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error){
                                                            if (!error) {
                                                                if ([request.URL isEqual:[NSURL URLWithString:photo.thumbnailURL]]) {
                                                                    photo.thumbnailData = [NSData dataWithContentsOfURL:localfile];
                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                        cell.imageView.image = [UIImage imageWithData:photo.thumbnailData];
                                                                    });
                                                                }
                                                            }
                                                        }];
        [task resume];
    } else {
        cell.imageView.image = [UIImage imageWithData:photo.thumbnailData];
    }
    
    return cell;
}

#define SEGUE_IDENTIFIER @"ShowPhoto"
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.splitViewController) {
        UINavigationController *navController = [self.splitViewController.viewControllers objectAtIndex:1];
        if ([[navController.viewControllers objectAtIndex:0] isKindOfClass:[PhotoViewController class]]) {
            PhotoViewController *viewController = [navController.viewControllers objectAtIndex:0];
            [self preparePhotoViewController:viewController forIndexPath:indexPath];
        }
    } else {
        [self performSegueWithIdentifier:SEGUE_IDENTIFIER sender:indexPath];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_IDENTIFIER]) {
        if ([segue.destinationViewController isKindOfClass:[PhotoViewController class]]) {
            PhotoViewController *viewController = segue.destinationViewController;
            [self preparePhotoViewController:viewController forIndexPath:(NSIndexPath *)sender];
        }
    }
}

- (void)preparePhotoViewController:(PhotoViewController *)viewController forIndexPath:(NSIndexPath *)indexPath
{
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    photo.viewDate = [NSDate date];
    viewController.imageURL = [NSURL URLWithString:photo.photoURL];
}

@end
