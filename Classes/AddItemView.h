//
//  AddItemView.h
//  iPOS
//
//  Created by Steven McCoole on 2/12/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GradientView.h"
#import "MOGlassButton.h"
#import "ExtUITextField.h"
#import "AvailabilityView.h"

@class AddItemView;

@protocol AddItemViewDelegate

- (void) addItem:(AddItemView *)addItemView orderQuantity:(NSDecimalNumber *)quantity ofUnits:(NSString *)unitOfMeasure;
- (void) cancelAddItem:(AddItemView *)addItemView;

@end

@interface AddItemView : UIView <UITextFieldDelegate>
{
	id productItem;
	NSObject <AddItemViewDelegate>* viewDelegate;
	
	GradientView *roundedView;
	UILabel *skuLabel;
	UILabel *descriptionLabel;
	UILabel *priceLabel;
	
	AvailabilityView *storeInfoView;
	
	AvailabilityView *dc1InfoView;
	
	AvailabilityView *dc2InfoView;
	
	AvailabilityView *dc3InfoView;
	
	MOGlassButton *addToCartButton;
	MOGlassButton *exitButton;
	GradientView *addQuantityView;
	UILabel *addQuantityUnitsLabel;
	ExtUITextField *addQuantityField;
	
	NSNumberFormatter *priceFormatter;
	NSNumberFormatter *availableFormatter;
	
	id currentFirstResponder;
	CGFloat previousViewOriginY;
	BOOL keyboardCancelled;
	
	NSNumberFormatter *quantityFormatter;

}

@property (nonatomic, retain) id productItem;
@property (nonatomic, assign) NSObject<AddItemViewDelegate>* viewDelegate;
@property (nonatomic, retain) id currentFirstResponder;
@property                     BOOL keyboardCancelled;

@end
