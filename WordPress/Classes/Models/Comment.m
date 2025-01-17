#import "Comment.h"
#import "ContextManager.h"
#import "Blog.h"
#import "BasePost.h"
#import <WordPressShared/NSString+XMLExtensions.h>
#import "WordPress-Swift.h"

NSString * const CommentUploadFailedNotification = @"CommentUploadFailed";

NSString * const CommentStatusPending = @"hold";
NSString * const CommentStatusApproved = @"approve";
NSString * const CommentStatusUnapproved = @"trash";
NSString * const CommentStatusSpam = @"spam";

// draft is used for comments that have been composed but not succesfully uploaded yet
NSString * const CommentStatusDraft = @"draft";

@implementation Comment

@dynamic blog;
@dynamic post;
@dynamic author;
@dynamic author_email;
@dynamic author_ip;
@dynamic author_url;
@dynamic authorAvatarURL;
@dynamic commentID;
@dynamic content;
@dynamic dateCreated;
@dynamic depth;
@dynamic hierarchy;
@dynamic link;
@dynamic parentID;
@dynamic postID;
@dynamic postTitle;
@dynamic status;
@dynamic type;
@dynamic isLiked;
@dynamic likeCount;
@dynamic canModerate;
@synthesize isNew;
@synthesize attributedContent;

#pragma mark - Helper methods

+ (NSString *)titleForStatus:(NSString *)status
{
    if ([status isEqualToString:CommentStatusPending]) {
        return NSLocalizedString(@"Pending moderation", @"");
    } else if ([status isEqualToString:CommentStatusApproved]) {
        return NSLocalizedString(@"Comments", @"");
    }

    return status;
}

- (NSString *)postTitle
{
    NSString *title = nil;
    if (self.post) {
        title = self.post.postTitle;
    } else {
        [self willAccessValueForKey:@"postTitle"];
        title = [self primitiveValueForKey:@"postTitle"];
        [self didAccessValueForKey:@"postTitle"];
    }

    if (title == nil || [@"" isEqualToString:title]) {
        title = NSLocalizedString(@"(no title)", @"the post has no title.");
    }
    return title;

}

- (NSString *)author
{
    NSString *authorName = nil;

    [self willAccessValueForKey:@"author"];
    authorName = [self primitiveValueForKey:@"author"];
    [self didAccessValueForKey:@"author"];

    if (authorName == nil || [@"" isEqualToString:authorName]) {
        authorName = NSLocalizedString(@"Anonymous", @"the comment has an anonymous author.");
    }
    return authorName;

}

- (NSDate *)dateCreated
{
    NSDate *date = nil;

    [self willAccessValueForKey:@"dateCreated"];
    date = [self primitiveValueForKey:@"dateCreated"];
    [self didAccessValueForKey:@"dateCreated"];

    return date;
}

- (NSString *)sectionIdentifier
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterLongStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    return [formatter stringFromDate:self.dateCreated];
}


#pragma mark - PostContentProvider protocol

- (BOOL)isPrivateContent
{
    if ([self.post respondsToSelector:@selector(isPrivateAtWPCom)]) {
        return (BOOL)[self.post performSelector:@selector(isPrivateAtWPCom)];
    }
    return NO;
}

- (NSString *)titleForDisplay
{
    return [self.postTitle stringByDecodingXMLCharacters];
}

- (NSString *)authorForDisplay
{
    return [[self.author trim] length] > 0 ? [[self.author stringByDecodingXMLCharacters] trim] : [self.author_email trim];
}

- (NSString *)blogNameForDisplay
{
    return self.author_url;
}

- (NSString *)statusForDisplay
{
    NSString *status = [[self class] titleForStatus:self.status];
    if ([status isEqualToString:NSLocalizedString(@"Comments", @"")]) {
        status = nil;
    }
    return status;
}

- (NSString *)authorUrlForDisplay
{
    return self.author_url.hostname;
}

- (BOOL)hasAuthorUrl
{
    return self.author_url && ![self.author_url isEqualToString:@""];
}

- (BOOL)isApproved
{
    return [self.status isEqualToString:CommentStatusApproved];
}

- (BOOL)isReadOnly
{
    // If the current user cannot moderate the comment, they can only Like and Reply if the comment is Approved.
    if ((self.blog.isHostedAtWPcom || self.blog.isAtomic)
        && !self.canModerate && !self.isApproved) {
        return YES;
    }

    return NO;
}

- (NSString *)contentForDisplay
{
    //Strip HTML from the comment content
    NSString *commentContent = [self.content stringByDecodingXMLCharacters];
    commentContent = [commentContent trim];
    commentContent = [commentContent stringByStrippingHTML];
    commentContent = [commentContent stringByNormalizingWhitespace];    

    return commentContent;
}

- (NSString *)contentPreviewForDisplay
{
    return [[[self.content stringByDecodingXMLCharacters] stringByStrippingHTML] stringByNormalizingWhitespace];
}

- (NSURL *)avatarURLForDisplay
{
    return [NSURL URLWithString:self.authorAvatarURL];
}

- (NSString *)gravatarEmailForDisplay
{
    return [self.author_email trim];
}

- (NSDate *)dateForDisplay
{
    return self.dateCreated;
}

- (NSURL *)authorURL
{
    if (self.author_url) {
        return [NSURL URLWithString:self.author_url];
    }

    return nil;
}

- (BOOL)authorIsPostAuthor
{
    return [[self authorURL] isEqual:[self.post authorURL]];
}

- (NSNumber *)numberOfLikes
{
    return self.likeCount ?: @(0);
}

@end
