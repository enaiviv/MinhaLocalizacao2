//
//  ViewController.m
//  MinhaLocalizacao2
//
//  Created by Viviane Rosa Marcos on 03/02/14.
//  Copyright (c) 2014 nivi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        locMgr = [[CLLocationManager alloc] init];
        [locMgr setDelegate:self];
        
        //Esse DistanceFilter vai pedir o intervalo de espaço do movimento percorrido para atualizar o app, isso permite navegar pelo mapa sem que ele volte à sua localização
        [locMgr setDistanceFilter: 10.0];

        
        [locMgr startUpdatingLocation];
        
    }
    return self;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"Estou em %@", [locations lastObject]);
    
    //Aqui eu determino a área que vai delimitar o mapa
    CLLocationCoordinate2D loc = [[locations lastObject] coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 250, 250);
    
//    //Aqui eu crio uma anotação no mapa (um alfinete)
//    MKPointAnnotation *a = [[MKPointAnnotation alloc] init];
//    [a setCoordinate:loc];
//    [mapView addAnnotation:a];
//    
    [mapView setRegion:region animated:YES];
    
}

-(void)showRoute: (MKDirectionsResponse *)response {
    for(MKRoute *route in response.routes)
    {
        [mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
    }
 }

-(MKOverlayRenderer *) mapa: (MKMapView *)mapa rendererForOverlay: (id<MKOverlay>)overlay {
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [UIColor redColor];
    renderer.lineWidth = 4.0;
    return renderer;
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Erro %@", error);
}

-(void) adicionaPino: (UIGestureRecognizer *) gesto {
    if (gesto.state == UIGestureRecognizerStateBegan) {
        CGPoint ponto = [gesto locationInView:self.view];
        
        CLLocationCoordinate2D coordenadas = [self->mapView convertPoint:ponto toCoordinateFromView:self->mapView];
        
        MKPointAnnotation *pino = [[MKPointAnnotation alloc] init];
        pino.coordinate = coordenadas;
        [self->mapView addAnnotation:pino];
        
        MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
        MKMapItem *source = [MKMapItem mapItemForCurrentLocation];
       // CLLocationCoordinate2D destinationCoords = CLLocationCoordinate2DMake(38.8977, -77.0365);
        MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:coordenadas addressDictionary:nil];
        MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
        
        [directionsRequest setSource:source];
        [directionsRequest setDestination:destination];
        
        MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
        
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            if (error) {
                NSLog(@"There was an error getting your directions");
                return ;
            }
            else
            {

              [self showRoute:response];
            }
        }];
        
        
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
        {
        MKPolylineView*  aView = [[MKPolylineView alloc] initWithPolyline:(MKPolyline*)overlay];
        aView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        aView.lineWidth = 10;
    
    return aView;
            }
    
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Adicionar pinos com toque (da apostila)

    mapView.showsUserLocation = YES;
    
    //O mapa fica real
    mapView.showsUserLocation=TRUE;
    mapView.mapType=MKMapTypeHybrid;
    
    UILongPressGestureRecognizer *toquelongoMapa = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(adicionaPino:)];
    
    toquelongoMapa.minimumPressDuration = 0.3;
    [mapView addGestureRecognizer:toquelongoMapa];

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)search
{
    [self->search resignFirstResponder];
    MKLocalSearchRequest *pedido = [[MKLocalSearchRequest alloc] init];
    pedido.naturalLanguageQuery = self->search.text;
    pedido.region = mapView.region;
    MKLocalSearch *searchbar = [[MKLocalSearch alloc]initWithRequest:pedido];
    
    [searchbar startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSMutableArray *pontosInteres = [[NSMutableArray alloc] init];
        for (MKMapItem *item in response.mapItems){
            [pontosInteres addObject:item.placemark];
        }
        [mapView showAnnotations:pontosInteres animated:YES];
    }];
}


- (IBAction)ActionMap:(id)sender {
    switch (OptionMap.selectedSegmentIndex) {
        case 0:
            mapView.mapType = MKMapTypeStandard;
            break;
            
        case 1:
            mapView.mapType = MKMapTypeSatellite;
        
        case 2:
            mapView.mapType = MKMapTypeHybrid;
            
        default:
            break;
    }
}
@end
