#import <MapKit/MapKit.h>

@interface RegionAnnotation : NSObject <MKAnnotation> {
    
}

@property (nonatomic, retain) CLCircularRegion *region;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, readwrite) CLLocationDistance radius;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

- (id)initWithCLRegion:(CLRegion *)newRegion;

@end
