//
//  ViewController.m
//  FlickrTestTask
//
//  Created by Viktor Todorov on 8/27/16.
//  Copyright © 2016 jabble. All rights reserved.
//

#import "FlickrController.h"

@interface FlickrController ()

@end

@implementation FlickrController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = true;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Fetch the comments from persistent data store
    if (![mSearchedTag isEqualToString:@""]) {
       [self searchFlickrPhotosWithKeyword:mSearchedTag];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark LOAD DATA

- (void)searchFlickrPhotosWithKeyword:(NSString*)keyword {
    for (UIView *subview in mScrollView.subviews) {
        [subview removeFromSuperview];
    }
    mScrollView.contentSize = CGSizeMake(self.view.frame.size.width, 0);
    
    [self.view endEditing:YES];
    
    FKFlickrPhotosSearch *search = [[FKFlickrPhotosSearch alloc] init];
    search.tags = keyword;
    search.per_page = @"50";
    search.extras = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@",@"owner_name",@"description",@"o_dims",@"views",@"geo",@"count_faves"];
    
    [[FlickrKit sharedFlickrKit] call:search completion:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response) {
                NSMutableArray* _commentsArray = [self loadCommentsFromCoreData];
                
                mPhotosDictionary = [NSMutableDictionary new];
                int _counter = 0;
                for (NSDictionary *photoDictionary in [response valueForKeyPath:@"photos.photo"]) {
                    NSURL *url = [[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeSmall240 fromPhotoDictionary:photoDictionary];
                    
                    NSMutableDictionary* _photo = [NSMutableDictionary new];
                    [_photo setObject:url forKey:@"PhotoURL"];
                    [_photo setObject:[photoDictionary valueForKey:@"title"] forKey:@"PhotoTitle"];
                    [_photo setObject:[photoDictionary valueForKey:@"id"] forKey:@"PhotoID"];
                    [_photo setObject:[photoDictionary valueForKey:@"ownername"] forKey:@"PhotoOwner"];
                    [_photo setObject:[photoDictionary valueForKey:@"description"] forKey:@"PhotoDescription"];
                    [_photo setObject:[photoDictionary objectForKey:@"views"] forKey:@"PhotoViews"];
                    [_photo setObject:[photoDictionary objectForKey:@"count_faves"] forKey:@"PhotoFaves"];
                    [_photo setObject:[NSNumber numberWithFloat:190] forKey:@"PhotoHeight"];
                    
                    NSMutableArray* _newCommentToAdd = [NSMutableArray array];
                    for (NSManagedObject* comment in _commentsArray) {
                        if ([[comment valueForKey:@"photoId"] isEqualToString:[photoDictionary valueForKey:@"id"]]) {
                            
                            [_newCommentToAdd addObject:comment];
                        }
                    }
                    [_photo setObject:_newCommentToAdd forKey:@"PhotoComments"];
                    [mPhotosDictionary setObject:_photo forKey:[NSString stringWithFormat:@"%i",_counter]];
                    _counter++;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Any GUI related operations here
                    for (int i = 0; i < mPhotosDictionary.count; i++) {
                        NSURL* _photoURL = [[mPhotosDictionary objectForKey:[NSString stringWithFormat:@"%i",i]] objectForKey:@"PhotoURL"];
                        
                        NSURLRequest* urlRequest = [NSURLRequest requestWithURL:_photoURL];
                                                   
                        [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                            
                            UIImage *image = [[UIImage alloc] initWithData:data];
                            [self addImageToView:image photoData:[mPhotosDictionary objectForKey:[NSString stringWithFormat:@"%i",i]] tag:i];
                            
                        }];
                    }
                    
                });

            } else {
                
            }
        });
    }];    
}

