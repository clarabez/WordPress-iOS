#import "MenuItemActionableView.h"

typedef NS_ENUM(NSUInteger) {
    MenuItemPlaceholderViewTypeAbove = 1,
    MenuItemPlaceholderViewTypeBelow,
    MenuItemPlaceholderViewTypeChild
}MenuItemPlaceholderViewType;

@protocol MenuItemPlaceholderViewDelegate;

@interface MenuItemPlaceholderView : MenuItemActionableView

@property (nonatomic, weak) id <MenuItemPlaceholderViewDelegate> delegate;
@property (nonatomic, assign) MenuItemPlaceholderViewType type;

@end

@protocol MenuItemPlaceholderViewDelegate <NSObject>

- (void)itemPlaceholderViewSelected:(MenuItemPlaceholderView *)placeholderView;

@end
