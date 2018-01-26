//
//  subNote.h
//  MemobirdNoteDemo
//
//  Created by Kumaravel  Gurusamy on 17/01/2018.
//  Copyright © 2018 Intretech Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubNote : NSObject<NSCoding>

@property(nonatomic) NSInteger type;
@property(nonatomic, strong) NSString *imageName;
@property(nonatomic, strong) NSString *text;

@end
