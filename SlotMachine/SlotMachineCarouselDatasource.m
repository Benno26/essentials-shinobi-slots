//
//  SlotMachineCarouselDatasource.m
//  SlotMachine
//
//  Created by Andrew Polkinghorn on 27/06/2013.
//
//  Copyright 2013 Scott Logic
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "SlotMachineCarouselDatasource.h"

@implementation SlotMachineCarouselDatasource

- (id)init
{
    self = [super init];
    if (self) {
        [self setUpDatasource];
    }
    return self;
}

-(void)setUpDatasource {
    NSArray *imageNames = @[@"blue ninja", @"red ninja", @"orange ninja", @"pink ninja", @"purple ninja", @"grey ninja", @"yellow ninja", @"green ninja"];
    _slotImages = [[NSMutableArray alloc] init];
    
    // Add images to array
    for(int i=0; i<imageNames.count;i++){
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SLOT_SIZE, SLOT_SIZE)];
        imageView.image = [UIImage imageNamed:imageNames[i]];
        [_slotImages addObject:imageView];
    }
    
    // Shuffle the images so they are in a random order
    for (NSUInteger i = 1; i < _slotImages.count; ++i) {
        // Select a random element between i and end of array to swap with.
        int nElements = _slotImages.count - i;
        int n = (arc4random() % nElements) + i;
        [_slotImages exchangeObjectAtIndex:i withObjectAtIndex:n];
    }    
}

-(int)numberOfItemsInCarousel:(SEssentialsCarousel *)carousel {
    return _slotImages.count;
}

-(UIView *)carousel:(SEssentialsCarousel *)carousel itemAtIndex:(int)index {
    return _slotImages[index];
}

@end
