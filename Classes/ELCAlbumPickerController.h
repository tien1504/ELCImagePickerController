//
//  AlbumPickerController.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class ELCImagePickerController;
@class ELCAsset;

@interface ELCAlbumPickerController : UITableViewController {
	
	NSMutableArray *assetGroups;
	NSOperationQueue *queue;
	ELCImagePickerController *parent;
    
    ALAssetsLibrary *library;
    ALAssetsFilter *assetsFilter;
}

@property (nonatomic, retain) ALAssetsFilter *assetsFilter;
@property (nonatomic, assign) ELCImagePickerController *parent;
@property (nonatomic, retain) NSMutableArray *assetGroups;

-(BOOL)canSelectAsset:(ELCAsset *)asset;
-(BOOL)canDeselectAsset:(ELCAsset *)asset;
-(void)selectedAssets:(NSArray*)_assets;

#pragma mark - Protected interface

- (NSString *)titleForLoadingAlbums;
- (NSString *)titleForSelectingAlbums;

@end

