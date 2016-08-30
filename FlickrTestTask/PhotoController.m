//
//  PhotoController.m
//  FlickrTestTask
//
//  Created by Viktor Todorov on 8/27/16.
//  Copyright © 2016 jabble. All rights reserved.
//

#import "PhotoController.h"

@implementation PhotoController
@synthesize mPhotoData;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadPhotoDetails];
    
    //Add Observers to check if keyboard is visible or not
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    mTableView.rowHeight = UITableViewAutomaticDimension;
    mTableView.estimatedRowHeight = 73.0;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Fetch the comments from persistent data store
    [self loadCommentsFromCoreData];
    
}
- (void)loadPhotoDetails {
    //Load Data
    NSURL* _flickrPhotoImageURL = [mPhotoData valueForKey:@"PhotoURL"];
    NSString* _flickrPhotoTitle = [mPhotoData valueForKey:@"PhotoTitle"];
    int _flickrPhotoFaves = [[mPhotoData objectForKey:@"PhotoFaves"] intValue];
    int _flickrPhotoViews = [[mPhotoData objectForKey:@"PhotoViews"] intValue];
    NSString* _flickrPhotoDescription = [[mPhotoData valueForKey:@"PhotoDescription"] valueForKey:@"_content"];
    
    //Update UI
    [mFlickrPhoto setImageWithURL:_flickrPhotoImageURL placeholderImage:[UIImage imageNamed:@"loadImage.png"]];
    mFlickrPhotoTitle.text = _flickrPhotoTitle;
    mFlickrPhotoLikes.text = [NSString stringWithFormat:@"%i",_flickrPhotoFaves];
    mFlickrPhotoViews.text = [NSString stringWithFormat:@"%i",_flickrPhotoViews];
    mFlickrPhotoDescription.text = _flickrPhotoDescription;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark IBActions
-(IBAction)mBackButtonAction:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:true];
}
-(IBAction)mSendAction:(id)sender {
    NSString* _photoID = [mPhotoData valueForKey:@"PhotoID"];
    //To set tge photo owner or we can set our name
    //NSString* _photoAuthor = [mPhotoData valueForKey:@"PhotoOwner"];
    NSString* _photoAuthor = @"Viktor Todorov";
    
    [self saveCommentWithText:mCommentField.text photoID:_photoID authorName:_photoAuthor];
    [self loadCommentsFromCoreData];
    
    //hide keyboard and clear text
    [self.view endEditing:true];
    mCommentField.text = @"";
}
#pragma mark Table View
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.mComments != nil && self.mComments.count > 0) {
        return self.mComments.count;
    }
    else {
        return 0;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    
    if (cell == nil) {
        
        cell = [[UserCommentCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UserCell"];
        
    }
    
    NSManagedObject *comment = [self.mComments objectAtIndex:indexPath.row];
    cell.userName.text = [comment valueForKey:@"authorName"];
    cell.userComment.text = [comment valueForKey:@"comment"];
    
    return cell;
}


#pragma mark CORE DATA
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
-(void)saveCommentWithText:(NSString*)commentText photoID:(NSString*)photoID authorName:(NSString*)authorName {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Create a new managed object
    NSManagedObject *newComment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:context];
    [newComment setValue:commentText forKey:@"comment"];
    [newComment setValue:photoID forKey:@"photoId"];
    [newComment setValue:authorName forKey:@"authorName"];
    
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}
-(void)loadCommentsFromCoreData {
    NSString* _photoID = [mPhotoData valueForKey:@"PhotoID"];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Comment"];
    NSMutableArray* _commentsArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    self.mComments = [NSMutableArray array];
    for (NSManagedObject* comment in _commentsArray) {
        if ([[comment valueForKey:@"photoId"] isEqualToString:_photoID]) {
            [self.mComments addObject:comment];
        }
    }
    mFlickrPhotoComments.text = [NSString stringWithFormat:@"%i",(int)self.mComments.count];
    
    mTableView.rowHeight = UITableViewAutomaticDimension;
    mTableView.estimatedRowHeight = 73.0;
    [mTableView reloadData];
}
#pragma mark Notification Methods
- (void)keyboardWillShow:(NSNotification*)aNotification {
    CGRect keyboardRect = [aNotification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil]; //this is it!
    
    [UIView animateWithDuration:0.1 animations:^
     {
         CGRect commentsFrame = [mCommentField frame];
         commentsFrame.origin.y -= keyboardRect.size.height; // tweak here to adjust the moving position
         [mCommentField setFrame:commentsFrame];
         
         CGRect buttonFrame = [mSendButton frame];
         buttonFrame.origin.y -= keyboardRect.size.height; // tweak here to adjust the moving position
         [mSendButton setFrame:buttonFrame];
         
         CGRect backgroundFrame = [mFieldBackground frame];
         backgroundFrame.origin.y -= keyboardRect.size.height; // tweak here to adjust the moving position
         [mFieldBackground setFrame:backgroundFrame];
         
     }completion:^(BOOL finished)
     {
         
     }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    CGRect keyboardRect = [aNotification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil]; //this is it!
    
    [UIView animateWithDuration:0.1 animations:^
     {
         CGRect commentsFrame = [mCommentField frame];
         commentsFrame.origin.y += keyboardRect.size.height; // tweak here to adjust the moving position
         [mCommentField setFrame:commentsFrame];
         
         CGRect buttonFrame = [mSendButton frame];
         buttonFrame.origin.y += keyboardRect.size.height; // tweak here to adjust the moving position
         [mSendButton setFrame:buttonFrame];
         
         CGRect backgroundFrame = [mFieldBackground frame];
         backgroundFrame.origin.y += keyboardRect.size.height; // tweak here to adjust the moving position
         [mFieldBackground setFrame:backgroundFrame];
         
     }completion:^(BOOL finished)
     {
         
     }];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
