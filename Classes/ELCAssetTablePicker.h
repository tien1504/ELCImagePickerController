//
//  AssetTablePicker.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ELCAsset.h"


@class ELCAlbumPickerController;

@interface ELCAssetTablePicker : UITableViewController <ELCAssetDelegate>
{
	ALAssetsGroup *assetGroup;
	
	ELCAlbumPickerController *parent;
}

@property (nonatomic, assign) ELCAlbumPickerController *parent;
@property (nonatomic, assign) ALAssetsGroup *assetGroup;
@property (nonatomic, retain) IBOutlet UILabel *selectedAssetsLabel;

-(int)totalSelectedAssets;

-(void)doneAction:(id)sender;

#pragma mark - Protected interface

- (NSString *)titleForLoadingMedia;
- (NSString *)titleForSelectingMedia;

@end