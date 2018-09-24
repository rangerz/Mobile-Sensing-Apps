//
//  ViewController.m
//  SMUExampleOne
//
//  Created by Alejandro Henkel on 8/26/18.
//  Copyright © 2018 Alejandro Henkel. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) UIImage* imageData;
@property (strong, nonatomic) UIImageView* imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation ViewController

-(void)setImageData: (UIImage*)image {
    _imageData = image;
}

-(UIImageView*)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage: self.imageData];
    }
    return _imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.scrollView addSubview:self.imageView];
    self.scrollView.contentSize = self.imageView.image.size;
    self.scrollView.minimumZoomScale = 0.1;
    self.scrollView.delegate = self;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

@end
