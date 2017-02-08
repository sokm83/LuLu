//
//  NaverMapViewController.h
//  LuLu
//
//  Created by Su-gil Lee on 2017. 2. 8..
//  Copyright © 2017년 Sokm83. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NMapViewerSDK/NMapView.h>
#import <NMapViewerSDK/NMapLocationManager.h>

@interface NaverMapViewController : UIViewController <CLLocationManagerDelegate, NMapViewDelegate, NMapPOIdataOverlayDelegate, NMapLocationManagerDelegate>

@end
