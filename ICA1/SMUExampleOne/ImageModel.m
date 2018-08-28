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
@property (strong,nonatomic) NSMutableArray* images;
@end

@implementation ImageModel
@synthesize imageNames = _imageNames;

-(NSArray*)imageNames{
    if (!_imageNames) {
        _imageNames = @[@"Eric1", @"Eric2", @"Eric3", @"sample1", @"sample2", @"sample3"];
    }

    return _imageNames;
}

-(NSArray*)image{
    if (!_images) {
        _images = [[NSMutableArray alloc] init];
        for (NSString* name in _imageNames) {
            [_images addObject:[self getImageWithName:name]];
        }
    }
    return _images;
}

+(ImageModel*)sharedInstance{
    static ImageModel * _sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate,^{
        _sharedInstance = [[ImageModel alloc] init];
    });
    
    return _sharedInstance;
}

-(UIImage*)getImageWithName:(NSString*)name{
    UIImage* image = nil;
    image = [UIImage imageNamed:name];
    return image;
}

-(UIImage*)getImageByIdx:(NSInteger)index{
    return self.image[index];
}

-(NSString*)getImageNameByIdx:(NSInteger)index {
    return self.imageNames[index];
}

-(NSInteger)getImageCount {
    return [self.imageNames count];
}

@end
