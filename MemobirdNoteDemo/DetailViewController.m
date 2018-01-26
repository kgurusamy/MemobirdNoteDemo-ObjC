//
//  DetailViewController.m
//  MemobirdNoteDemo
//
//  Created by Kumaravel  Gurusamy on 18/01/2018.
//  Copyright © 2018 Intretech Inc. All rights reserved.
//

#import "DetailViewController.h"
#import "SubNote.h"
#import "MainTableViewController.h"
#import "PECropViewController.h"

NSInteger textFieldDefaultTag = 10;
NSInteger imageViewDefaultTag = 20;

NSInteger vwBorderBackgoundTag = 80;
NSInteger vwImageOptionsDefaultTag = 30;
NSInteger btnReOrderButtonDefaultTag = 40;
NSInteger txtDescriptionDefaultTag = 50;

NSString *imagesDirectoryPath;

typedef enum : NSUInteger {
    TEXT=0,
    IMAGE=1
} ContentType;

@interface DetailViewController ()

@end

@implementation DetailViewController

@synthesize subNoteArray;
@synthesize selectedRowIndex;
@synthesize currentNoteIndex;
@synthesize movingCellIndex;


#pragma mark - ViewController delegate methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.movingCellIndex = -1;
    [self createImagesFolder];
    
    
    imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView setEditing:YES animated:YES];
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    if(self.subNoteArray == nil){
        self.subNoteArray = [NSMutableArray new];
        SubNote *emptyNote = [SubNote new];
        emptyNote.text = @" ";
        emptyNote.imageName = @"";
        emptyNote.type = TEXT;
        [self.subNoteArray insertObject:emptyNote atIndex:0];
    }
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
    [self setInitialFocus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.subNoteArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 48;

    SubNote *subNoteObj = (SubNote *)[self.subNoteArray objectAtIndex:indexPath.row];
    
    if(subNoteObj.type == IMAGE){
        if(self.movingCellIndex == indexPath.row){
            height = 48.0;
        }else{
            height = 280.0;
        }
    }else{
        height = 48.0;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    [self setUpCell:cell atIndex:indexPath.row];
    
    //[self reOrderCellImageChange:indexPath];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]){
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]){
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]){
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    // Configure the cell...
    cell.selectionStyle = UITableViewStylePlain;

    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    SubNote *subNoteObj = (SubNote *)[self.subNoteArray objectAtIndex:indexPath.row];
    if(subNoteObj.type == IMAGE){
        //[self reOrderCellImageChange:indexPath];
        return YES;
    }else{
        return NO;
    }
    
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    [self.subNoteArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    [tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willBeginReorderingRowAtIndexPath:(NSIndexPath *)indexPath{
    self.movingCellIndex = indexPath.row;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    //[self reOrderCellImageChange:indexPath];
    NSLog(@"Moving");
}

- (void)tableView:(UITableView *)tableView didEndReorderingRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    cell.frame = CGRectMake(cell.frame.origin.x,cell.frame.origin.y,cell.frame.size.width,280.0);

    [self reOrderCellImageChange:indexPath];
    self.movingCellIndex = -1;
    [self.tableView reloadData];
    NSLog(@"Moving ended");
}

-(void)reOrderCellImageChange:(NSIndexPath *)indexPath{
    
    SubNote *subNoteObj = (SubNote *)[self.subNoteArray objectAtIndex:indexPath.row];
    if(subNoteObj.type == IMAGE){
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    for (UIView * view in cell.subviews) {
        if ([NSStringFromClass([view class]) rangeOfString: @"Reorder"].location != NSNotFound) {
            for (UIView * subview in view.subviews) {
                if ([subview isKindOfClass: [UIImageView class]]) {
                    UIImageView *reOrderImage = ((UIImageView *)subview);
                    reOrderImage.hidden = YES;
//                    reOrderImage.image = [UIImage imageNamed: @"move_icon.png"];
//                    NSLog(@"reorderImage frame before : %f, %f, %f, %f",reOrderImage.frame.origin.x,reOrderImage.frame.origin.y,reOrderImage.frame.size.width,reOrderImage.frame.size.height);
//                    reOrderImage.frame = CGRectMake(reOrderImage.frame.origin.x, -100, 32, 32);
//                    NSLog(@"reorderImage frame after : %f, %f, %f, %f",reOrderImage.frame.origin.x,reOrderImage.frame.origin.y,reOrderImage.frame.size.width,reOrderImage.frame.size.height);
                }
            }
        }
    }
    }
}

-(void)setUpCell:(UITableViewCell*)cell atIndex:(NSInteger)index
{
    SubNote *subNote = (SubNote*)self.subNoteArray[index];
    UITextField *myTextField = [cell.contentView viewWithTag:textFieldDefaultTag];
    UIImageView *myImageView = [cell.contentView viewWithTag:imageViewDefaultTag];
    UIView *vwBackground = [cell.contentView viewWithTag:vwBorderBackgoundTag];
    UIButton *btnReOrder = [cell.contentView viewWithTag:btnReOrderButtonDefaultTag];
    if(subNote.type == TEXT){
       
        myTextField = [cell.contentView viewWithTag:textFieldDefaultTag];
        myImageView = [cell.contentView viewWithTag:imageViewDefaultTag];
        myImageView.image = nil;
        
        myTextField.delegate = self;
        myTextField.autocorrectionType = NO;
        myTextField.font = [UIFont systemFontOfSize:18.0];
        myTextField.text = subNote.text;
        myTextField.frame = CGRectMake(0, 0, self.tableView.frame.size.width-70, cell.contentView.frame.size.height);
        myTextField.autocorrectionType = false;
        [myTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        myTextField.hidden = false;
        //myTextField.backgroundColor = [UIColor lightGrayColor];
        vwBackground.hidden = true;
        btnReOrder.hidden = true;
    }
    else{
        vwBackground.frame = CGRectMake(0, 0, (self.tableView.frame.size.width/1.65)+60, 280);
        vwBackground.layer.borderWidth = 1;
        vwBackground.layer.borderColor = [UIColor grayColor].CGColor;
        vwBackground.hidden = NO;
        
        myTextField.hidden = true;
        myImageView.frame = CGRectMake(5,5,(self.tableView.frame.size.width/1.65)+50, 242);
        myImageView.contentMode = UIViewContentModeScaleToFill;
        myImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureImageView:)];
        tapImageView.numberOfTapsRequired = 1;
        //tapImageView.delegate = self;
        [myImageView addGestureRecognizer:tapImageView];
        
        SubNote *subNoteImage = (SubNote *)self.subNoteArray[index];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",imagesDirectoryPath,subNoteImage.imageName];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
        myImageView.accessibilityIdentifier = subNoteImage.imageName;
        if(data != nil){
            myImageView.image = [UIImage imageWithData:data];
        }
        myImageView.accessibilityIdentifier = subNoteImage.imageName;
        
        // Description textfield
        UITextField *txtImageDescrption = (UITextField *)[cell.contentView viewWithTag:txtDescriptionDefaultTag];
        txtImageDescrption.frame = CGRectMake(5, cell.contentView.frame.size.height-33, myImageView.frame.size.width, 30);
        txtImageDescrption.delegate = self;
        txtImageDescrption.font = [UIFont systemFontOfSize:12];
        txtImageDescrption.placeholder = @"Picture description";
        txtImageDescrption.autocorrectionType = NO;

        if([subNoteImage.text length]>0){
            txtImageDescrption.text = subNoteImage.text;
            txtImageDescrption.hidden = false;
        }else{
            txtImageDescrption.hidden = true;
        }
        btnReOrder.hidden = false;
        btnReOrder.frame = CGRectMake(self.tableView.frame.size.width-80, 10, 32, 32);
        btnReOrder.userInteractionEnabled = false;
        
        for (UIView * view in cell.subviews) {
            if ([NSStringFromClass([view class]) rangeOfString: @"Reorder"].location != NSNotFound) {
                for (UIView * subview in view.subviews) {
                    if ([subview isKindOfClass: [UIImageView class]]) {
                        UIImageView *reOrderImage = ((UIImageView *)subview);
                        reOrderImage.hidden = YES;
                    }
                }
            }
        }
        
    }
}

#pragma mark - Image picker related
// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //    You can retrieve the actual UIImage
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSString *imageName = [NSDate date].description;
    imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@""];
    imageName = [imageName stringByReplacingOccurrencesOfString:@":" withString:@""];
    imageName = [NSString stringWithFormat:@"%@.png",imageName];
    UIImage *myImage = [self fixOrientation:image];
    NSData *data = UIImagePNGRepresentation(myImage);
    NSString *fullImagePath = [NSString stringWithFormat:@"%@/%@",imagesDirectoryPath,imageName];
    BOOL success = [[NSFileManager defaultManager] createFileAtPath:fullImagePath contents:data attributes:nil];
    if(success){
        SubNote *noteImage = [SubNote new];
        noteImage.type = IMAGE;
        noteImage.imageName = imageName;
        noteImage.text = @"";
        [self.subNoteArray insertObject:noteImage atIndex:self.selectedRowIndex+1];
        if([self.subNoteArray count] == self.selectedRowIndex+1)
        {
            [self createNewCell:self.selectedRowIndex+1];
        }
    }
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)btnCameraIconClicked:(id)sender{
    [self.view endEditing:YES];
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:@"Choose Image from" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // Camera button tapped.
        [self openCamera];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // Gallery button tapped.
        [self openGallery];
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

-(void)openCamera{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = true;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"You don't have camera" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
    }
}

