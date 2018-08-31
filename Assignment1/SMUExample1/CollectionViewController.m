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

@property (strong, nonatomic) NSMutableArray* myImages;
@property (strong, nonatomic) NSIndexPath* currIndex;

@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"ImageCollectCell";

-(NSMutableArray*)myImages{
    if (!_myImages) {
        _myImages = [[NSMutableArray alloc] init];
        for (NSString* name in _galleryNames) {
            [_myImages addObject:[self getImageWithName:name]];
        }
    }
    return _myImages;
}

-(UIImage*)getImageWithName:(NSString*)name{
    UIImage* image = nil;
    image = [UIImage imageNamed:name];
    return image;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
//    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    BOOL isVC = [[segue destinationViewController] isKindOfClass:[ViewController class]];
    
    if(isVC){
        ViewController *vc = [segue destinationViewController];
        vc.currImage = self.myImages[_currIndex.row];
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
    return [self.myImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    cell.backgroundColor = [UIColor blueColor];
    cell.imageView.image = self.myImages[indexPath.row];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
