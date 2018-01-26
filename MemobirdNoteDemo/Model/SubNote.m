//
//  subNote.m
//  MemobirdNoteDemo
//
//  Created by Kumaravel  Gurusamy on 17/01/2018.
//  Copyright © 2018 Intretech Inc. All rights reserved.
//

#import "SubNote.h"

@implementation SubNote

@synthesize text;
@synthesize type;
@synthesize imageName;

-(void)init:(NSInteger)type :(NSString*)text :(NSString*)imageName
{
    self.type = type;
    self.text = text;
    self.imageName = imageName;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.text = [decoder decodeObjectForKey:@"text"];
        self.imageName = [decoder decodeObjectForKey:@"imageName"];
        self.type = [decoder decodeIntegerForKey:@"type"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.text forKey:@"text"];
    [encoder encodeObject:self.imageName forKey:@"imageName"];
    [encoder encodeInteger:self.type forKey:@"type"];
}


@end