-(void)openGallery{
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = true;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - Custom Actions
-(IBAction)btnSaveBack_clicked:(id)sender{
    MainTableViewController *mainTableVC = self.navigationController.viewControllers[0];
    mainTableVC.selectedNoteIndex = currentNoteIndex;
    NSMutableArray *indexPaths = [self indexPathsForRowsInSection:0];
    [self.subNoteArray removeAllObjects];
    
    for(int i=0; i<indexPaths.count; i++){
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPaths[i]];
        UITextField *myTextField = [cell.contentView viewWithTag:textFieldDefaultTag];
        UIImageView *myImageView = [cell.contentView viewWithTag:imageViewDefaultTag];
        UITextField *txtDescription = [cell.contentView viewWithTag:txtDescriptionDefaultTag];
        SubNote *subNoteData = [SubNote new];
        if(myImageView.image != nil){
            subNoteData.type = IMAGE;
            subNoteData.imageName = myImageView.accessibilityIdentifier;
            subNoteData.text = txtDescription.text;
        }else{
            subNoteData.type = TEXT;
            subNoteData.imageName = @"";
            subNoteData.text = myTextField.text;
        }
        [self.subNoteArray addObject:subNoteData];
    }
    mainTableVC.subNoteArray = self.subNoteArray;
    mainTableVC.needToSyncData = YES;
    [self.navigationController popToViewController:mainTableVC animated:YES];
}

