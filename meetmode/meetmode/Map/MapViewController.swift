//
//  MapViewController.swift
//  meetmode
//
//  Created by Varun Iyer on 3/3/20.
//  Copyright © 2020 spott. All rights reserved.
//

import RIBs
import RxSwift
import UIKit
import Mapbox
import RxGesture
import MapboxDirections

protocol MapPresentableListener: class {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func updateLocation(coordinate: CLLocationCoordinate2D)
    func tappedBackButton()
    func tappedOnFriendAnnotation(friend: User)
}

final class MapViewController: UIViewController, MapPresentable, MapViewControllable {
    
    weak var listener: MapPresentableListener?
    
    init(w: CGFloat, h: CGFloat) {
        self.w = w
        self.h = h
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Method is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        _setupMapView()
        
        createLocationManager()
        view.addSubview(mapView)
        _setupBackButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showAnnotations()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom]
    }
    
    // MARK: - MapViewControllable
    
    func show(view: ViewControllable) {
        addChild(view.uiviewController)
        self.view.addSubview(view.uiviewController.view)
    }
    
    func hide(view: ViewControllable) {
        view.uiviewController.removeFromParent()
        view.uiviewController.view.removeFromSuperview()
    }

    // MARK: - MapPresentable

    func addAnnotations(friends: [User]) {
        if mapView != nil {
            for friend in friends {
                let point = MapAnnotation()
                point.coordinate = friend.coordinate
                point.title = friend.uid
                point.friend = friend
                point.type = "friend"
                
                mapView.addAnnotation(point)
            }
        }
    }
    
    func drawRoute(id: String, route: Route, dest: CLLocationCoordinate2D) {
        guard route.coordinateCount > 0 else { return }
        
        allCoordinates = route.coordinates!

        if let pstyle = polylineStyle {
            mapView.style?.removeLayer(pstyle)
        }
        
        if let source = mapView.style?.source(withIdentifier: "\(id)-source") as? MGLShapeSource {
            source.shape = nil
            polylineSource = source
            
            let lineStyle = MGLLineStyleLayer(identifier: "\(id)-style", source: source)
            lineStyle.lineJoin = NSExpression(forConstantValue: "round")
            lineStyle.lineCap = NSExpression(forConstantValue: "round")
            lineStyle.lineColor = NSExpression(forConstantValue: UIColor(red: 213/255, green: 168/255, blue: 94/255, alpha: 1.0))
            lineStyle.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
            [14: 5, 18: 20])

            mapView.style?.addLayer(lineStyle)
            polylineStyle = lineStyle
        } else {
            let source = MGLShapeSource(identifier: "\(id)-source", shape: nil, options: nil)
            mapView.style?.addSource(source)
            polylineSource = source
            
            let lineStyle = MGLLineStyleLayer(identifier: "\(id)-style", source: source)
            lineStyle.lineJoin = NSExpression(forConstantValue: "round")
            lineStyle.lineCap = NSExpression(forConstantValue: "round")
            lineStyle.lineColor = NSExpression(forConstantValue: UIColor(red: 213/255, green: 168/255, blue: 94/255, alpha: 1.0))
            lineStyle.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
            [14: 5, 18: 20])

            mapView.style?.addLayer(lineStyle)
            polylineStyle = lineStyle
        }
        
        animatePolyline(coordinateCount: allCoordinates.count)
        polylineZoom(dest: dest)
        focusAnnotation(id: id)
    }
    
    func resetRoute() {
        if let pstyle = polylineStyle {
            mapView.style?.removeLayer(pstyle)
        }
        for annotation in otherAnnotations {
            mapView.addAnnotation(annotation)
        }
        otherAnnotations = []
    }
    
    func showAnnotations() {
        if mapView != nil && mapView.userLocation != nil && mapView.annotations != nil {
            var upper = mapView.userLocation!.coordinate
            var lower = mapView.userLocation!.coordinate
            
            for (index, annotation) in mapView.annotations!.enumerated() {
                if annotation.coordinate.latitude > upper.latitude {
                    upper.latitude = annotation.coordinate.latitude
                }
                if annotation.coordinate.latitude < lower.latitude {
                    lower.latitude = annotation.coordinate.latitude
                }
                if annotation.coordinate.longitude < lower.longitude {
                    lower.longitude = annotation.coordinate.longitude
                }
                if annotation.coordinate.longitude > upper.longitude {
                    upper.longitude = annotation.coordinate.longitude
                }
                
                if index == mapView.annotations!.count - 1 {
                    let bounds = MGLCoordinateBounds(sw: lower, ne: upper)
                    let distance = Double.random(in: 2000...2500)
                    let pitch = 0.0
                    let heading = 0.0
                    let camera = MGLMapCamera(lookingAtCenter: mapView.userLocation!.coordinate, acrossDistance: distance, pitch: CGFloat(pitch), heading: heading)
                    let newCamera = mapView.camera(camera, fitting: bounds, edgePadding: UIEdgeInsets(top: 35, left: 35, bottom: 225 + 35, right: 35))
                    let d = newCamera.centerCoordinate.distance(from: mapView.centerCoordinate)
                    let duration = max(min(log(d/600), 2.5), 0.85)
                    mapView.fly(to: newCamera, withDuration: duration, completionHandler: nil)
                }
            }
        }
    }
    
    func backButtonEntranceAnimation() {
        if backImageView != nil && backBackgroundView != nil {
            let animator = UIViewPropertyAnimator(duration: 0.35, curve: .easeIn, animations: {
                self.backBackgroundView.alpha = 1
                self.backImageView.alpha = 1
            })
            
            animator.startAnimation()
        }
    }
    
    func backButtonExitAnimation() {
        if backImageView != nil && backBackgroundView != nil {
            let animator = UIViewPropertyAnimator(duration: 0.35, curve: .easeIn, animations: {
                self.backBackgroundView.alpha = 0
                self.backImageView.alpha = 0
            })
            
            animator.startAnimation()
        }
    }

    // MARK: - Private
    
    private func createLocationManager() {
        locationManager = CLLocationManager()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 5
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = false
        } else {
            // Fallback on earlier versions
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }

    private func _setupMapView() {
        let url = URL(string: "mapbox://styles/spottiyer/ck7ccpk7b0cm41imlwz324eve")
        mapView = MGLMapView(frame: CGRect(x: 0, y: 0, width: w, height: h), styleURL: url)
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.automaticallyAdjustsContentInset = true
        mapView.compassView.isHidden = true
        mapView.center = view.center
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        mapView.isUserInteractionEnabled = true
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.tintColor = UIColor(red: 213/255, green: 168/255, blue: 94/255, alpha: 1.0)
    }
    
    private func _setupBackButton() {
        backBackgroundView = UIView()
        backBackgroundView.backgroundColor = UIColor(red: 15/255, green: 16/255, blue: 18/255, alpha: 1.0)
        backBackgroundView.layer.cornerRadius = 25
        backBackgroundView.alpha = 0
        
        view.addSubview(backBackgroundView)
        backBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.top).offset(35)
            make.height.equalTo(50)
            make.width.equalTo(50)
            make.left.equalTo(self.view.snp.left).offset(15)
        }
        
        backImageView = UIImageView(image: UIImage(named: "backImage")!)
        backImageView.contentMode = .scaleAspectFit
        backImageView.alpha = 0
        
        view.addSubview(backImageView)
        backImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(backBackgroundView.snp.centerX).offset(-2)
            make.centerY.equalTo(backBackgroundView.snp.centerY)
            make.height.equalTo(20)
        }
        
        backBackgroundView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.generator.impactOccurred()
                self?.selectBackButtonAnimation()
                self?.listener?.tappedBackButton()
            })
            .disposed(by: disposeBag)
    }
    
    private func polylineZoom(dest: CLLocationCoordinate2D) {
        if mapView != nil && mapView.userLocation != nil && allCoordinates != nil {
            var upper = mapView.userLocation!.coordinate
            var lower = mapView.userLocation!.coordinate
            
            if dest.latitude > upper.latitude {
                upper.latitude = dest.latitude
            }
            if dest.latitude < lower.latitude {
                lower.latitude = dest.latitude
            }
            if dest.longitude < lower.longitude {
                lower.longitude = dest.longitude
            }
            if dest.longitude > upper.longitude {
                upper.longitude = dest.longitude
            }
            
            for (index, coordinate) in allCoordinates.enumerated() {
                if coordinate.latitude > upper.latitude {
                    upper.latitude = coordinate.latitude
                }
                if coordinate.latitude < lower.latitude {
                    lower.latitude = coordinate.latitude
                }
                if coordinate.longitude < lower.longitude {
                    lower.longitude = coordinate.longitude
                }
                if coordinate.longitude > upper.longitude {
                    upper.longitude = coordinate.longitude
                }
                
                if index == allCoordinates.count - 1 {
                    let bounds = MGLCoordinateBounds(sw: lower, ne: upper)
                    let distance = Double.random(in: 2000...2500)
                    let pitch = 0.0
                    let heading = 0.0
                    let camera = MGLMapCamera(lookingAtCenter: mapView.userLocation!.coordinate, acrossDistance: distance, pitch: CGFloat(pitch), heading: heading)
                    let newCamera = mapView.camera(camera, fitting: bounds, edgePadding: UIEdgeInsets(top: 107.5, left: 35, bottom: 4.5*h/10 + 35, right: 35))
                    let d = newCamera.centerCoordinate.distance(from: mapView.centerCoordinate)
                    let duration = max(min(log(d/600), 2.5), 0.85)
                    mapView.fly(to: newCamera, withDuration: duration, completionHandler: nil)
                }
            }
        }
    }
    
    private func animatePolyline(coordinateCount: Int) {
        currentIndex = 1
         
        // Start a timer that will simulate adding points to our polyline. This could also represent coordinates being added to our polyline from another source, such as a CLLocationManagerDelegate.
        timer = Timer.scheduledTimer(timeInterval: 0.35/Double(coordinateCount), target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
         
    @objc private func tick() {
        if currentIndex > allCoordinates.count {
            timer?.invalidate()
            timer = nil
            return
        }
         
        // Create a subarray of locations up to the current index.
        let coordinates = Array(allCoordinates[0..<currentIndex])
         
        // Update our MGLShapeSource with the current locations.
        updatePolylineWithCoordinates(coordinates: coordinates)
         
        currentIndex += 1
    }
     
    private func updatePolylineWithCoordinates(coordinates: [CLLocationCoordinate2D]) {
        var mutableCoordinates = coordinates
         
        let polyline = MGLPolylineFeature(coordinates: &mutableCoordinates, count: UInt(mutableCoordinates.count))
         
        // Updating the MGLShapeSource’s shape will have the map redraw our polyline with the current coordinates.
        polylineSource?.shape = polyline
    }
    
    private func focusAnnotation(id: String) {
        if mapView.annotations != nil {
            for annotation in mapView.annotations! {
                if annotation is MapAnnotation {
                    if (annotation as! MapAnnotation).type == "friend" {
                        if (annotation as! MapAnnotation).friend.uid != id.dropLast() {
                            mapView.removeAnnotation(annotation)
                            otherAnnotations.append(annotation)
                        }
                    }
                }
            }
        }
    }
    
    private func selectBackButtonAnimation() {
        backImageView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        backBackgroundView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        UIView.animate(withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.3,
            initialSpringVelocity: 6.0,
            options: .allowUserInteraction,
            animations: { [weak self] in
                self?.backImageView.transform = .identity
                self?.backBackgroundView.transform = .identity
            },
            completion: nil)
    }
    
    private let disposeBag = DisposeBag()
    private let w: CGFloat
    private let h: CGFloat
    private var mapView: MGLMapView!
    private var location: CLLocation?
    private var locationManager: CLLocationManager!
    private let generator = UIImpactFeedbackGenerator(style: .medium)
    
    // Polyline
    private var timer: Timer?
    private var polylineSource: MGLShapeSource?
    private var polylineStyle: MGLLineStyleLayer?
    private var otherAnnotations: [MGLAnnotation] = []
    private var currentIndex = 1
    private var allCoordinates: [CLLocationCoordinate2D]!
    
    // Back Button
    private var backImageView: UIImageView!
    private var backBackgroundView: UIView!
}

extension MapViewController: MGLMapViewDelegate {
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        if annotation.isKind(of: MapAnnotation.self) && (annotation as! MapAnnotation).type == "friend" {
            let view = FriendAnnotationView(reuseIdentifier: "friendAnnotation", friend: (annotation as! MapAnnotation).friend)
            view.rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [weak self] _ in
                    self?.generator.impactOccurred()
                    view.selectAnimation()
                    self?.listener?.tappedOnFriendAnnotation(friend: (annotation as! MapAnnotation).friend)
                })
                .disposed(by: disposeBag)
            return view
        }

        
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return false
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
        // Add a MGLFillExtrusionStyleLayer.
        addFillExtrusionLayer(style: style)

        // Create an MGLLight object.
        let light = MGLLight()

        // Create an MGLSphericalPosition and set the radial, azimuthal, and polar values.
        // Radial : Distance from the center of the base of an object to its light. Takes a CGFloat.
        // Azimuthal : Position of the light relative to its anchor. Takes a CLLocationDirection.
        // Polar : The height of the light. Takes a CLLocationDirection.
        let position = MGLSphericalPositionMake(10, 0, 80)
        light.position = NSExpression(forConstantValue: NSValue(mglSphericalPosition: position))

        // Set the light anchor to the map and add the light object to the map view's style. The light anchor can be the viewport (or rotates with the viewport) or the map (rotates with the map). To make the viewport the anchor, replace `map` with `viewport`.
        light.anchor = NSExpression(forConstantValue: "map")
        style.light = light
    }
    
    func addFillExtrusionLayer(style: MGLStyle) {
        // Access the Mapbox Streets source and use it to create a `MGLFillExtrusionStyleLayer`. The source identifier is `composite`. Use the `sources` property on a style to verify source identifiers.
        let source = style.source(withIdentifier: "composite")!
        let layer = MGLFillExtrusionStyleLayer(identifier: "extrusion-layer", source: source)
        layer.sourceLayerIdentifier = "building"
        layer.fillExtrusionBase = NSExpression(forKeyPath: "min_height")
        layer.fillExtrusionHeight = NSExpression(forKeyPath: "height")
        layer.fillExtrusionOpacity = NSExpression(forConstantValue: 0.2)
        layer.fillExtrusionColor = NSExpression(forConstantValue: UIColor(red: 15/255, green: 16/255, blue: 18/255, alpha: 1.0))
        
        // Access the map's layer with the identifier "poi-scalerank3" and insert the fill extrusion layer below it.
        if let symbolLayer = style.layer(withIdentifier: "poi-scalerank3") {
            style.insertLayer(layer, below: symbolLayer)
        } else {
            style.addLayer(layer)
        }
    }
}


extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let mostRecentLocation = locations.last else {
            return
        }
        
        if self.location == nil {
            listener?.updateLocation(coordinate: mostRecentLocation.coordinate)
            self.location = mostRecentLocation
        }
    }
}

extension CLLocationCoordinate2D {
    //distance in meters, as explained in CLLoactionDistance definition
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let destination=CLLocation(latitude:from.latitude,longitude:from.longitude)
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: destination)
    }
}
