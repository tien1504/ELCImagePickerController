//
//  ELCThumbnailsTableViewCell.m
//  Qwiki
//
//  Created by John A. Debay on 11/16/12.
//  Copyright (c) 2012 Qwiki. All rights reserved.
//

#import "ELCThumbnailsTableViewCell.h"
#import "ELCAssetView.h"
#import "NSString+GeneralHelpers.h"


@interface ELCThumbnailsTableViewCell ()
@property (nonatomic, copy) NSArray *assetViews;
@end


@implementation ELCThumbnailsTableViewCell

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
        [self initialize];

    return self;
}

- (void)initialize
{
    CGRect bounds = [[self contentView] bounds];
    const CGSize thumbnailSize = CGSizeMake(75, 75);
    const CGFloat horizontalPadding = 4, verticalPadding = 2;
    NSInteger thumbnailCount = bounds.size.width / thumbnailSize.width;
    NSMutableArray *assetViews = [NSMutableArray arrayWithCapacity:thumbnailCount];
    CGFloat x = horizontalPadding;
    for (NSInteger i = 0; i < thumbnailCount; ++i) {
        CGRect thumbnailFrame = CGRectMake(x, verticalPadding, thumbnailSize.width, thumbnailSize.height);
        ELCAssetView *view = [ELCAssetView instanceFromNib];
        [view setDelegate:self];
        [view setFrame:thumbnailFrame];
        [[self contentView] addSubview:view];
        [assetViews addObject:view];

        x = CGRectGetMaxX(thumbnailFrame) + horizontalPadding;
    }

    [self setAssetViews:assetViews];
}

#pragma mark - ELCAssetViewDelegate implementation

- (BOOL)assetViewCanToggleSelection:(ELCAssetView *)assetView
{
    NSInteger where = [[self assetViews] indexOfObject:assetView];
    return [[self delegate] tumbnailsTableViewCell:self canToggleSelectionOfAsset:[self assets][where]];
}

- (void)assetViewDidToggleSelection:(ELCAssetView *)assetView
{
    NSInteger where = [[self assetViews] indexOfObject:assetView];
    [[self delegate] tumbnailsTableViewCell:self didToggleSelectionOfAsset:[self assets][where]];
}

#pragma mark - View configuration

- (void)configureViewForAssets:(NSArray *)assets
{
    NSArray *assetViews = [self assetViews];
    [assetViews enumerateObjectsUsingBlock:^(ELCAssetView *assetView, NSUInteger idx, BOOL *stop) {
        UIImage *thumbnail = nil;
        BOOL isVideo = NO;
        NSString *durationString = nil;
        if (idx < [assets count]) {
            ALAsset *asset = assets[idx];
            thumbnail = [UIImage imageWithCGImage:[asset thumbnail]];

            isVideo = [[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo];
            if (isVideo) {
                NSNumber *duration = [asset valueForProperty:ALAssetPropertyDuration];
                durationString = [NSString stringForDuration:[duration floatValue]];
            }
            [assetView setBackgroundColor:[UIColor whiteColor]];
        } else {
            [assetView setBackgroundColor:[UIColor clearColor]];
        }

        [[assetView button] setImage:thumbnail forState:UIControlStateNormal];
        [assetView setVideo:isVideo];
        [[assetView videoDurationLabel] setText:durationString];
        [[assetView button] setEnabled:(thumbnail != nil)];
    }];
}

- (void)selectAssetsAtIndexes:(NSIndexSet *)indexes
{
    NSArray *assetViews = [self assetViews];
    [assetViews enumerateObjectsUsingBlock:^(ELCAssetView *assetView, NSUInteger idx, BOOL *stop) {
        [assetView setSelected:[indexes containsIndex:idx]];
    }];
}

#pragma mark - Accessors

//Selected Assets related:

- (void)setAssets:(NSArray *)assets
{
    _assets = [assets copy];
    [self configureViewForAssets:_assets];
}

- (void)setSelectedAssetIndexes:(NSIndexSet *)selectedAssetIndexes
{
    _selectedAssetIndexes = [selectedAssetIndexes copy];
    [self selectAssetsAtIndexes:_selectedAssetIndexes];
}

- (void)setSelectedAssetOverlayImage:(UIImage *)selectedAssetOverlayImage
{
    _selectedAssetOverlayImage = selectedAssetOverlayImage;
    [[self assetViews] makeObjectsPerformSelector:@selector(setSelectedOverlayImage:) withObject:_selectedAssetOverlayImage];
}

//Pre-selected Assets related:

- (void)setPreSelectedAssetIndexes:(NSIndexSet *)preSelectedAssetIndexes
{
    _preSelectedAssetIndexes = [preSelectedAssetIndexes copy];
    [self indicatePreSelectedAssetAtIndexes:_preSelectedAssetIndexes];
}

- (void)indicatePreSelectedAssetAtIndexes:(NSIndexSet *)indexes
{
    [[self assetViews] enumerateObjectsUsingBlock:^(ELCAssetView *assetView, NSUInteger idx, BOOL *stop) {
        [assetView setPreSelected:[indexes containsIndex:idx]];
    }];
}

#pragma mark - Static properties

+ (NSString *)reuseIdentifier
{
    return @"ELCThumbnailsTableViewCell";
}

+ (CGFloat)cellHeight
{
    return 79;
}

@end
