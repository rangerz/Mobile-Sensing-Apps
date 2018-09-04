//
//  CollectionViewController.m
//  SMUExample1
//
//  Created by Alejandro Henkel on 8/26/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionViewCell.h"
#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface CollectionViewController ()
@property (strong, nonatomic) NSArray* imageNames;
@property (strong, nonatomic) NSMutableArray* imageData;
@property (strong, nonatomic) NSIndexPath* currIndex;
@end

@implementation CollectionViewController

-(void)setImageNames: (NSArray*)imageNames {
    _imageNames = imageNames;
}

-(NSMutableArray*)imageData {
    if (!_imageData) {
        _imageData = [[NSMutableArray alloc] init];
        for (NSString* name in self.imageNames) {
            [_imageData addObject:[self getImageWithName:name]];
        }
    }
    return _imageData;
}

-(UIImage*)getImageWithName:(NSString*)name {
    UIImage* image = nil;
    image = [UIImage imageNamed:name];
    return image;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    BOOL isVC = [[segue destinationViewController] isKindOfClass:[ViewController class]];
    
    if (isVC) {
        ViewController *vc = [segue destinationViewController];
        [vc setImageData: self.imageData[_currIndex.row]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    _currIndex = indexPath;
    [self performSegueWithIdentifier:@"ToImageZoom" sender:self];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imageData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCollectCell" forIndexPath:indexPath];

    // Configure the cell
    cell.backgroundColor = [UIColor blueColor];
    cell.imageView.image = self.imageData[indexPath.row];

    return cell;
}

@end
