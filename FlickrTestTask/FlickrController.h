//
//  ViewController.h
//  FlickrTestTask
//
//  Created by Viktor Todorov on 8/27/16.
//  Copyright © 2016 jabble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrKit.h"
#import "UIImageView+AFNetworking.h"
#import "PhotoController.h"
#import "UserCommentView.h"
#import "FlickrPhotoDetailsView.h"

@interface FlickrController : UIViewController <UISearchBarDelegate> {
    
    NSMutableDictionary* mPhotosDictionary;
    
    //Outlets
    IBOutlet UISearchBar* mSearchBar;
    IBOutlet UILabel* mStartToSearchLabel;
    IBOutlet UIScrollView* mScrollView;
    
    NSString* mSearchedTag;
}

@end

