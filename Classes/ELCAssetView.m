//
//  ELCAssetView.m
//  Qwiki
//
//  Created by John A. Debay on 11/16/12.
//  Copyright (c) 2012 Qwiki. All rights reserved.
//

#import "ELCAssetView.h"
#import "UIView+QWFonts.h"

@interface ELCAssetView ()
@property (nonatomic, strong, readonly) IBOutlet UIView *videoDurationOverlayView;
@property (nonatomic, strong, readonly) IBOutlet UIImageView *selectedOverlayImageView;
@end


@implementation ELCAssetView

#pragma mark - UIView implementation

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[self videoDurationOverlayView] applyRegularFont];
    [self configureViewForSelectionState:[self isSelected]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ([self isSelected])
        [self configureSelectedOverlayView];
}

#pragma mark - View configuration

- (void)configureViewForSelectionState:(BOOL)isSelected
{
    if (isSelected)
        [self addSubview:[self selectedOverlayImageView]];
    else
        [[self selectedOverlayImageView] removeFromSuperview];
}

- (void)configureSelectedOverlayView
{
    UIImageView *overlayView = [self selectedOverlayImageView];
    CGRect overlayFrame = [overlayView frame];
    overlayFrame.size = [[self selectedOverlayImage] size];
    CGRect bounds = [[overlayView superview] bounds];
    if (overlayFrame.size.width < bounds.size.width && overlayFrame.size.height < bounds.size.height) {
        CGFloat padding = 3;
        overlayFrame.origin = CGPointMake(bounds.size.width - overlayFrame.size.width - padding,
                                          bounds.size.height - overlayFrame.size.height - padding);
    } else
        overlayFrame = bounds;

    [overlayView setFrame:overlayFrame];
}

#pragma mark - UI events

- (IBAction)buttonWasTapped:(id)sender
{
    id<ELCAssetViewDelegate> delegate = [self delegate];
    BOOL canToggle = [delegate assetViewCanToggleSelection:self];
    if (canToggle) {
        [self setSelected:![self isSelected]];
        [delegate assetViewDidToggleSelection:self];
    }
}

#pragma mark - Accessors

- (void)setVideo:(BOOL)video
{
    if (_video != video) {
        _video = video;
        [[self videoDurationOverlayView] setHidden:!_video];
    }
}

- (void)setSelected:(BOOL)selected
{
    if (_selected != selected) {
        _selected = selected;
        [self configureViewForSelectionState:_selected];
    }
}

- (void)setSelectedOverlayImage:(UIImage *)selectedOverlayImage
{
    [[self selectedOverlayImageView] setImage:selectedOverlayImage];
    [self setNeedsLayout];
}

- (UIImage *)selectedOverlayImage
{
    return [[self selectedOverlayImageView] image];
}

@end


@implementation ELCAssetView (InstantiationHelpers)

+ (id)instanceFromNib
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
    return [nib instantiateWithOwner:self options:nil][0];
}

@end
