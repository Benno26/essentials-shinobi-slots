//
//  SlotMachineViewController.m
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

#import "SlotMachineViewController.h"
#import "SlotMachineCarouselDatasource.h"

#define PADDING 30
#define TITLE_LABEL_HEIGHT 150
#define CAROUSEL_HEIGHT 500
#define BUTTON_HEIGHT 150
#define BUTTON_WIDTH 300
#define DEFAULT_CAROUSEL_OFFSET 20000
#define SPIN_DURATION 5
#define BORDER_WIDTH 15

@interface SlotMachineViewController ()

@property SEssentialsCarouselLinear3D *leftCarousel;
@property SlotMachineCarouselDatasource *leftCarouselDatasource;
@property SEssentialsCarouselLinear3D *middleCarousel;
@property SlotMachineCarouselDatasource *middleCarouselDatasource;
@property SEssentialsCarouselLinear3D *rightCarousel;
@property SlotMachineCarouselDatasource *rightCarouselDatasource;

@property UIButton *slotMachineButton;
@property UILabel *resultLabel;
@property UIImageView *backgroundImage;
@property UILabel *leftTitleLabel;
@property UILabel *rightTitleLabel;

@property BOOL isSpinning;

@end

@implementation SlotMachineViewController

- (id)init
{
    self = [super init];
    if (self) {
        _isSpinning = NO;
        
        _backgroundImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _backgroundImage.image = [UIImage imageNamed:@"background.jpg"];
        [self.view addSubview:_backgroundImage];
        
        // Create title with two labels with different colors and fonts
        _leftTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    (self.view.bounds.size.width / 20) * 11,
                                                                    TITLE_LABEL_HEIGHT)];
        _leftTitleLabel.text = @"shinobi";
        _leftTitleLabel.font = [UIFont fontWithName:@"Nunito-Bold" size:80];
        _leftTitleLabel.backgroundColor = [UIColor clearColor];
        _leftTitleLabel.textAlignment = NSTextAlignmentRight;
        _leftTitleLabel.textColor = [UIColor redColor];
        [self.view addSubview:_leftTitleLabel];
        
        _rightTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width / 20) * 11,
                                                                     0,
                                                                     self.view.bounds.size.width / 2,
                                                                     TITLE_LABEL_HEIGHT)];
        _rightTitleLabel.text = @"slots";
        _rightTitleLabel.font = [UIFont fontWithName:@"Nunito-Regular" size:75];
        _rightTitleLabel.backgroundColor = [UIColor clearColor];
        _rightTitleLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:_rightTitleLabel];
        
        
        // Create the three 'slots'
        _leftCarousel = [self makeCarouselWithFrame:CGRectMake(BORDER_WIDTH,
                                                               PADDING*5,
                                                               (self.view.bounds.size.width - ((BORDER_WIDTH * 2) + (2 * PADDING))) / 3,
                                                               CAROUSEL_HEIGHT)];
        _leftCarouselDatasource = [[SlotMachineCarouselDatasource alloc] init];
        _leftCarousel.dataSource = _leftCarouselDatasource;
        [self.view addSubview:_leftCarousel];
        
        _middleCarousel = [self makeCarouselWithFrame:CGRectMake(CGRectGetMaxX(_leftCarousel.frame) + PADDING,
                                                                 _leftCarousel.frame.origin.y,
                                                                 (self.view.bounds.size.width - ((BORDER_WIDTH * 2) + (2 * PADDING))) / 3,
                                                                 CAROUSEL_HEIGHT)];
        _middleCarouselDatasource = [[SlotMachineCarouselDatasource alloc] init];
        _middleCarousel.dataSource = _middleCarouselDatasource;
        [self.view addSubview:_middleCarousel];
        
        _rightCarousel = [self makeCarouselWithFrame:CGRectMake(CGRectGetMaxX(_middleCarousel.frame) + PADDING,
                                                                _middleCarousel.frame.origin.y,
                                                                (self.view.bounds.size.width - ((BORDER_WIDTH * 2) + (2 * PADDING))) / 3,
                                                                CAROUSEL_HEIGHT)];
        _rightCarouselDatasource = [[SlotMachineCarouselDatasource alloc] init];
        _rightCarousel.dataSource = _rightCarouselDatasource;
        _rightCarousel.delegate = self;
        [self.view addSubview:_rightCarousel];
        
        UILabel *box = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                 _leftCarousel.frame.origin.y + (CAROUSEL_HEIGHT - SLOT_SIZE - (2 * PADDING)) / 2,
                                                                 self.view.bounds.size.width,
                                                                 SLOT_SIZE + (2 * PADDING))];
        box.backgroundColor = [UIColor clearColor];
        box.layer.borderWidth = BORDER_WIDTH;
        box.layer.borderColor = [UIColor redColor].CGColor;
        [self.view addSubview:box];
        
        _slotMachineButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - BUTTON_WIDTH) / 2,
                                                                        self.view.bounds.size.height - (BUTTON_HEIGHT + (1.5*PADDING)),
                                                                        BUTTON_WIDTH,
                                                                        BUTTON_HEIGHT)];
        [_slotMachineButton setTitle:@"PLAY!" forState:UIControlStateNormal];
        [_slotMachineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_slotMachineButton setBackgroundColor:[UIColor redColor]];
        [[_slotMachineButton titleLabel] setFont:[UIFont fontWithName:@"Nunito-Regular" size:50]];
        [_slotMachineButton addTarget:self action:@selector(letsPlay) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_slotMachineButton];
        
        _resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                 CGRectGetMaxY(_leftCarousel.frame),
                                                                 self.view.bounds.size.width,
                                                                 _slotMachineButton.frame.origin.y - CGRectGetMaxY(_leftCarousel.frame))];
        [_resultLabel setTextColor:[UIColor yellowColor]];
        [_resultLabel setFont:[UIFont fontWithName:@"Nunito-Regular" size:50]];
        [_resultLabel setBackgroundColor:[UIColor clearColor]];
        [_resultLabel setTextAlignment:NSTextAlignmentCenter];
        [_resultLabel setNumberOfLines:0];
        [_resultLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.view addSubview:_resultLabel];
    }
    return self;
}

