//
//  RecentPhotosViewController.m
//  Top Regions
//
//  Created by Skylar Peterson on 11/15/13.
//  Copyright (c) 2013 Class Apps. All rights reserved.
//

#import "RecentPhotosViewController.h"
#import "PhotoDatabaseAvailability.h"
#import "Photo.h"
#import "PhotoViewController.h"

@interface RecentPhotosViewController ()

@end

@implementation RecentPhotosViewController

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note){
                                                      self.managedObjectContext = note.userInfo[PhotoDatabaseAvailabilityContext];
                                                  }];
    self.title = @"Recently Viewed Photos";
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"viewDate != nil"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"viewDate" ascending:YES]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

#define CELL_IDENTIFIER @"Recent Cell"
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    cell.imageView.image = [UIImage imageWithData:photo.thumbnailData];
    
    return cell;
}

#define SEGUE_IDENTIFIER @"Show Recent Photo"
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
    viewController.imageURL = [NSURL URLWithString:photo.photoURL];
}

@end
