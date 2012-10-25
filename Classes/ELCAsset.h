//
//  Asset.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>


@protocol ELCAssetDelegate;


@interface ELCAsset : UIView {
	ALAsset *asset;
	UIImageView *overlayView;
	BOOL selected;
	id parent;
    id<ELCAssetDelegate> delegate;
}

@property (nonatomic, retain) ALAsset *asset;
@property (nonatomic, assign) id parent;
@property (nonatomic, assign) id<ELCAssetDelegate> delegate;

-(id)initWithAsset:(ALAsset*)_asset;
-(BOOL)selected;

@end


@protocol ELCAssetDelegate <NSObject>

@optional

- (BOOL)assetCanBeSelected:(ELCAsset *)asset;
- (BOOL)assetCanBeDeselected:(ELCAsset *)asset;

@end


@interface ALAsset (ELCHelpers)

-(NSDictionary *)mediaInfo;

@end