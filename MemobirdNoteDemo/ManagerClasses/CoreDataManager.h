//
//  CoreDataManager.h
//  MemobirdNoteDemo
//
//  Created by Kumaravel  Gurusamy on 17/01/2018.
//  Copyright © 2018 Intretech Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const DataManagerDidSaveNotification;
extern NSString * const DataManagerDidSaveFailedNotification;

@interface CoreDataManager : NSObject{
}

@property (nonatomic, readonly, retain) NSManagedObjectModel *objectModel;
@property (nonatomic, readonly, retain) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CoreDataManager*)sharedInstance;
- (BOOL)save;
- (NSManagedObjectContext*)managedObjectContext;

@end
