//
//  SelectorCell.m
//  Yelp
//
//  Created by Liz Chaddock on 9/17/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "SelectorCell.h"

@interface SelectorCell ()
- (IBAction)selectionMade:(id)sender;
@end

@implementation SelectorCell
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setValue:(NSInteger)value {
    [self setValue:value animated:NO];
}

- (void)setValue:(NSInteger)value animated:(BOOL)animated {
    _value = value;
    [self setValue:value animated:animated];
}

- (IBAction)selectionMade:(id)sender {
    [self.delegate selectorCell:self didUpdateValue:(NSInteger) _selector.selectedSegmentIndex];
}

@end
