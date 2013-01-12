//
//  ELCThumbnailsTableViewCell.h
//  Qwiki
//
//  Created by John A. Debay on 11/16/12.
//  Copyright (c) 2012 Qwiki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCAssetView.h"
#import <AssetsLibrary/AssetsLibrary.h>


@protocol ELCThumbnailsTableViewCellDelegate;

@interface ELCThumbnailsTableViewCell : UITableViewCell <ELCAssetViewDelegate>

@property (nonatomic, weak) id<ELCThumbnailsTableViewCellDelegate> delegate;

@property (nonatomic, copy) NSArray *assets;
@property (nonatomic, copy) NSIndexSet *selectedAssetIndexes;
@property (nonatomic, strong) UIImage *selectedAssetOverlayImage;
@property (nonatomic, copy) NSIndexSet *preSelectedAssetIndexes;

#pragma mark - Static properties

+ (NSString *)reuseIdentifier;
+ (CGFloat)cellHeight;

@end


@protocol ELCThumbnailsTableViewCellDelegate <NSObject>

- (BOOL)tumbnailsTableViewCell:(ELCThumbnailsTableViewCell *)cell canToggleSelectionOfAsset:(ALAsset *)asset;
- (void)tumbnailsTableViewCell:(ELCThumbnailsTableViewCell *)cell didToggleSelectionOfAsset:(ALAsset *)asset;

@end
