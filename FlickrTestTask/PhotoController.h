//
//  PhotoController.h
//  FlickrTestTask
//
//  Created by Viktor Todorov on 8/27/16.
//  Copyright © 2016 jabble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"
#import <CoreData/CoreData.h>
#import "UserCommentCell.h"

@interface PhotoController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UIButton* mBackButton;
    IBOutlet UIButton* mSendButton;
    
    IBOutlet UIImageView* mFlickrPhoto;
    IBOutlet UIImageView* mFieldBackground;
    IBOutlet UILabel* mFlickrPhotoLikes;
    IBOutlet UILabel* mFlickrPhotoViews;
    IBOutlet UILabel* mFlickrPhotoComments;
    IBOutlet UILabel* mFlickrPhotoDescription;
    IBOutlet UILabel* mFlickrPhotoTitle;
    IBOutlet UITextField* mCommentField;
    
    IBOutlet UITableView* mTableView;

}
@property (nonatomic) NSMutableDictionary* mPhotoData;
@property (strong) NSMutableArray *mComments;

-(IBAction)mBackButtonAction:(id)sender;
-(IBAction)mSendAction:(id)sender;
@end
