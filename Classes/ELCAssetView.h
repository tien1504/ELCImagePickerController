//
//  ELCAssetView.h
//  Qwiki
//
//  Created by John A. Debay on 11/16/12.
//  Copyright (c) 2012 Qwiki. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ELCAssetViewDelegate;

@interface ELCAssetView : UIView

@property (nonatomic, weak) id<ELCAssetViewDelegate> delegate;

@property (nonatomic, strong, readonly) IBOutlet UIButton *button;
@property (nonatomic, strong, readonly) IBOutlet UILabel *videoDurationLabel;
@property (nonatomic, assign, getter=isVideo) BOOL video;
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, assign) BOOL preSelected;

@property (nonatomic, strong) UIImage *selectedOverlayImage;

@end

@protocol ELCAssetViewDelegate <NSObject>

- (BOOL)assetViewCanToggleSelection:(ELCAssetView *)assetView;
- (void)assetViewDidToggleSelection:(ELCAssetView *)assetView;

@end


@interface ELCAssetView (InstantiationHelpers)

+ (id)instanceFromNib;

@end