-(IBAction)btnDeleteNote_clicked:(id)sender{
    [self.view endEditing:YES];
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure want to delete?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // No button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // Yes button tapped
        MainTableViewController *mainTableVC = self.navigationController.viewControllers[0];
        mainTableVC.selectedNoteIndex = currentNoteIndex;
        mainTableVC.isDeleteNote = true;
        // Deleting all images stored in local
        for(int i=0; i<self.subNoteArray.count; i++){
             SubNote *subNote = (SubNote*)self.subNoteArray[i];
            if(subNote.type == IMAGE){
                [self deleteFileWithName:subNote.imageName];
            }
        }
        [self.navigationController popToViewController:mainTableVC animated:YES];
    }]];
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
    
   
}

#pragma mark - Image options

-(void)tapGestureImageView:(UIGestureRecognizer *)gesture{
    [self.view endEditing:YES];
    UITableViewCell *currentCell = (UITableViewCell*)gesture.view.superview.superview;
    NSIndexPath *currentIndextPath = [self.tableView indexPathForCell:currentCell];
    UIView *vwImageOptions = [currentCell.contentView viewWithTag:vwImageOptionsDefaultTag];
    if(vwImageOptions.hidden == false){
        vwImageOptions.hidden = true;
    }
    else{
        vwImageOptions.hidden = false;
    }
    NSLog(@"Image tapped on : %ld",currentIndextPath.row);
}

-(IBAction)editImageDescription_clicked:(UIButton *)sender{
    UITableViewCell *currentCell = (UITableViewCell*)sender.superview.superview.superview;
    UIView *vwImgOptions = [currentCell.contentView viewWithTag:vwImageOptionsDefaultTag];
    UITextField *txtImgDescription = [currentCell.contentView viewWithTag:txtDescriptionDefaultTag];
    txtImgDescription.hidden = false;
    vwImgOptions.hidden = true;
    if(txtImgDescription != nil){
        [currentCell setSelected:true];
        txtImgDescription.delegate = self;
        [txtImgDescription becomeFirstResponder];
    }
}

-(IBAction)deleteImage_clicked:(UIButton *)sender{
    UITableViewCell *currentCell = (UITableViewCell*)sender.superview.superview.superview;
    NSIndexPath *currentIndexPath = [self.tableView indexPathForCell:currentCell];
    UIView *vwImageOptions = (UIView*)[currentCell.contentView viewWithTag:vwImageOptionsDefaultTag];
    vwImageOptions.hidden = true;
    SubNote *subNoteObj = (SubNote *)self.subNoteArray[currentIndexPath.row];
    
    [self deleteFileWithName:subNoteObj.imageName];
    [self deleteCell:currentIndexPath.row];
    
}

