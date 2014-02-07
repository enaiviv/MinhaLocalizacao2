//
//  ViewController.h
//  MinhaLocalizacao2
//
//  Created by Viviane Rosa Marcos on 03/02/14.
//  Copyright (c) 2014 nivi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UIScrollViewDelegate>


{
    __weak IBOutlet MKMapView *mapView;
    CLLocationManager *locMgr;
    
    //Método para frequencia de chamada do delegate
    CLLocationDistance distanceFilter;
    
    __weak IBOutlet UISegmentedControl *OptionMap;
    
    __weak IBOutlet UISearchBar *search;
        
}

- (IBAction)ActionMap:(id)sender;

@end
