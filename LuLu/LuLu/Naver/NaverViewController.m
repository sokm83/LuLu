//
//  NaverViewController.m
//  LuLu
//
//  Created by Su-gil Lee on 2017. 2. 7..
//  Copyright © 2017년 Sokm83. All rights reserved.
//

#import "NaverViewController.h"
#import "NaverLoginViewController.h"
#import "NaverMapViewController.h"

@interface NaverViewController ()

@end

@implementation NaverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            NaverLoginViewController * viewController = [[NaverLoginViewController alloc] init];
            viewController.title = @"네이버 아이디로 로그인";
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case 1:
        {
            NaverMapViewController * viewController = [[NaverMapViewController alloc] init];
            viewController.title = @"네이버 지도";
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case 2:
        {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

@end
