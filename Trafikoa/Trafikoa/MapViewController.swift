//
//  MapViewController.swift
//  EuskoEvents
//
//  Created by Asier on 10/12/17.
//  Copyright © 2017 Asier. All rights reserved.
//

import UIKit

import MapKit
import SafariServices

import AEXML
import Alamofire

var eventos = [Evento]()

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    let regionRadius: CLLocationDistance = 100000

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self

        Alamofire.request("https://www.trafikoa.eus/servicios/IncidenciasTDT/IncidenciasTrafikoTDTGeo").responseData { res in

            if let data = res.data {

                let xml2 = String(data: data, encoding: .utf8) ?? "?"
                let xml = xml2.replacingOccurrences(of: "ISO-8859-1", with: "UTF-8", options: .literal, range: nil)

                var options = AEXMLOptions()
                options.parserSettings.shouldProcessNamespaces = false
                options.parserSettings.shouldReportNamespacePrefixes = false
                options.parserSettings.shouldResolveExternalEntities = false

                do {
                    let xmlDoc = try AEXMLDocument(xml: xml, options: options)

                    // prints the same XML structure as original
                    //print(xmlDoc.xml)

                    // prints cats, dogs
                    for child in xmlDoc.root.children {

                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let date = dateFormatter.date(from: child["fechahora_ini"].value ?? "?") ?? Date()

                        let evento = Evento(tipo: child["tipo"].value ?? "?",
                                            causa: child["causa"].value ?? "?",
                                            nivel: child["nivel"].value ?? "?",
                                            carretera: child["carretera"].value ?? "?",
                                            fechaInicio: date,
                                            latitud: Double(child["latitud"].value ?? "?") ?? 0.0,
                                            longitud: Double(child["longitud"].value ?? "?") ?? 0.0
                        )
                        eventos.append(evento)
                    }

                }
                catch {
                    print("\(error)")
                }

                for e in eventos {
                    if e.latitud != nil && e.longitud != nil {
                        let anotacion = Anotacion(evento: e)
                        self.mapView.addAnnotation(anotacion)
                    }
                }
            }
        }

        // Centrar el mapa
        let initialLocation = CLLocation(latitude: 43.1714635, longitude: -2.630595900000003)
        centerMapOnLocation(location: initialLocation)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class Anotacion: NSObject, MKAnnotation {

    let title: String? // MKAnnotation
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D // MKAnnotation
    let fecha: String
    var color: UIColor

    init(evento e: Evento) {

        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "dd/MM/yyyy HH:mm"

        self.title = "\(e.carretera) \(e.causa)"
        self.subtitle = "\(e.nivel)\n\(e.fechaInicio)"
        self.coordinate = CLLocationCoordinate2D(latitude: e.latitud!, longitude: e.longitud!)
        self.fecha = dateFmt.string(from: e.fechaInicio)

        switch e.nivel {
        case "Blanco":
            self.color = UIColor.lightGray
        case "Rojo":
            self.color = UIColor.red
        case "Amarillo":
            self.color = UIColor.orange
        case "Negro":
            self.color = UIColor.black
        case "Verde":
            self.color = UIColor.green
        default:
            self.color = UIColor.gray
        }

        if(e.nivel.contains("T:")) {
            self.color = UIColor.blue
        }

        super.init()
    }

}

extension UIViewController: MKMapViewDelegate {

    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard let annotation = annotation as? Anotacion else { return nil }

        let identifier = "marker"
        var view: MKMarkerAnnotationView

        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
        }

        view.markerTintColor = annotation.color

        return view
    }

    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

    }
}
