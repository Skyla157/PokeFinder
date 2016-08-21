//
//  ViewController.swift
//  PokeFinder
//
//  Created by Meagan McDonald on 8/17/16.
//  Copyright © 2016 Skyla Apps. All rights reserved.
//

import UIKit
import MapKit
import GeoFire
import Firebase
import FirebaseDatabase
import Contacts

extension NSLayoutConstraint {
    override open var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)"
    }
}

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false
    
    var geoFire: GeoFire!
    var geoFireRef: FIRDatabaseReference!
    var selectedPokemon: Pokemon!
    var isPinPlaced: Bool = false
    var annoArr = [MKAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow //map moves with your location
        locationManager.requestWhenInUseAuthorization()
        
        geoFireRef = FIRDatabase.database().reference()
        geoFire = GeoFire(firebaseRef: geoFireRef)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MapVC.createPokeSighting), name: NSNotification.Name(rawValue: "savePokemon"), object: nil)
        
        addGestureRecognizer()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
    }
    
    //MARK: - LOCATION AUTH
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    //MARK: - MAP VIEW
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            if !mapHasCenteredOnce {
                centerMapOnLocation(location: loc)
                mapHasCenteredOnce = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        showSightingsOnMap(location: location)
    }
    
    //MARK: Annotation
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annoIdentifier = "Pokemon"
        var annotationView: MKAnnotationView?
        if annotation.isKind(of: MKUserLocation.self) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage(named: "ash")
        } else if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: annoIdentifier) {
            annotationView = deqAnno
            annotationView?.annotation = annotation
        } else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
        }
        
        if let annotationView = annotationView, let anno = annotation as? PokeAnnotation {
            //must have title or will crash
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "\(anno.pokemonNumber)")
            selectedPokemon = Pokemon(name: anno.pokemonName, iD: anno.pokemonNumber)
            let mapBtn = UIButton()
            mapBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            mapBtn.setImage(UIImage(named: "map"), for: .normal)
            annotationView.leftCalloutAccessoryView = mapBtn
            
            let infoBtn = UIButton()
            infoBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            infoBtn.setImage(UIImage(named: "info"), for: .normal)
            annotationView.rightCalloutAccessoryView = infoBtn
            
        } else if !annotation.isKind(of: MKUserLocation.self) {
            let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            savedLocation = location
                
                let pinAnnoView = MKPinAnnotationView()
                pinAnnoView.canShowCallout = true
                pinAnnoView.pinTintColor = .purple
                pinAnnoView.isDraggable = true
                pinAnnoView.animatesDrop = true
                
                
                //isPinPlaced = true
                
                return pinAnnoView
            
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .ending, .canceling:
            view.dragState = .none
        default: break
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.leftCalloutAccessoryView {
        
            if let anno = view.annotation as? PokeAnnotation {
                var place: MKPlacemark!
                if #available(iOS 10.0, *) {
                    place = MKPlacemark(coordinate: anno.coordinate)
                } else {
                    //let addressDictionary = [String(CNPostalAddressStreetKey): anno.title!]
                    place = MKPlacemark(coordinate: anno.coordinate, addressDictionary: nil)
                }
                let destination = MKMapItem(placemark: place)
                destination.name = "Pokemon Sighting"
                let regionDistance: CLLocationDistance = 100
                let regionSpan = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
                let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
                MKMapItem.openMaps(with: [destination], launchOptions: options)            
            }
        } else if control == view.rightCalloutAccessoryView {
            if let anno = view.annotation as? PokeAnnotation {
                let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsVCID") as! PokemonDetailVC
                detailsVC.pokemon = Pokemon(name: anno.pokemonName, iD: anno.pokemonNumber)
                navigationController?.pushViewController(detailsVC, animated: true)
            }
        }
    }
    
    //MARK: - FINGER TAPS
    
    func addGestureRecognizer() {
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapVC.didSingleTap(recognizer:)))
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapVC.didDoubleTap(recognizer:)))
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapVC.didLongPress(recognizer:)))
        
        singleTapRecognizer.numberOfTapsRequired = 1
        doubleTapRecognizer.numberOfTapsRequired = 2
        
        //mapView.addGestureRecognizer(longPressRecognizer)
        mapView.addGestureRecognizer(singleTapRecognizer)
        //mapView.addGestureRecognizer(doubleTapRecognizer)
        
        singleTapRecognizer.require(toFail: doubleTapRecognizer)
    }
    
    func didLongPress(recognizer: UILongPressGestureRecognizer) {
    }
    
    func didSingleTap(recognizer: UITapGestureRecognizer) {
        if !isPinPlaced {
            let location = recognizer.location(in: mapView)
            let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
            
            let tapAnno = MKPointAnnotation()
            tapAnno.coordinate = coordinate
            tapAnno.title = "Tapped"
            tapAnno.subtitle = "I've been tapped!"
            mapView.addAnnotation(tapAnno)
            isPinPlaced = true
        }
    }

    func didDoubleTap(recognizer: UITapGestureRecognizer) {
        
    }

    
    //MARK: - POKEMON SIGHTINGS
    
    func createPokeSighting() {
        geoFire.setLocation(savedLocation, forKey: "\(savedPokemon.pokedexID)")
    }
    
    func showSightingsOnMap(location: CLLocation) {
        let circleQuery = geoFire.query(at: location, withRadius: 2.5)
        _ = circleQuery?.observe(GFEventType.keyEntered, with: { (key, location) in
            if let key = key, let location = location {
                let anno = PokeAnnotation(coordinate: location.coordinate, pokemonNum: Int(key)!)
                self.mapView.addAnnotation(anno)
            }
        })
    }
    
    @IBAction func spotRandomPokemon(_ sender: UIButton) {
        
        
        //let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        //let rand = arc4random_uniform(151) + 1
        //createSighting(forLocation: location, withPokemon: Int(rand))
     }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Add" {
            if let addVC = segue.destination as? AddVC {
                print("Segue: \(savedLocation)")
                addVC.loc = savedLocation
                print("Segue: \(addVC.loc)")
            }
        }
    }

}
