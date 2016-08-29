//
//  UserCommentCell.h
//  FlickrTestTask
//
//  Created by Viktor Todorov on 8/29/16.
//  Copyright © 2016 jabble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCommentCell : UITableViewCell
@property (nonatomic) IBOutlet UIImageView* userPhoto;
@property (nonatomic) IBOutlet UILabel* userComment;
@property (nonatomic) IBOutlet UILabel* userName;
@end
