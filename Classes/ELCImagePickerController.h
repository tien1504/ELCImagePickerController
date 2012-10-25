//
//  ELCImagePickerController.h
//  ELCImagePickerDemo
//
//  Created by Collin Ruffenach on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ELCImagePickerControllerDelegate;
@class ELCAsset;

@interface ELCImagePickerController : UINavigationController {

	id<UINavigationControllerDelegate, ELCImagePickerControllerDelegate> delegate;
}

@property (nonatomic, assign) id<UINavigationControllerDelegate, ELCImagePickerControllerDelegate> delegate;

-(BOOL)canSelectAsset:(ELCAsset *)asset;
- (BOOL)canDeselectAsset:(ELCAsset *)asset;
-(void)selectedAssets:(NSArray*)_assets;
-(void)cancelImagePicker;

@end

@protocol ELCImagePickerControllerDelegate <NSObject>

@optional

- (BOOL)elcImagePickerController:(ELCImagePickerController *)picker shouldSelectMediaWithInfo:(NSDictionary *)info;
- (BOOL)elcImagePickerController:(ELCImagePickerController *)picker shouldDeselectMediaWithInfo:(NSDictionary *)info;

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info;
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker;

@end