-(IBAction)btnCropImage_clicked:(UIButton *)sender{
    UITableViewCell *currentCell = (UITableViewCell*)sender.superview.superview.superview;
    NSIndexPath *currentIndexPath = [self.tableView indexPathForCell:currentCell];
    self.selectedRowIndex = currentIndexPath.row;
    SubNote *subNoteData = [subNoteArray objectAtIndex:currentIndexPath.row];
    NSData *imgData = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/%@",imagesDirectoryPath, subNoteData.imageName]];
    
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = [UIImage imageWithData:imgData];
    
    UIImage *image = controller.image;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:YES completion:NULL];
    
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect
{
    // Delete existing file from local storage
    SubNote *subNoteData = [subNoteArray objectAtIndex:self.selectedRowIndex];
    NSString *imageName = subNoteData.imageName;
    [self deleteFileWithName:imageName];
    
    // Assign back the image name to cropped image
    NSString *fullImagePath = [NSString stringWithFormat:@"%@/%@",imagesDirectoryPath,imageName];
    NSData *imgData = UIImagePNGRepresentation(croppedImage);
    BOOL success = [[NSFileManager defaultManager] createFileAtPath:fullImagePath contents:imgData attributes:nil];
    if(success){
        NSLog(@"Cropped Image created successfully!");
    }
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
    [self.tableView reloadData];
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - TextField delegate methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField.tag != txtDescriptionDefaultTag){
        UITableViewCell *currentCell = (UITableViewCell*)textField.superview.superview;
        NSIndexPath *currentIndexPath = [self.tableView indexPathForCell:currentCell];
        self.selectedRowIndex = currentIndexPath.row;
        // Added
        SubNote *subNote = [self.subNoteArray objectAtIndex:self.selectedRowIndex];
        subNote.text = textField.text;
        
        [self createNewCell:currentIndexPath.row];
        
    }
    return true;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableAttributedString *combinedString = textField.attributedText.mutableCopy;
    [combinedString replaceCharactersInRange:range withString:string];
    
    if(textField.tag != txtDescriptionDefaultTag){
        UITableViewCell *currentCell = (UITableViewCell*)textField.superview.superview;
        NSIndexPath *currentIndexPath = [self.tableView indexPathForCell:currentCell];
        if([string isEqualToString:@""]){
            UITextRange *selectedRange = textField.selectedTextRange;
            long cursorPosition = [textField offsetFromPosition:textField.beginningOfDocument toPosition:selectedRange.start];
            if(cursorPosition == 1){

                [self deleteCell:currentIndexPath.row];
            }
            NSLog(@"Backspace pressed");
        }
        if(combinedString.size.width < textField.bounds.size.width){
            
        }else{
            self.selectedRowIndex = currentIndexPath.row;
            [self createNewCell:currentIndexPath.row];
        }
    }
    return combinedString.size.width < textField.bounds.size.width;
}

-(void)textFieldDidChange:(UITextField*)textField{
    if(textField.tag != txtDescriptionDefaultTag){
        UITableViewCell *currentCell =(UITableViewCell*)textField.superview.superview;
        NSIndexPath *currentIndexPath = [self.tableView indexPathForCell:currentCell];
        self.selectedRowIndex = currentIndexPath.row;
        SubNote *subNote = self.subNoteArray[currentIndexPath.row];
        subNote.text = textField.text;
        self.subNoteArray[currentIndexPath.row] = subNote;
    }
}

//-(IBAction)choosePhoto_clicked:(id)sender
//{
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.allowsEditing = YES;
//    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//
//    [self presentViewController:picker animated:YES completion:nil];
//}



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
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
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

#pragma mark - Helper methods
-(void)setInitialFocus
{
    if(self.subNoteArray.count == 0){
        [self createNewCell:-1];
    }
    
    NSMutableArray *indexPaths = [self indexPathsForRowsInSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPaths[self.subNoteArray.count-1]];
    if([cell.contentView viewWithTag:textFieldDefaultTag] != nil){
        [cell setSelected:true];
        UITextField *currentTextField = [cell.contentView viewWithTag:textFieldDefaultTag];
        currentTextField.delegate = self;
        [currentTextField becomeFirstResponder];
    }
}
                             
