//
//  CustomClass.h
//  SinkorSwim
//
//  Created by Ranger on 2018/9/6.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CustomClass;

@protocol CustomClassDelegate

-(void)openModal:(CustomClass *)customClass;

@end

@interface CustomClass : NSObject

@property (nonatomic, assign) id delegate;
-(void)openModalDelegate;

@end
