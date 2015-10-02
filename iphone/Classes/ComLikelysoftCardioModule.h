/**
 * ios
 *
 * Created by Your Name
 * Copyright (c) 2015 Your Company. All rights reserved.
 */

#import "TiModule.h"
#import "CardIO.h"

@interface ComLikelysoftCardioModule : TiModule <CardIOPaymentViewControllerDelegate>
{
    KrollCallback * _callback;
}
@property (nonatomic, retain) KrollCallback * _callback;
@end
