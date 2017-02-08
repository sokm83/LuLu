//
//  NaverLoginViewController.m
//  LuLu
//
//  Created by Su-gil Lee on 2017. 2. 8..
//  Copyright © 2017년 Sokm83. All rights reserved.
//

#import "NaverViewController.h"
#import "NaverLoginViewController.h"
#import "NaverThirdPartyConstantsForApp.h"
#import "NaverThirdPartyLoginConnection.h"
#import "NLoginThirdPartyOAuth20InAppBrowserViewController.h"

@interface NaverLoginViewController ()

@end

@implementation NaverLoginViewController

@synthesize loginBtn, logoutBtn, statusLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _naverLoginConn = [NaverThirdPartyLoginConnection getSharedInstance];
    _naverLoginConn.delegate = self;
    [_naverLoginConn setIsNaverAppOauthEnable:YES];
    [_naverLoginConn setIsInAppOauthEnable:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginBtnClicked:(id)sender {
    [self requestThirdpartyLogin];
}

- (IBAction)logoutBtnClicked:(id)sender {
    [self requestDeleteToken];
}

- (void)setLoginStatusBtn:(BOOL)isLogin {
    if(isLogin) {
        [self.loginBtn setHidden:YES];
        [self.logoutBtn setHidden:NO];
    } else {
        [self.loginBtn setHidden:NO];
        [self.logoutBtn setHidden:YES];
    }
}

#pragma mark - Requests
- (void)requestThirdpartyLogin
{
    // NaverThirdPartyLoginConnection의 인스턴스에 서비스앱의 url scheme와 consumer key, consumer secret, 그리고 appName을 파라미터로 전달하여 3rd party OAuth 인증을 요청한다.
    
    NaverThirdPartyLoginConnection *tlogin = [NaverThirdPartyLoginConnection getSharedInstance];
    [tlogin setConsumerKey:kClientID];
    [tlogin setConsumerSecret:kClientSecret];
    [tlogin setAppName:kServiceAppName];
    [tlogin setServiceUrlScheme:kServiceAppUrlScheme];
    [tlogin requestThirdPartyLogin];
}

- (void)requestAccessTokenWithRefreshToken
{
    NaverThirdPartyLoginConnection *tlogin = [NaverThirdPartyLoginConnection getSharedInstance];
    [tlogin setConsumerKey:kClientID];
    [tlogin setConsumerSecret:kClientSecret];
    [tlogin requestAccessTokenWithRefreshToken];
}

- (void)resetToken
{
    [_naverLoginConn resetToken];
}

- (void)requestDeleteToken
{
    NaverThirdPartyLoginConnection *tlogin = [NaverThirdPartyLoginConnection getSharedInstance];
    [tlogin requestDeleteToken];
}

- (void)requestUserInfo
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURL * url = [NSURL URLWithString:@"https://openapi.naver.com/v1/nid/me"];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:[NSString stringWithFormat:@"Bearer %@", _naverLoginConn.accessToken] forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask * dataTask = [defaultSession
                                       dataTaskWithRequest:urlRequest
                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                           if(error == nil)
                                           {
                                               NSString * text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                               NSLog(@"DATA: [%@]",text);
                                               
                                               text = [text stringByReplacingOccurrencesOfString:@"{" withString:@""];
                                               text = [text stringByReplacingOccurrencesOfString:@"}" withString:@""];
                                               text = [text stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                                               text = [text stringByReplacingOccurrencesOfString:@"response:" withString:@""];
                                               
                                               NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                                               NSArray *dictArray = [text componentsSeparatedByString:@","];
                                               for(NSString *item in dictArray) {
                                                   NSLog(@"item[%@]", item);
                                                   NSArray *itemArray = [item componentsSeparatedByString:@":"];
                                                   if([itemArray count] > 1) {
                                                       if([itemArray[0] isEqualToString:@"profile_image"]) {
                                                           NSString *urlPath = [item stringByReplacingOccurrencesOfString:@"profile_image:" withString:@""];
                                                           [dict setObject:urlPath forKey:itemArray[0]];
                                                       } else
                                                           [dict setObject:itemArray[1] forKey:itemArray[0]];
                                                   }
                                               }
                                               
                                               NSLog(@"Result: %@", dict);
                                           } else {
                                               NSLog(@"Got response %@ with error %@.\n", response, error);
                                               NSLog(@"DATA: [%@]",
                                                     [[NSString alloc] initWithData: data
                                                                           encoding: NSUTF8StringEncoding]);
                                           }
                                           
                                       }];
    [dataTask resume];
}


#pragma mark - NaverOAuthConnectionDelegate
- (void) presentWebviewControllerWithRequest:(NSURLRequest *)urlRequest   {
    // FormSheet모달위에 FullScreen모달이 뜰 떄 애니메이션이 이상하게 동작하여 애니메이션이 없도록 함
    
    NLoginThirdPartyOAuth20InAppBrowserViewController *inAppBrowserViewController = [[NLoginThirdPartyOAuth20InAppBrowserViewController alloc] initWithRequest:urlRequest];
    inAppBrowserViewController.parentOrientation = (UIInterfaceOrientation)[[UIDevice currentDevice] orientation];
    [self presentViewController:inAppBrowserViewController animated:YES completion:nil];
}


#pragma mark - NaverThirdPartyLoginConnectionDelegate

- (void)oauth20ConnectionDidOpenInAppBrowserForOAuth:(NSURLRequest *)request {
    NSLog(@"%s", __FUNCTION__);
    
    [self presentWebviewControllerWithRequest:request];
}

- (void)oauth20Connection:(NaverThirdPartyLoginConnection *)oauthConnection didFailWithError:(NSError *)error {
    NSLog(@"%s=[%@]", __FUNCTION__, error);
    [self.statusLabel setText:[NSString stringWithFormat:@"%@", error]];
}

- (void)oauth20ConnectionDidFinishRequestACTokenWithAuthCode {
    NSLog(@"%s\n[%@]", __FUNCTION__, [NSString stringWithFormat:@"OAuth Success!\nAccess Token - %@\nAccess Token Expire Date- %@\nRefresh Token - %@", _naverLoginConn.accessToken, _naverLoginConn.accessTokenExpireDate, _naverLoginConn.refreshToken]);
    
    [self.statusLabel setText:[NSString stringWithFormat:@"OAuth Success!\nAccess Token - %@\nAccess Token Expire Date- %@\nRefresh Token - %@", _naverLoginConn.accessToken, _naverLoginConn.accessTokenExpireDate, _naverLoginConn.refreshToken]];
    [self setLoginStatusBtn:YES];
    
    [self requestUserInfo];
}

- (void)oauth20ConnectionDidFinishRequestACTokenWithRefreshToken {
    NSLog(@"%s\n[%@]", __FUNCTION__, [NSString stringWithFormat:@"Refresh Success!\nAccess Token - %@\nAccess sToken ExpireDate- %@", _naverLoginConn.accessToken, _naverLoginConn.accessTokenExpireDate ]);
    
    [self.statusLabel setText:[NSString stringWithFormat:@"Refresh Success!\nAccess Token - %@\nAccess sToken ExpireDate- %@", _naverLoginConn.accessToken, _naverLoginConn.accessTokenExpireDate]];
    [self setLoginStatusBtn:YES];
    
    [self requestUserInfo];
}

- (void)oauth20ConnectionDidFinishDeleteToken {
    NSLog(@"%s", __FUNCTION__);
    
    [self.statusLabel setText:@"로그인 해주세요."];
    
    [self setLoginStatusBtn:NO];
}

@end
