//
//  TopRegionsAppDelegate.m
//  Top Regions
//
//  Created by Skylar Peterson on 11/14/13.
//  Copyright (c) 2013 Class Apps. All rights reserved.
//

#import "TopRegionsAppDelegate.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "PhotoDatabaseAvailability.h"

@interface TopRegionsAppDelegate() <NSURLSessionDownloadDelegate>
@property (copy, nonatomic) void (^flickrDownloadBackgroundURLSessionCompletionHandler)();
@property (strong, nonatomic) NSURLSession *flickrDownloadSession;
@property (strong, nonatomic) NSTimer *flickrForegroundFetchTimer;
@property (strong, nonatomic) UIManagedDocument *document;
@end

#define FLICKR_FETCH @"Flickr Just Uploaded Fetch"
#define FOREGROUND_FLICKR_FETCH_INTERVAL (20*60)
#define BACKGROUND_FLICKR_FETCH_TIMEOUT (10)

@implementation TopRegionsAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                     inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = @"MyDocument";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if ([fileManager fileExistsAtPath:[url path]]) {
        [self.document openWithCompletionHandler:^(BOOL success){
            if (success) [self documentIsReady];
            if (!success) NSLog(@"Couldn't open document at url %@", url);
        }];
    } else {
        [self.document saveToURL:url
                forSaveOperation:UIDocumentSaveForCreating
               completionHandler:^(BOOL success){
                   if (success) [self documentIsReady];
                   if (!success) NSLog(@"Couldn't open document at url %@", url);
               }];
    }
    return YES;
}

- (void)documentIsReady
{
    if (self.document.documentState == UIDocumentStateNormal) {
        [self startFlickrFetch];
        [self.flickrForegroundFetchTimer invalidate];
        self.flickrForegroundFetchTimer = nil;
        
        if (self.document) {
            self.flickrForegroundFetchTimer = [NSTimer scheduledTimerWithTimeInterval:FOREGROUND_FLICKR_FETCH_INTERVAL
                                                                               target:self
                                                                             selector:@selector(startFlickrFetch:)
                                                                             userInfo:nil
                                                                              repeats:YES];
        }
        NSDictionary *userInfo = self.document ? @{ PhotoDatabaseAvailabilityContext : self.document.managedObjectContext } : nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification
                                                            object:self
                                                          userInfo:userInfo];
    }
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if (self.document) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.allowsCellularAccess = NO;
        sessionConfig.timeoutIntervalForRequest = BACKGROUND_FLICKR_FETCH_TIMEOUT;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
        NSURLSessionDownloadTask *task;
        task = [session downloadTaskWithRequest:request
                              completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                                  [self loadFlickrPhotosFromLocalURL:localFile
                                                         intoContext:self.document.managedObjectContext
                                                 andThenExecuteBlock:^{
                                                     completionHandler(UIBackgroundFetchResultNewData);
                                                 }];
                              }];
        [task resume];
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    self.flickrDownloadBackgroundURLSessionCompletionHandler = completionHandler;
}

#pragma mark - Flickr Fetching

- (void)startFlickrFetch {
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTaks){
        if (![downloadTaks count]) {
            NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription = FLICKR_FETCH;
            [task resume];
        } else {
            for (NSURLSessionDownloadTask *task in downloadTaks) [task resume];
        }
    }];
}

- (void)startFlickrFetch:(NSTimer *)timer
{
    [self startFlickrFetch];
}

- (NSURLSession *)flickrDownloadSession
{
    if (!_flickrDownloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *urlSessionConfig= [NSURLSessionConfiguration backgroundSessionConfiguration:FLICKR_FETCH];
            urlSessionConfig.allowsCellularAccess = NO;
            _flickrDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig
                                                                   delegate:self
                                                              delegateQueue:nil];
        });
    }
    return _flickrDownloadSession;
}

- (NSArray *)flickrPhotosAtURL:(NSURL *)url
{
    NSDictionary *flickrPropertyList;
    NSData *flickrJSONData = [NSData dataWithContentsOfURL:url];
    if (flickrJSONData) {
        flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData
                                                             options:0
                                                               error:NULL];
    }
    return [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
}

- (void)loadFlickrPhotosFromLocalURL:(NSURL *)localFile
                         intoContext:(NSManagedObjectContext *)context
                 andThenExecuteBlock:(void(^)())whenDone
{
    if (context) {
        NSArray *photos = [self flickrPhotosAtURL:localFile];
        [context performBlock:^{
            [Photo loadPhotosFromFlickrArray:photos intoManagedObjectContext:context];
            if (whenDone) whenDone();
        }];
    } else {
        if (whenDone) whenDone();
    }
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {
        [self loadFlickrPhotosFromLocalURL:location
                               intoContext:self.document.managedObjectContext
                       andThenExecuteBlock:^{
                           [self flickrDownloadTasksMightBeComplete];
                       }];
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    //not supported - required by protocol
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //not supported - required by protocol
}

- (void)flickrDownloadTasksMightBeComplete
{
    if (self.flickrDownloadBackgroundURLSessionCompletionHandler) {
        [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks){
            if (![downloadTasks count]) {
                void (^completionHandler)() = self.flickrDownloadBackgroundURLSessionCompletionHandler;
                self.flickrDownloadBackgroundURLSessionCompletionHandler = nil;
                if (completionHandler) completionHandler();
            }
        }];
    }
}

@end