#pragma mark SCROLL VIEW METHODS
- (void) addImageToView:(UIImage *)image photoData:(NSMutableDictionary*)photoData tag:(int)tag {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setUserInteractionEnabled:true];
    imageView.tag = tag;
    
    UITapGestureRecognizer *_imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture:)];
    _imageTap.numberOfTapsRequired = 1;
    [imageView addGestureRecognizer:_imageTap];
    
    //Calculate the image width to be proportionally fixed to match the screen width
    CGFloat width = CGRectGetWidth(mScrollView.frame);
    CGFloat imageRatio = image.size.width / image.size.height;
    CGFloat height = width / imageRatio;
    CGFloat x = 0;
    CGFloat y = mScrollView.contentSize.height;
    
    //Add The Photo Details view at the bottom of the imageview and load the data
    NSArray *_subviewArray = [[NSBundle mainBundle] loadNibNamed:@"FlickrPhotoDetailsView" owner:self options:nil];
    FlickrPhotoDetailsView *_detailsView = [_subviewArray objectAtIndex:0];
    _detailsView.frame = CGRectMake(0, height-_detailsView.frame.size.height, self.view.frame.size.width, _detailsView.frame.size.height);
    
    [imageView addSubview:_detailsView];
    
    //Add photo title
    _detailsView.flickrPhotoName.text = [photoData valueForKey:@"PhotoTitle"];
    
    //Add photo author
    _detailsView.flickrPhotoAuthor.text = [NSString stringWithFormat:@"By %@",[photoData valueForKey:@"PhotoOwner"]];
    
    //Add photo likes
    int _photoFavesNumber = [[photoData objectForKey:@"PhotoFaves"] intValue];
    NSString* _photoFavesText = @"99+";
    if (_photoFavesNumber <= 99) {
        _detailsView.flickrPhotoLikes.text = [NSString stringWithFormat:@"%i",_photoFavesNumber];
    }
    else {
        _detailsView.flickrPhotoLikes.text = _photoFavesText;
    }
    
    //Set the new imageview frame
    imageView.frame = CGRectMake(x, y, width, height);
    
    CGFloat newHeight = mScrollView.contentSize.height + height;
    mScrollView.contentSize = CGSizeMake(self.view.frame.size.width, newHeight);
    
    [mScrollView addSubview:imageView];
    
    //Add photo comments
    NSMutableArray* _commentsArray = [photoData objectForKey:@"PhotoComments"];
    _detailsView.flickrPhotoComments.text = [NSString stringWithFormat:@"%i",(int)[_commentsArray count]];
    
    if (_commentsArray.count > 0) {
        for (int i = 0; i < _commentsArray.count; i++) {
            if (i < 3) {
                NSArray *_subviewArray = [[NSBundle mainBundle] loadNibNamed:@"UserCommentView" owner:self options:nil];
                UserCommentView *_commentView = [_subviewArray objectAtIndex:0];
                float _newHeight = mScrollView.contentSize.height;
                _commentView.frame = CGRectMake(0, _newHeight, _commentView.frame.size.width, _commentView.frame.size.height);
                
                //Load from Core Data the comment
                NSManagedObject *_comment = [_commentsArray objectAtIndex:i];
                _commentView.commentUsername.text = [_comment valueForKey:@"authorName"];
                _commentView.commentText.text = [_comment valueForKey:@"comment"];
                
                CGFloat newHeight = mScrollView.contentSize.height + _commentView.frame.size.height;
                mScrollView.contentSize = CGSizeMake(self.view.frame.size.width, newHeight);
                
                [mScrollView addSubview:_commentView];
            }
            
        }
    }
}
- (void) tapGesture: (UITapGestureRecognizer*)sender
{
    [self.view endEditing:true];
    if(![sender.view isKindOfClass:[UIImageView class]]) {
        return;
    }
    int _photoTag = (int)[(UIImageView*)sender.view tag];
    PhotoController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"storyboardPhoto"];
    viewController.mPhotoData = [mPhotosDictionary objectForKey:[NSString stringWithFormat:@"%i",_photoTag]];
    [self.navigationController pushViewController:viewController animated:YES];
}
#pragma mark SEARCH BAR METHODS
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    mStartToSearchLabel.hidden = true;
    mSearchedTag = searchBar.text;
    
    [self searchFlickrPhotosWithKeyword:searchBar.text];
}
#pragma mark CORE DATA

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
-(NSMutableArray*)loadCommentsFromCoreData {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Comment"];
    
    return [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
}
@end
