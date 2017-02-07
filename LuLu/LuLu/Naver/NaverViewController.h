//
//  NaverViewController.h
//  LuLu
//
//  Created by Su-gil Lee on 2017. 2. 7..
//  Copyright © 2017년 Sokm83. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NaverThirdPartyLoginConnection.h"

@interface NaverViewController : UIViewController <NaverThirdPartyLoginConnectionDelegate>
{
    NaverThirdPartyLoginConnection *_naverLoginConn;
}

@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UIButton *loginBtn;

- (IBAction)loginBtnClicked:(id)sender;

@end
