import UIKit
import MapKit

class MapFrienderViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var myTabBarIT: UITabBarItem!
    
    let rippleLayer = RippleLayer()
    
    var mapManaager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Chek user is open GPS service
        guard CLLocationManager.locationServicesEnabled() else {
            //Alert user
            return
        }
        //Ask user's permission
        mapManaager.requestAlwaysAuthorization()
        
        self.mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}


extension MapFrienderViewController :MKMapViewDelegate{
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if annotation.isEqual(mapView.userLocation) {
//            let annotationView = MyMKAnnotationView(annotation: annotation, reuseIdentifier: "userLocation")
//
//            let userEmail = UserDefaults.standard
//            guard let emailHead = userEmail.string(forKey: "emailHead") else {
//                return nil
//            }
//
//            let image = Manager.shared.userPhotoRead(jpg: emailHead)
//            let reSizeImage = Manager.shared.resizeImage(image: image!)
//
//            annotationView.image = reSizeImage
//            //self.rippleLayer.position = CGPoint(x: , y: annotationView.frame.origin.y)
//            //self.view.layer.addSublayer(rippleLayer)
//
//            return annotationView
//        }
//        return nil
//    }
}

class MyMKAnnotationView :MKAnnotationView {
    var myimage :UIImageView?
}