-(SEssentialsCarouselLinear3D*)makeCarouselWithFrame:(CGRect) frame{
    SEssentialsCarouselLinear3D *carousel = [[SEssentialsCarouselLinear3D alloc] initWithFrame:frame];
    carousel.backgroundColor = [UIColor whiteColor];
    carousel.orientation = SEssentialsCarouselOrientationVertical;
    carousel.wrapItems = YES;
    carousel.maxNumberOfItemsToDisplay = 3;
    carousel.scaleFactor = 0.5;
    carousel.itemSpacingFactor = 1.25;
    carousel.userInteractionEnabled = NO;
    return carousel;
}

-(void)letsPlay {
    if(!_isSpinning)
    {
        _resultLabel.hidden = YES;
        _isSpinning = YES;
        
        [self spinLeft];
        
        [self performSelector:@selector(spinMiddle) withObject:nil afterDelay:[[NSNumber numberWithFloat:0.7] doubleValue]];
        
        [self performSelector:@selector(spinRight) withObject:nil afterDelay:[[NSNumber numberWithFloat:1.5] doubleValue]];
    }
}

-(int)matchingSlots {
    UIImageView *leftImageView = (UIImageView*)_leftCarousel.currentItemInFocus;
    UIImageView *middleImageView = (UIImageView*)_middleCarousel.currentItemInFocus;
    UIImageView *rightImageView = (UIImageView*)_rightCarousel.currentItemInFocus;
    if ([leftImageView.image isEqual:rightImageView.image] && [leftImageView.image isEqual:middleImageView.image]) {
        return 3;
    }
    else if([leftImageView.image isEqual:rightImageView.image] || [leftImageView.image isEqual:middleImageView.image] || [middleImageView.image isEqual:rightImageView.image]) {
        return 2;
    }
    return 1;
}

#pragma mark SEssentialsCarousel Delegate Methods

// The delegate is only set on the right carousel.
// So this method is only called when the right carousel is finished scrolling.
-(void)carousel:(SEssentialsCarousel *)carousel didFinishScrollingAtOffset:(float)offset {
    _isSpinning = NO;
    
    int result = [self matchingSlots];
    
    if (result == 3) {
        _resultLabel.text = @"WINNER WINNER\nCHICKEN DINNER!!!";
    }
    else if(result == 2){
       _resultLabel.text = @"OOOHHHHH!!! \nSOOO CLOSE...";
    }
    else {
        _resultLabel.text = @"Not this time... Try again!";
    }
    _resultLabel.hidden = NO;
}

#pragma mark Carousel Spinning Methods

-(void)spinLeft {
    [_leftCarousel setContentOffset:_leftCarousel.contentOffset + DEFAULT_CAROUSEL_OFFSET + arc4random() % (SLOT_SIZE * _leftCarouselDatasource.slotImages.count)
                           animated:YES
                       withDuration:SPIN_DURATION];
}

-(void)spinMiddle {
    [_middleCarousel setContentOffset:_middleCarousel.contentOffset + DEFAULT_CAROUSEL_OFFSET + arc4random() % (SLOT_SIZE * _middleCarouselDatasource.slotImages.count)
                             animated:YES
                         withDuration:SPIN_DURATION];
}

-(void)spinRight {
    [_rightCarousel setContentOffset:_rightCarousel.contentOffset + DEFAULT_CAROUSEL_OFFSET + arc4random() % (SLOT_SIZE * _rightCarouselDatasource.slotImages.count)
                            animated:YES
                        withDuration:SPIN_DURATION];
}

@end
