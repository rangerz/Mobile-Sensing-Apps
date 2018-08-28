//
//  ImageModel.m
//  SMUExampleOne
//
//  Created by Eric Larson on 1/21/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

#import "ImageModel.h"

@interface ImageModel()
@property (strong,nonatomic) NSArray* imageNames;
@end
@implementation ImageModel

@synthesize imageNames = _imageNames;

-(NSArray*)imageNames{
    
    if(!_imageNames)
        _imageNames = @[@"Eric1",@"Eric2",@"Eric3"];
    
    return _imageNames;
}

+(ImageModel*)sharedInstance{
    static ImageModel * _sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate,^{
        _sharedInstance = [[ImageModel alloc] init];
    });
    
    return _sharedInstance;
}

-(UIImage*)getImageWithName:(NSString *)name{
    UIImage* image = nil;
    image = [UIImage imageNamed:name];
    return image;
}

-(UIImage*)getImageByIdx:(NSInteger)index{
    UIImage* image = nil;
    NSString* name = [self getImageNameByIdx: index];
    image = [UIImage imageNamed:name];
    return image;
}

-(NSInteger)getImageCount {
    return [self.imageNames count];
}

-(NSString*)getImageNameByIdx:(NSInteger) index {
    return self.imageNames[index];
}

@end
