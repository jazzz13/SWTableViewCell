//
//  SWTableViewCell.m
//  SWTableViewCell
//
//  Created by Chris Wendel on 9/10/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import "SWTableViewCell.h"
#import "SWUtilityButton.h"

#define kUtilityButtonWidth 80

typedef enum {
    kCellStateCenter,
    kCellStateLeft,
    kCellStateRight
} SWCellState;

#pragma mark - SWUtilityButtonView

@interface SWUtilityButtonView : UIView

@property (nonatomic, strong) NSArray *utilityButtons;

- (id)initWithFrame:(CGRect)frame utilityButtons:(NSArray *)utilityButtons;

- (id)initWithUtilityButtons:(NSArray *)utilityButtons;

@end

@implementation SWUtilityButtonView

#pragma mark - SWUtilityButonView initializers

- (id)initWithUtilityButtons:(NSArray *)utilityButtons {
    self = [super init];
    
    if (self) {
        self.utilityButtons = utilityButtons;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame utilityButtons:(NSArray *)utilityButtons {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.utilityButtons = utilityButtons;
    }
    
    return self;
}

- (CGFloat)utilityButtonsWidth {
    NSLog(@"utility buttons count is %d", _utilityButtons.count);
    return (_utilityButtons.count * kUtilityButtonWidth);
}

- (void)populateUtilityButtons {
    NSUInteger utilityButtonsCount = _utilityButtons.count;
    NSUInteger utilityButtonsCounter = _utilityButtons.count;
    for (SWUtilityButton *utilityButton in _utilityButtons) {
        CGFloat utilityButtonXCord = 0;
        if (utilityButtonsCounter > 0) utilityButtonXCord = [self utilityButtonsWidth] / utilityButtonsCounter;
        [utilityButton setFrame:CGRectMake(utilityButtonXCord, 0, [self utilityButtonsWidth] / utilityButtonsCount, CGRectGetHeight(self.bounds))];
        NSLog(@"utility button frame is %@", NSStringFromCGRect(utilityButton.frame));
        [self addSubview:utilityButton];
        utilityButtonsCounter--;
    }
}

@end

@interface SWTableViewCell () <UIScrollViewDelegate> {
    SWCellState _cellState;
}

// Scroll view to be added to UITableViewCell
@property (nonatomic, weak) UIScrollView *cellScrollView;

// The cell's height
@property (nonatomic) CGFloat height;

// Views that live in the scroll view
@property (nonatomic, weak) UIView *scrollViewContentView;
@property (nonatomic, strong) SWUtilityButtonView *scrollViewButtonViewLeft;
@property (nonatomic, strong) SWUtilityButtonView *scrollViewButtonViewRight;

@end

@implementation SWTableViewCell

#pragma mark Initializers

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
    height:(CGFloat)height
    leftUtilityButtons:(NSArray *)leftUtilityButtons
    rightUtilityButtons:(NSArray *)rightUtilityButtons {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.rightUtilityButtons = rightUtilityButtons;
        self.leftUtilityButtons = leftUtilityButtons;
        self.height = height;
        [self initializer];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initializer];
    }
    
    return self;
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self initializer];
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self initializer];
    }
    
    return self;
}

- (void)initializer {
    // Set up scroll view that will host our cell content
    UIScrollView *cellScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), _height)];
    cellScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + [self utilityButtonsPadding], _height);
    cellScrollView.contentOffset = [self scrollViewContentOffset];
    cellScrollView.delegate = self;
    cellScrollView.showsHorizontalScrollIndicator = NO;
    
    self.cellScrollView = cellScrollView;
    
    //self.cellScrollView.alpha = 0.5;
    
    // Set up the views that will hold the utility buttons
    SWUtilityButtonView *scrollViewButtonViewLeft = [[SWUtilityButtonView alloc] initWithUtilityButtons:_leftUtilityButtons];
    [scrollViewButtonViewLeft setFrame:CGRectMake([self leftUtilityButtonsWidth], 0, [self leftUtilityButtonsWidth], _height)];
    NSLog(@"scrollViewButtonViewLeft frame is %@", NSStringFromCGRect(scrollViewButtonViewLeft.frame));
    self.scrollViewButtonViewLeft = scrollViewButtonViewLeft;
    [self.cellScrollView addSubview:scrollViewButtonViewLeft];
    
    SWUtilityButtonView *scrollViewButtonViewRight = [[SWUtilityButtonView alloc] initWithUtilityButtons:_rightUtilityButtons];
    [scrollViewButtonViewRight setFrame:CGRectMake(CGRectGetWidth(self.bounds), 0, [self rightUtilityButtonsWidth], _height)];
    NSLog(@"scrollViewButtonViewRight frame is %@", NSStringFromCGRect(scrollViewButtonViewRight.frame));
    self.scrollViewButtonViewRight = scrollViewButtonViewRight;
    [self.cellScrollView addSubview:scrollViewButtonViewRight];
    
    // Populate the button views with utility buttons
    [scrollViewButtonViewLeft populateUtilityButtons];
    [scrollViewButtonViewRight populateUtilityButtons];
    
    // Create the content view that will live in our scroll view
    UIView *scrollViewContentView = [[UIView alloc] initWithFrame:CGRectMake([self leftUtilityButtonsWidth], 0, CGRectGetWidth(self.bounds), _height)];
    scrollViewContentView.backgroundColor = [UIColor whiteColor];
    NSLog(@"scrollViewContentView frame is %@", NSStringFromCGRect(scrollViewContentView.frame));
    [self.cellScrollView addSubview:scrollViewContentView];
    self.scrollViewContentView = scrollViewContentView;
    
    // Add the cell scroll view to the cell
    NSArray *cellSubviews = self.subviews;
    [self insertSubview:cellScrollView atIndex:0];
    for (UIView *subview in cellSubviews) {
        [self.scrollViewContentView addSubview:subview];
    }
}


#pragma mark - Overriden methods

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"layout subviews!");
    
    self.cellScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), _height);
    self.cellScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + [self utilityButtonsPadding], _height);
    self.cellScrollView.contentOffset = CGPointMake([self leftUtilityButtonsWidth], 0);
    self.scrollViewButtonViewLeft.frame = CGRectMake([self leftUtilityButtonsWidth], 0, [self leftUtilityButtonsWidth], _height);
    self.scrollViewButtonViewRight.frame = CGRectMake(CGRectGetWidth(self.bounds), 0, [self rightUtilityButtonsWidth], _height);
    self.scrollViewContentView.frame = CGRectMake([self leftUtilityButtonsWidth], 0, CGRectGetWidth(self.bounds), _height);
}

#pragma mark - Setup helpers

- (CGFloat)leftUtilityButtonsWidth {
    return [_scrollViewButtonViewLeft utilityButtonsWidth];
}

- (CGFloat)rightUtilityButtonsWidth {
    return [_scrollViewButtonViewRight utilityButtonsWidth];
}

- (CGFloat)utilityButtonsPadding {
    return ([_scrollViewButtonViewLeft utilityButtonsWidth] + [_scrollViewButtonViewRight utilityButtonsWidth]);
}

- (CGPoint)scrollViewContentOffset {
    return CGPointMake([_scrollViewButtonViewLeft utilityButtonsWidth], 0);
}

@end