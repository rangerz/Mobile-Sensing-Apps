//
//  CustomClass.m
//  SinkorSwim
//
//  Created by Ranger on 2018/9/6.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

#import "CustomClass.h"

@implementation CustomClass

-(void)openModalDelegate
{
    [_delegate openModal:self];
}

-(void)dealloc
{
    _delegate = nil;
}

@end
