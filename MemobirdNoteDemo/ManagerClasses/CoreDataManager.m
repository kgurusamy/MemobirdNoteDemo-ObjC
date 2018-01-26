//
//  CoreDataManager.m
//  MemobirdNoteDemo
//
//  Created by Kumaravel  Gurusamy on 17/01/2018.
//  Copyright © 2018 Intretech Inc. All rights reserved.
//

#import "CoreDataManager.h"

NSString * const DataManagerDidSaveNotification = @"DataManagerDidSaveNotification";
NSString * const DataManagerDidSaveFailedNotification = @"DataManagerDidSaveFailedNotification";

@interface CoreDataManager ()

- (NSString*)sharedDocumentsPath;

@end

@implementation CoreDataManager

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainObjectContext = _mainObjectContext;
@synthesize objectModel = _objectModel;

NSString * const kDataManagerBundleName = @"";
NSString * const kDataManagerModelName = @"MemobirdNoteDemo";
NSString * const kDataManagerSQLiteName = @"MemobirdNoteDemo.sqlite";

+ (CoreDataManager*)sharedInstance {
    static dispatch_once_t pred;
    static CoreDataManager *sharedInstance = nil;
    
    dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

- (void)dealloc {
    [self save];
}

- (NSManagedObjectModel*)objectModel {
    if (_objectModel)
        return _objectModel;
    
    NSBundle *bundle = [NSBundle mainBundle];
//    if (kDataManagerBundleName) {
//
////        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"CoreData" ofType:@"momd"];
////        if (!path) {
////            path = [[NSBundle mainBundle] pathForResource:@"CoreData" ofType:@"momd"];
//
//        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:kDataManagerBundleName ofType:@"bundle"];
//        bundle = [NSBundle bundleWithPath:bundlePath];
//    }
    NSString *modelPath = [bundle pathForResource:kDataManagerModelName ofType:@"momd"];
    _objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
    
    return _objectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
    if (_persistentStoreCoordinator)
        return _persistentStoreCoordinator;
    
    // Get the paths to the SQLite file
    NSString *storePath = [[self sharedDocumentsPath] stringByAppendingPathComponent:kDataManagerSQLiteName];
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    
    // Define the Core Data version migration options
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             nil];
    
    // Attempt to load the persistent store
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.objectModel];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error]) {
        NSLog(@"Fatal error while creating persistent store: %@", error);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext*)mainObjectContext {
    if (_mainObjectContext)
        return _mainObjectContext;
    
    // Create the main context only on the main thread
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(mainObjectContext)
                               withObject:nil
                            waitUntilDone:YES];
        return _mainObjectContext;
    }
    
    _mainObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_mainObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
    return _mainObjectContext;
}

- (BOOL)save {
    if (![self.mainObjectContext hasChanges])
        return YES;
    
    NSError *error = nil;
    if (![self.mainObjectContext save:&error]) {
        NSLog(@"Error while saving: %@\n%@", [error localizedDescription], [error userInfo]);
        [[NSNotificationCenter defaultCenter] postNotificationName:DataManagerDidSaveFailedNotification
                                                            object:error];
        return NO;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DataManagerDidSaveNotification object:nil];
    return YES;
}

- (NSString*)sharedDocumentsPath {
    static NSString *SharedDocumentsPath = nil;
    if (SharedDocumentsPath)
        return SharedDocumentsPath;
    
    // Compose a path to the <Library>/Database directory
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    SharedDocumentsPath = [libraryPath stringByAppendingPathComponent:@"Database"];
    
    // Ensure the database directory exists
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDirectory;
    if (![manager fileExistsAtPath:SharedDocumentsPath isDirectory:&isDirectory] || !isDirectory) {
        NSError *error = nil;
        NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                         forKey:NSFileProtectionKey];
        [manager createDirectoryAtPath:SharedDocumentsPath
           withIntermediateDirectories:YES
                            attributes:attr
                                 error:&error];
        if (error)
            NSLog(@"Error creating directory path: %@", [error localizedDescription]);
    }
    
    return SharedDocumentsPath;
}

- (NSManagedObjectContext*)managedObjectContext {
    NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [ctx setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
    return ctx;
}

@end
