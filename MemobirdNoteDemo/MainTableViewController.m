//
//  MainTableViewController.m
//  MemobirdNoteDemo
//
//  Created by Kumaravel  Gurusamy on 17/01/2018.
//  Copyright © 2018 Intretech Inc. All rights reserved.
//

#import "MainTableViewController.h"
#import "CoreDataManager.h"
#import "DetailViewController.h"
#import "SubNote.h"

NSInteger dateLabelDefaultTag = 10;
NSInteger noteLabelDefaultTag = 20;

@interface MainTableViewController ()

@end

@implementation MainTableViewController

@synthesize notes,filteredNotes, searchController;
@synthesize needToSyncData;
@synthesize subNoteArray;
@synthesize selectedNoteIndex;
@synthesize isDeleteNote;

- (void)viewDidLoad {
    [super viewDidLoad];
    notes = [NSMutableArray new];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    [self getSavedData];
    self.tableView.separatorColor = [UIColor clearColor];
    
    // setup search controller
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = false;
    self.searchController.hidesNavigationBarDuringPresentation = false;
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = searchController.searchBar;
    [self.searchController.searchBar sizeToFit];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(self.needToSyncData == true){
        [self save_data];
        needToSyncData = false;
    }
    if(self.isDeleteNote == true){
        [self deleteNote];
        isDeleteNote = false;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
   
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    if([searchText isEqualToString:@""]){
        self.filteredNotes = self.notes;
    }else{
         NSMutableArray *searchResults = [[NSMutableArray alloc] init];
        
        for(Notes *note in self.notes){
            NSLog(@"Note name : %@",note.name);
            if([note.name containsString:searchText]){
                [searchResults addObject:note];
            }
        }
        self.filteredNotes = searchResults;
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete implementation, return the number of rows
    if([self.searchController.searchBar.text isEqualToString:@""]){
        return [self.notes count];
    }else{
        return [self.filteredNotes count];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell" forIndexPath:indexPath];

    UILabel *lblNoteName =(UILabel *)[cell.contentView viewWithTag:noteLabelDefaultTag];
    UILabel *lblDate = (UILabel*)[cell.contentView viewWithTag:dateLabelDefaultTag];
    Notes *note;
    
    if([self.searchController.searchBar.text isEqualToString:@""]){
        note = self.notes[indexPath.row];
    }else{
        note = self.filteredNotes[indexPath.row];
    }
    lblNoteName.text = note.name;
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"dd-MM-yyyy hh:mm a";
    NSDate *lastModifiedTime = note.modified_time;
    lblDate.text = [formatter stringFromDate:lastModifiedTime];
    
    // Configure the cell...
 
    return cell;
 }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailViewController *detailVC = [storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailVC.currentNoteIndex = indexPath.row;
    //NSMutableArray *subNoteArr = [NSMutableArray new];
    //[notes objectAtIndex:in dexPath.row];
    Notes *note = [notes objectAtIndex:indexPath.row];
    
    NSMutableArray *subNote = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData*)note.subNote];
    NSLog(@"SubNote : %@",subNote);
   
    
    if(subNote !=nil)
    {
        //[subNoteArr insertObject:subNote atIndex:0];
        detailVC.subNoteArray = subNote;
    }
    else
    {
        detailVC.subNoteArray = nil;
    }
   
    [self.navigationController pushViewController:detailVC animated:YES];
}
 
#pragma mark - Coredata Methods
-(IBAction)addNote_clicked:(id)sender
{
    [self initialSave];
    [self getSavedData];
    [self.tableView reloadData];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailViewController *detailVC = [storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    [self.navigationController pushViewController:detailVC animated:YES];
    
    //DetailViewController *detailVC = [DetailViewController new];
    //[self.navigationController pushViewController:detailVC animated:YES];
}

-(void)deleteNote{
    [[[CoreDataManager sharedInstance] mainObjectContext] deleteObject:notes[self.selectedNoteIndex]];
    [[CoreDataManager sharedInstance] save];
    [self getSavedData];
    [self.tableView reloadData];
}

-(void)initialSave
{
    //NSManagedObjectContext *ctx = [[CoreDataManager sharedInstance] mainObjectContext];
    Notes *coreDataNote = [NSEntityDescription insertNewObjectForEntityForName:@"Notes" inManagedObjectContext:[[CoreDataManager sharedInstance] mainObjectContext]];
    //Notes *coreDataNote = [Notes];
    coreDataNote.name = @" ";
    coreDataNote.modified_time = NSDate.date;
    coreDataNote.subNote = nil;
    [[CoreDataManager sharedInstance] save];
}

-(void)save_data{
    SubNote *checkSubNote = (SubNote*)subNoteArray[0];
    if(subNoteArray.count == 1 && ([checkSubNote.text isEqualToString:@""] || [checkSubNote.text isEqualToString:@" "])){
        [[[CoreDataManager sharedInstance] mainObjectContext] deleteObject:notes[self.selectedNoteIndex]];
        [[CoreDataManager sharedInstance] save];
    }else{
        
        NSFetchRequest *fetchRequest = [NSFetchRequest new];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notes" inManagedObjectContext:[[CoreDataManager sharedInstance] mainObjectContext]];
        [fetchRequest setEntity:entity];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"modified_time" ascending:false];
        fetchRequest.sortDescriptors = [NSArray arrayWithObject:sort];
        @try{
            NSError *error;
            id records = [[[CoreDataManager sharedInstance] mainObjectContext] executeRequest:fetchRequest error:&error];
    
            NSMutableArray *notesData = [[records finalResult] mutableCopy];
            Notes *saveNote =notesData[self.selectedNoteIndex];
            
            NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:subNoteArray];
            saveNote.subNote = encodedData;
            saveNote.modified_time = [NSDate date];
            saveNote.name = @"";
            
            for(int i=0; i<subNoteArray.count; i++){
                SubNote *subNote = (SubNote*)subNoteArray[i];
                NSString *subNoteText = subNote.text;
                if([subNoteText length]>0 && ![subNoteText isEqualToString:@" "]){
                    saveNote.name = subNoteText;
                    break;
                }
            }
            if(saveNote.name == nil){
                saveNote.name = @" ";
            }
        }
        @catch(NSError *error){
            
        }
        [[CoreDataManager sharedInstance] save];
    }
    [self getSavedData];
    [self.tableView reloadData];
}


-(void)getSavedData
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notes" inManagedObjectContext:[[CoreDataManager sharedInstance] mainObjectContext]];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"modified_time" ascending:false];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:sort];
    NSError *error;
    id tempArray = [[[CoreDataManager sharedInstance] mainObjectContext] executeRequest:fetchRequest error:&error];
    self.notes = [[tempArray finalResult] mutableCopy];
    //notes = [[[[CoreDataManager sharedInstance] mainObjectContext] executeRequest:fetchRequest error:&error] copy];
    if(error)
    {
        NSLog(@"CoreData Error : %@", error.description);
    }
    
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
