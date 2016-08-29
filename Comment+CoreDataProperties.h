//
//  Comment+CoreDataProperties.h
//  FlickrTestTask
//
//  Created by Viktor Todorov on 8/29/16.
//  Copyright © 2016 jabble. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Comment.h"

NS_ASSUME_NONNULL_BEGIN

@interface Comment (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *photoId;
@property (nullable, nonatomic, retain) NSString *comment;

@end

NS_ASSUME_NONNULL_END
