//
//  Photo.h
//  Top Regions
//
//  Created by Skylar Peterson on 11/15/13.
//  Copyright (c) 2013 Class Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer, Region;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSDate * viewDate;
@property (nonatomic, retain) NSData * thumbnailData;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) Photographer *whoTook;
@property (nonatomic, retain) Region *region;

@end
