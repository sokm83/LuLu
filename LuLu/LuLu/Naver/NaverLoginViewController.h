//
//  NaverLoginViewController.h
//  LuLu
//
//  Created by Su-gil Lee on 2017. 2. 8..
//  Copyright © 2017년 Sokm83. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NaverThirdPartyLoginConnection.h"

@interface NaverLoginViewController : UIViewController <NaverThirdPartyLoginConnectionDelegate>
{
    NaverThirdPartyLoginConnection *_naverLoginConn;
}

@property (nonatomic, strong) IBOutlet UIButton *loginBtn;
@property (nonatomic, strong) IBOutlet UIButton *logoutBtn;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;

- (IBAction)loginBtnClicked:(id)sender;
- (IBAction)logoutBtnClicked:(id)sender;

@end
