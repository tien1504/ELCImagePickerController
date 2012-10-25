//
//  Asset.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAsset.h"
#import "ELCAssetTablePicker.h"

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
		
		overlayView = [[UIImageView alloc] initWithFrame:viewFrames];
		[overlayView setImage:[UIImage imageNamed:@"Overlay.png"]];
		[overlayView setHidden:YES];
		[self addSubview:overlayView];
    }
    
	return self;	
}

-(void)toggleSelection {

    id<ELCAssetDelegate> del = [self delegate];
    SEL selector = overlayView.hidden ? @selector(assetCanBeSelected:) : @selector(assetCanBeDeselected:);
    BOOL shouldToggle = [del respondsToSelector:selector] ? (BOOL) [del performSelector:selector withObject:self] : YES;

    if (shouldToggle)
        overlayView.hidden = !overlayView.hidden;

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
