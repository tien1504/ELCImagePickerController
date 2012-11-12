//
//  Asset.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAsset.h"
#import "ELCAssetTablePicker.h"

#import "QWMovieThumbnailOverlayView.h"
#import "UIView+QWFonts.h"
#import "NSString+GeneralHelpers.h"


@implementation ELCAsset

@synthesize asset;
@synthesize parent;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

-(id)initWithAsset:(ALAsset*)_asset {
	
	if (self = [super initWithFrame:CGRectMake(0, 0, 0, 0)]) {
		
		self.asset = _asset;
		
		CGRect viewFrames = CGRectMake(0, 0, 75, 75);
		
		UIImageView *assetImageView = [[UIImageView alloc] initWithFrame:viewFrames];
		[assetImageView setContentMode:UIViewContentModeScaleAspectFill];
        [assetImageView setClipsToBounds:YES];
		[assetImageView setImage:[UIImage imageWithCGImage:[self.asset thumbnail]]];
		[self addSubview:assetImageView];
		[assetImageView release];

        // jad: this should be in a subclass somewhere
        if ([[[self asset] valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
            /*
            CGFloat height = 20;
            CGRect thumbnailFrame = CGRectMake(0, viewFrames.size.height - height, viewFrames.size.height, height);
            QWMovieThumbnailOverlayView *view = [[QWMovieThumbnailOverlayView alloc] initWithFrame:thumbnailFrame];
            [self addSubview:view];
            [view release];
             */

            CGRect bounds = [self bounds];
            const CGFloat OverlayHeight = 25;
            CGRect overlayFrame = CGRectMake(0, bounds.size.height - OverlayHeight, bounds.size.width, OverlayHeight);
            UIView *overlay = [[UIView alloc] initWithFrame:overlayFrame];
            [overlay setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
            [overlay setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
            [self addSubview:overlay];

            const CGFloat LabelPadding = 20;
            CGRect labelFrame =
                CGRectMake(45, overlayFrame.origin.y, overlayFrame.size.width - LabelPadding * 2, overlayFrame.size.height);
            UILabel *durationLabel = [[UILabel alloc] initWithFrame:labelFrame];
            [durationLabel setBackgroundColor:[UIColor clearColor]];
            [durationLabel setTextColor:[UIColor whiteColor]];
            [durationLabel setAutoresizingMask:[overlay autoresizingMask]];
            [durationLabel applyRegularFontOfSize:12];
            NSNumber *duration = [[self asset] valueForProperty:ALAssetPropertyDuration];
            [durationLabel setText:[NSString stringForDuration:[duration floatValue]]];
            [self addSubview:durationLabel];
        }

		overlayView = [[UIImageView alloc] initWithFrame:viewFrames];
		[overlayView setImage:[self overlayImage]];
        [self configureOverlayImage];
		[overlayView setHidden:YES];
		[self addSubview:overlayView];
    }
    
	return self;	
}

-(void)toggleSelection {

    id<ELCAssetDelegate> del = [self delegate];
    SEL selector = [self selected] ? @selector(assetCanBeDeselected:) : @selector(assetCanBeSelected:);
    BOOL shouldToggle = [del respondsToSelector:selector] ? (BOOL) [del performSelector:selector withObject:self] : YES;

    if (shouldToggle) {
        overlayView.hidden = !overlayView.hidden;
        [overlayView setImage:[self overlayImage]];
        [self configureOverlayImage];

        if ([del respondsToSelector:@selector(asset:wasSelected:)])
            [del asset:self wasSelected:[self selected]];
    }

//    if([(ELCAssetTablePicker*)self.parent totalSelectedAssets] >= 10) {
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Maximum Reached" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
//		[alert show];
//		[alert release];	
//
//        [(ELCAssetTablePicker*)self.parent doneAction:nil];
//    }
}

-(BOOL)selected {
	
	return !overlayView.hidden;
}

-(void)setSelected:(BOOL)_selected {
    
	[overlayView setHidden:!_selected];
}

- (void)dealloc 
{    
    self.asset = nil;
	[overlayView release];
    [super dealloc];
}

- (UIImage *)overlayImage
{
    id<ELCAssetDelegate> del = [self delegate];
    return [del respondsToSelector:@selector(overlayImageForAsset:)] ? [del overlayImageForAsset:self] : [UIImage imageNamed:@"Overlay.png"];
}

- (void)configureOverlayImage
{
    [overlayView sizeToFit];
    CGRect overlayFrame = [overlayView frame];
    CGRect bounds = [[overlayView superview] bounds];
    if (overlayFrame.size.width < bounds.size.width && overlayFrame.size.height < bounds.size.height) {
        CGFloat padding = 3;
        overlayFrame.origin = CGPointMake(bounds.size.width - overlayFrame.size.width - padding,
                                          bounds.size.height - overlayFrame.size.height - padding);
    } else
        overlayFrame = bounds;
    [overlayView setFrame:overlayFrame];
}

@end


@implementation ALAsset (ELCHelpers)

-(NSDictionary *)mediaInfo
{
    NSMutableDictionary *workingDictionary = [NSMutableDictionary dictionary];
    [workingDictionary setObject:[self valueForProperty:ALAssetPropertyType] forKey:UIImagePickerControllerMediaType];
    [workingDictionary setObject:[UIImage imageWithCGImage:[[self defaultRepresentation] fullScreenImage]] forKey:UIImagePickerControllerOriginalImage];
    [workingDictionary setObject:[[self valueForProperty:ALAssetPropertyURLs] valueForKey:[[[self valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:UIImagePickerControllerReferenceURL];

    return [NSDictionary dictionaryWithDictionary:workingDictionary];
}

@end
