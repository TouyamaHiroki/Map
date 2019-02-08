//
//  ViewController.swift
//  map5
//
//  Created by 藤山裕輝 on 2019/01/16.
//  Copyright © 2019 藤山裕輝. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Foundation

class ViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate, CLLocationManagerDelegate {
    
    var locationManager:CLLocationManager!
    var annotationArray: [MKAnnotation] = []
    
    var memoArray = [String]()
    var latitudeArray = [Double]()
    var longitudeArray = [Double]()
    
    //let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 現在地を拡大して表示する
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let coordinate = locations.last?.coordinate {
                // 現在地を拡大して表示する
                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                dispMap.region = region
            }
        }

        dispMap.delegate = self
        //保存した配列から情報を取得してピンを複数さす(forループ)
       //. CLLocationCoordinate2DMake(longitudeArray[0], latitudeArray[0])

        inputText.delegate = self
        
        
        
        // デフォルト値
        //userDefaults.register(defaults: ["MEMO": "default"])
        //saveExist(name: "MEMO", array: memoArray)
        if UserDefaults.standard.object(forKey: "MEMO") != nil
        {
            memoArray = UserDefaults.standard.array(forKey: "MEMO") as! [String]
        }
        if UserDefaults.standard.object(forKey: "LATITUDE") != nil
        {
            latitudeArray = UserDefaults.standard.array(forKey: "LATITUDE") as! [Double]
        }
        if UserDefaults.standard.object(forKey: "LONGITUDE") != nil
        {
            longitudeArray = UserDefaults.standard.array(forKey: "LONGITUDE") as! [Double]
        }
        
        
    }
    
   

    @IBOutlet weak var inputText: UITextField!
    
    @IBOutlet weak var dispMap: MKMapView!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //キーボードを閉じる
        textField.resignFirstResponder()
        //入力された文字を取り出す
        if let searchKey = textField.text {
            //入力された文字をデバッグエリアに表示
            print(searchKey)
            
            //CLGeocorderインスタンスを取得
            let geocorder = CLGeocoder()
            
            //入力された文字から位置情報を取得
            geocorder.geocodeAddressString(searchKey, completionHandler: { (placemarks, error) in
                
                //位置情報が存在する場合はunwrapPlacemarksに取り出す
                if let unwarpPlacemark = placemarks {
                    
                    //1件目の情報を取り出す
                    if let firstPlacemark = unwarpPlacemark.first {
                        
                        //位置情報を取り出す
                        if let location = firstPlacemark.location {
                            
                            //位置情報から緯度経度をtargetCoordinateに取り出す
                            let targetCoordinate = location.coordinate
                            
                            //緯度経度をデバッグエリアに表示
                            print(targetCoordinate)
                            
                            //MKPointAnnotationインスタンスを取得し、ピンを生成
                            let pin = MKPointAnnotation()
                            
                            //ピンの置く場所に緯度経度を設定
                            pin.coordinate = targetCoordinate
                            
                            //ピンのタイトル設定
                            pin.title = searchKey
                            
                            //ピンを地図に置く
                            self.dispMap.addAnnotation(pin)
                            
                            //緯度経度を中心に半径500メートルの範囲を表示
                            self.dispMap.region = MKCoordinateRegion(center: targetCoordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
                        }
                    }
                }
            })
        }
        //デフォルト操作を行うのでtrueを返す
        return true
    }
    
    
    //右下のボタンでマップ切り替え
    @IBAction func changeMapButtonAction(_ sender: Any) {
        if dispMap.mapType == .standard {
            dispMap.mapType = .satellite
        } else if dispMap.mapType == .satellite {
            dispMap.mapType = .satelliteFlyover
        } else {
        dispMap.mapType = .standard
    }
    }
        
    
    @IBAction func PictureButtonAction(_ sender: Any) {
        //カメラが利用可能かチェックする
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("カメラは利用できます")

        } else {
            print("カメラは利用できません")
            print(longitudeArray)
            print(latitudeArray)
            
        }
    }
    
    var identifier: String?
    
    @IBAction func AP(_ sender: Any) {
        
        var loop: [Int] = [0]
        for loop in 0...memoArray.count-1
        {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(latitudeArray[loop],longitudeArray[loop])
            annotationArray.append(annotation)
            annotation.title = "\(memoArray[loop])"
            annotation.subtitle = "\(latitudeArray[loop]), \(longitudeArray[loop])"
            loop + 1
            self.dispMap.addAnnotations(annotationArray)
        }
        
        
        //let annotation = MKPointAnnotation()
        //annotation.coordinate = CLLocationCoordinate2DMake(32.80479834244867,130.76562968194332)
        //annotationArray.append(annotation)
        //self.dispMap.addAnnotations(annotationArray)
        //self.dispMap.removeAnnotations(annotationArray)
        
        func dispMap(_ dispMap: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {   // --------（2）
            // 吹き出しを取得
            var annotationView = dispMap.dequeueReusableAnnotationView(withIdentifier: self.identifier!)
            
            //起き出しオブジェクトが空の場合は生成
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
            } else {
                annotationView!.annotation = annotation
            }
            return annotationView
        }
    }

    
    //ピンをカスタム
    /*func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        // Better to make this class property
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "yourImage")
        }
        
        return annotationView
    }*/
   
}

