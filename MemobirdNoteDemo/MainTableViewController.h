//
//  MainTableViewController.h
//  MemobirdNoteDemo
//
//  Created by Kumaravel  Gurusamy on 17/01/2018.
//  Copyright © 2018 Intretech Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notes+CoreDataClass.h"

@interface MainTableViewController : UITableViewController <UISearchResultsUpdating>
{
    NSMutableArray *notes;
    NSMutableArray *filteredNotes;
    BOOL needToSyncData;
    NSMutableArray *subNoteArray;
    NSInteger selectedNoteIndex;
    BOOL isDeleteNote;
    UISearchController *searchController;
}

@property(nonatomic, strong) NSMutableArray *notes, *filteredNotes;
@property(nonatomic, strong) NSMutableArray *subNoteArray;
@property(nonatomic, strong) UISearchController *searchController;
@property(nonatomic) BOOL needToSyncData;
@property(nonatomic) BOOL isDeleteNote;
@property(nonatomic) NSInteger selectedNoteIndex;

-(IBAction)addNote_clicked:(id)sender;


@end
