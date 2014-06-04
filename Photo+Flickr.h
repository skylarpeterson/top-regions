//
//  Photo+Flickr.h
//  Top Regions
//
//  Created by Skylar Peterson on 11/14/13.
//  Copyright (c) 2013 Class Apps. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)loadPhotosFromFlickrArray:(NSArray *)photos intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
