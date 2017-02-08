//
//  NaverMapViewController.m
//  LuLu
//
//  Created by Su-gil Lee on 2017. 2. 8..
//  Copyright © 2017년 Sokm83. All rights reserved.
//

#import "NaverMapViewController.h"
#import "NaverViewController.h"
#import <NMapViewerSDK/NMapView.h>
#import <NMapViewerSDK/NMapLocationManager.h>
#import <CoreLocation/CoreLocation.h>

@interface NaverMapViewController ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NMapView *mapView;
@end

@implementation NaverMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    
    // Location Manager 생성
    self.locationManager = [[CLLocationManager alloc] init];
    // Location Receiver 콜백에 대한 delegate 설정
    self.locationManager.delegate = self;
    // 사용중에만 위치 정보 요청
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    // Location Manager 시작하기
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // create map view
    self.mapView = [[NMapView alloc] initWithFrame:self.view.bounds];
    // set delegate for map view
    [self.mapView setDelegate:self];
    // set Client ID for Open MapViewer Library
    [self.mapView setClientId:kClientID];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
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


#pragma mark - NMapViewDelegate Method

- (void) onMapView:(NMapView *)mapView initHandler:(NMapError *)error {
    if (error == nil) { // success
        // set map center and level
        [self.mapView setMapCenter:NGeoPointMake(126.978371, 37.5666091) atLevel:11];
        // set for retina display
        [self.mapView setMapEnlarged:YES mapHD:YES];
        // set default map mode
        [self.mapView setMapViewMode:NMapViewModeVector];
    } else { // fail
        NSLog(@"onMapView:initHandler: %@", [error description]);
    }
}

#pragma mark - NMapPOIdataOverlayDelegate

- (UIImage *) onMapOverlay:(NMapPOIdataOverlay *)poiDataOverlay imageForOverlayItem:(NMapPOIitem *)poiItem selected:(BOOL)selected {
    return nil;
}

- (CGPoint) onMapOverlay:(NMapPOIdataOverlay *)poiDataOverlay anchorPointWithType:(NMapPOIflagType)poiFlagType {
    return CGPointZero;
}

- (UIImage*) onMapOverlay:(NMapPOIdataOverlay *)poiDataOverlay imageForCalloutOverlayItem:(NMapPOIitem *)poiItem
           constraintSize:(CGSize)constraintSize selected:(BOOL)selected
imageForCalloutRightAccessory:(UIImage *)imageForCalloutRightAccessory
          calloutPosition:(CGPoint *)calloutPosition calloutHitRect:(CGRect *)calloutHitRect {
    return nil;
}

- (CGPoint) onMapOverlay:(NMapPOIdataOverlay *)poiDataOverlay calloutOffsetWithType:(NMapPOIflagType)poiFlagType {
    return CGPointZero;
}

#pragma mark - NMapLocationManagerDelegate
- (void)locationManager:(NMapLocationManager *)locationManager didUpdateToLocation:(CLLocation *)location {
    
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    NGeoPoint myLocation;
    myLocation.longitude = coordinate.longitude;
    myLocation.latitude = coordinate.latitude;
    float locationAccuracy = [location horizontalAccuracy];
    
    [[self.mapView mapOverlayManager] setMyLocation:myLocation locationAccuracy:locationAccuracy];
    [self.mapView setMapCenter:myLocation];
}

- (void)locationManager:(NMapLocationManager *)locationManager didFailWithError:(NMapLocationManagerErrorType)errorType {
    NSString *message = nil;
    switch (errorType) {
        case NMapLocationManagerErrorTypeUnknown:
        case NMapLocationManagerErrorTypeCanceled:
        case NMapLocationManagerErrorTypeTimeout:
            message = @"일시적으로 내위치를 확인 할 수 없습니다.";
            break;
        case NMapLocationManagerErrorTypeDenied:
            if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0f )
                message = @"위치 정보를 확인 할 수 없습니다.\n사용자의 위치 정보를 확인하도록 허용하시려면 위치서비스를 켜십시오.";
            else
                message = @"위치 정보를 확인 할 수 없습니다.";
            break;
        case NMapLocationManagerErrorTypeUnavailableArea:
            message = @"현재 위치는 지도내에 표시 할 수 없습니다.";
            break;
        case NMapLocationManagerErrorTypeHeading:
            message = @"나침반 정보를 확인 할 수 없습니다.";
            break;
        default:
            break;
    }
    if (message) {
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"NMapViewer"
                                      message:message
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    if ([self.mapView isAutoRotateEnabled]) {
        [self.mapView setAutoRotateEnabled:NO animate:YES];
    }
    
    [[self.mapView mapOverlayManager] clearMyLocationOverlay];
}

- (void)locationManager:(NMapLocationManager *)locationManager didUpdateHeading:(CLHeading *)heading {
    double headingValue = [heading trueHeading] < 0.0 ? [heading magneticHeading] : [heading trueHeading];
    [self setCompassHeadingValue:headingValue];
}


#pragma mark - NaverMapViewController

- (void) setCompassHeadingValue : (CGFloat) headingValue {
    if ([self.mapView isAutoRotateEnabled] == YES) {
        [self.mapView setRotateAngle:headingValue animate:YES];
    }
}

@end
