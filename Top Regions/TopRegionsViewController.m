//
//  TopRegionsViewController.m
//  Top Regions
//
//  Created by Skylar Peterson on 11/14/13.
//  Copyright (c) 2013 Class Apps. All rights reserved.
//

#import "TopRegionsViewController.h"
#import "Photographer.h"
#import "Region.h"
#import "PhotoDatabaseAvailability.h"
#import "PhotosViewController.h"

@interface TopRegionsViewController ()

@end

#define MAX_RESULTS 50

@implementation TopRegionsViewController

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note){
                                                      self.managedObjectContext = note.userInfo[PhotoDatabaseAvailabilityContext];
                                                  }];
    self.title = @"Top Regions";
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    [request setFetchLimit:MAX_RESULTS];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"numPhotographers" ascending:YES selector:@selector(localizedStandardCompare:)],
                                [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

#define CELL_IDENTIFIER @"Region Cell"
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = region.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Photographers", region.numPhotographers.integerValue];
    
    return cell;
}

#define SEGUE_IDENTIFIER @"ShowPhotos"
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.splitViewController) {
        if ([[self.navigationController.viewControllers objectAtIndex:1] isKindOfClass:[PhotosViewController class]]) {
            PhotosViewController *viewController = [self.navigationController.viewControllers objectAtIndex:1];
            [self preparePhotosViewController:viewController forIndexPath:indexPath];
        }
    } else {
        [self performSegueWithIdentifier:SEGUE_IDENTIFIER sender:indexPath];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_IDENTIFIER]) {
        if ([segue.destinationViewController isKindOfClass:[PhotosViewController class]]) {
            PhotosViewController *viewController = segue.destinationViewController;
            [self preparePhotosViewController:viewController forIndexPath:(NSIndexPath *)sender];
        }
    }
}

- (void)preparePhotosViewController:(PhotosViewController *)viewController forIndexPath:(NSIndexPath *)indexPath
{
    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
    viewController.region = region;
    viewController.managedObjectContext = self.managedObjectContext;
}

@end
