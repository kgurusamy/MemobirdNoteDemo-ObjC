//
//  DetailViewController.h
//  MemobirdNoteDemo
//
//  Created by Kumaravel  Gurusamy on 18/01/2018.
//  Copyright © 2018 Intretech Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PECropViewController.h"


@interface DetailViewController : UITableViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,UIActionSheetDelegate,PECropViewControllerDelegate>
{
    NSMutableArray *subNoteArray;
    NSInteger selectedRowIndex;
    UIImagePickerController *imagePicker;
    NSInteger currentNoteIndex;
    NSInteger movingCellIndex;
}


@property(nonatomic,strong)NSMutableArray *subNoteArray;
@property(nonatomic) NSInteger selectedRowIndex;
@property(nonatomic) NSInteger currentNoteIndex;
@property(nonatomic) NSInteger movingCellIndex;
@end