-(NSMutableArray*)indexPathsForRowsInSection :(NSInteger)section{
    NSMutableArray *indexPaths = [NSMutableArray new];
    //for(int i=0; i<self.tableView.numberOfSections; i++)
    //{
        for (int j=0; j<[self.tableView numberOfRowsInSection:section]; j++)
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:j inSection:section]];
        }
    //}
    return indexPaths;
}

-(void)createNewCell:(NSInteger)index
{
    SubNote *emptyNote = [[SubNote alloc] init];
    emptyNote.type = TEXT;
    emptyNote.imageName = @"";
    emptyNote.text = @" ";
    [self.subNoteArray insertObject:emptyNote atIndex:index+1];
    //[self.subNoteArray addObject:emptyNote];
    //[UIView animateWithDuration:0.1 animations:^{
        [self.tableView reloadData];
    
       
    //} completion:^(BOOL finished){
        NSMutableArray *indexPaths = [self indexPathsForRowsInSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[indexPaths objectAtIndex:index+1]];
        if([cell.contentView viewWithTag:textFieldDefaultTag]!=nil){
            [cell setSelected:YES];
            UITextField *nextTextField = [cell.contentView viewWithTag:textFieldDefaultTag];
            [nextTextField becomeFirstResponder];
       }
    //}];
}
-(void)deleteCell:(NSInteger)index{
    if([self.subNoteArray count]>1){
        [self.subNoteArray removeObjectAtIndex:index];
        //[UIView animateWithDuration:0.2 animations:^{
            [self.tableView reloadData];
        //} completion:^(BOOL finished){
            
            NSMutableArray *indexPaths = [self indexPathsForRowsInSection:0];
            UITableViewCell *cell;
            if(self.selectedRowIndex>1){
                cell = [self.tableView cellForRowAtIndexPath:(NSIndexPath*)indexPaths[index-1]];
                self.selectedRowIndex = index - 1;
            }else{
                cell = [self.tableView cellForRowAtIndexPath:(NSIndexPath*)indexPaths[0]];
                self.selectedRowIndex = 0;
            }
            if(cell != nil){
                [cell setSelected:YES];
                UITextField *previousTextField = (UITextField*)[cell.contentView viewWithTag:textFieldDefaultTag];
                if([previousTextField canBecomeFirstResponder]){
                    if([previousTextField.text length]==0){
                        previousTextField.text = @" ";
                    }
                    [previousTextField becomeFirstResponder];
                }
            }
        //}];
    }
}

-(void)createImagesFolder
{
    NSString *dirName = @"Images";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Fetch path for document directory
    imagesDirectoryPath = (NSMutableString *)[documentsDirectory stringByAppendingPathComponent:dirName];
    
    NSError *error;
    BOOL isDir;
    if(![[NSFileManager defaultManager] fileExistsAtPath:imagesDirectoryPath isDirectory:&isDir]){
        if (![[NSFileManager defaultManager] createDirectoryAtPath:imagesDirectoryPath withIntermediateDirectories:NO attributes:nil error:&error]) {
        NSLog(@"Couldn't create directory error: %@", error);
        }
        else {
            NSLog(@"directory created!");
        }
    }else {
        NSLog(@"directory already available!");
    }
}

-(void)deleteFileWithName :(NSString *)imageName{
    if(![imageName isEqualToString:@""]){
        NSError *error;
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",imagesDirectoryPath,imageName];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if(error!=nil){
            NSLog(@"Unable to delete : %@",error.description);
        }
    }
}

- (UIImage *)fixOrientation :(UIImage*)currentImage{
    
    // No-op if the orientation is already correct
    if (currentImage.imageOrientation == UIImageOrientationUp) return currentImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (currentImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, currentImage.size.width, currentImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, currentImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, currentImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
            break;
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (currentImage.imageOrientation) {
        case UIImageOrientationUp:
            break;
        case UIImageOrientationDown:
            break;
        case UIImageOrientationLeft:
            break;
        case UIImageOrientationRight:
            break;
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, currentImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, currentImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, currentImage.size.width, currentImage.size.height,
                                             CGImageGetBitsPerComponent(currentImage.CGImage), 0,
                                             CGImageGetColorSpace(currentImage.CGImage),
                                             CGImageGetBitmapInfo(currentImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (currentImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,currentImage.size.height,currentImage.size.width), currentImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,currentImage.size.width,currentImage.size.height), currentImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


@end
