//
//  Helper.m
//  StarshipComander
//
//  Created by Arcilite on 20.09.14.
//  Copyright (c) 2014 Ramotion. All rights reserved.
//

#import "Helper.h"

@implementation Helper

+(BOOL) getYesOrNo{
    
    int tmp = (arc4random() % 3)+1;
    if(tmp % 5 == 0)
        return YES;
    return NO;
    
}

+(int) randomInt{
    int tmp = (arc4random() % 100);
    return tmp;
}

@end
