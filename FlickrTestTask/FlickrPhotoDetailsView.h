//
//  FlickrPhotoDetailsView.h
//  FlickrTestTask
//
//  Created by Viktor Todorov on 8/29/16.
//  Copyright © 2016 jabble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrPhotoDetailsView : UIView
@property (nonatomic) IBOutlet UILabel* flickrPhotoLikes;
@property (nonatomic) IBOutlet UILabel* flickrPhotoComments;
@property (nonatomic) IBOutlet UILabel* flickrPhotoName;
@property (nonatomic) IBOutlet UILabel* flickrPhotoAuthor;
@property (nonatomic) IBOutlet UIImageView* background;
@end
