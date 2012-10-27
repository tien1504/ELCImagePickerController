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
	
	NSMutableArray *elcAssets;
	int selectedAssets;
	
	ELCAlbumPickerController *parent;
	
	NSOperationQueue *queue;
}

@property (nonatomic, assign) ELCAlbumPickerController *parent;
@property (nonatomic, assign) ALAssetsGroup *assetGroup;
@property (nonatomic, retain) NSMutableArray *elcAssets;
@property (nonatomic, retain) IBOutlet UILabel *selectedAssetsLabel;

-(int)totalSelectedAssets;
-(void)preparePhotos;

-(void)doneAction:(id)sender;

#pragma mark - Protected interface

- (NSString *)titleForLoadingMedia;
- (NSString *)titleForSelectingMedia;

@end