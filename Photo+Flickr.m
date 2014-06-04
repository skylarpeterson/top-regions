//
//  Photo+Flickr.m
//  Top Regions
//
//  Created by Skylar Peterson on 11/14/13.
//  Copyright (c) 2013 Class Apps. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+Create.h"
#import "Region+Flickr.h"

@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSString *unique = photoDictionary[FLICKR_PHOTO_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //handle error
    } else if ([matches count]) {
        photo = [matches firstObject];
    } else {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                              inManagedObjectContext:context];
        photo.unique = unique;
        photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.photoURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
        photo.thumbnailURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
        
        NSString *photographerName = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
        photo.whoTook = [Photographer photographerWithName:photographerName
                                    inManagedObjectContext:context];
        
        dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher", NULL);
        dispatch_async(fetchQ, ^{
            id placeID = [photoDictionary valueForKeyPath:FLICKR_PHOTO_PLACE_ID];
            NSURL *url = [FlickrFetcher URLforInformationAboutPlace:placeID];
            NSData *data = [NSData dataWithContentsOfURL:url];
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                       options:0
                                                                         error:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *regionName = [FlickrFetcher extractNameOfPlace:placeID fromPlaceInformation:dictionary];
                Region *region = [Region regionWithName:regionName inManagedObjectContext:context];
                photo.region = region;
                [region addPhotographer:photo.whoTook];
                [region addPhotosObject:photo];
            });
        });
    }
    
    return photo;
}

+ (void)loadPhotosFromFlickrArray:(NSArray *)photos intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *photo in photos) {
        [self photoWithFlickrInfo:photo inManagedObjectContext:context];
    }
}

@end
