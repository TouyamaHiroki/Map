//
//  RecordViewController.swift
//  map5
//
//  Created by 藤山裕輝 on 2019/01/17.
//  Copyright © 2019 藤山裕輝. All rights reserved.
//

import UIKit
import CoreLocation
import AssetsLibrary

class RecordViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UITextViewDelegate {
    
    var locationManager: CLLocationManager!
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    
    
    @IBOutlet weak var pictureImage: UIImageView!
    var image: UIImage!
    
    @IBOutlet weak var memoText: UITextView!
    
    //メモを保存するためのからの配列の生成
    var memoArray = [String]()
    
    var MEMO = [String]()
    
    //経度を保存する配列
    var longitudeArray = [Double]()
    
    //緯度を保存する配列
    var latitudeArray = [Double]()
    
    
    //写真のPathを保存する配列
    var picturePathArray = [String]()
    
    //NSUserDefaultsのインスタンス生成
    var userDefaults = UserDefaults.standard
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        pictureImage.image = self.image
        setupLocationManager()
        memoText.delegate = self
        
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        locationManager.requestWhenInUseAuthorization()
        
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations
        locations: [CLLocation])
    {
        let location = locations.first!
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        print("latitude: \(latitude)\nlongitude: \(longitude)")
        
    }
    

    @IBAction func TakePicture(_ sender: Any) {
        
        //UIImagePickerControllerのインスタンスを作成
        let imagePickerController = UIImagePickerController()
        //SourceTypeにCameraを設定
        imagePickerController.sourceType = .camera
        //Delegate設置
        imagePickerController.delegate = self
        //モーダルビューで表示
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    //写真から
    //撮影が終わった時に呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
        //撮影した写真を配置したPictureImageに渡す
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        self.pictureImage.image = image
        
        //ライブラリに撮った写真を保存する
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        
        //モーダルビューを閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを隠す
        textField.resignFirstResponder()
        return true
    }
    
    
        
    
    @IBAction func addPin(_ sender: Any) {
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
        
        //画像の経度を配列に保存
        //longitudeArray = UserDefaults.standard.array(forKey: "LONGITUDE") as! [Double]
        longitudeArray.append(longitude)
        userDefaults.set(longitudeArray, forKey: "LONGITUDE")
        //画像の緯度を配列に保存
        //latitudeArray = UserDefaults.standard.array(forKey: "LATITUDE") as! [Double]
        latitudeArray.append(latitude)
        userDefaults.set(latitudeArray, forKey: "LATITUDE")
        
        //memoArray = UserDefaults.standard.array(forKey: "MEMO") as! [String]
        memoArray.append(memoText.text)
        //"MEMO"というキーで配列を保存
        userDefaults.set(memoArray, forKey: "MEMO")
        
        //"PATH"というキーで配列を保存
        userDefaults.set(picturePathArray, forKey: "PATH")
        
       
    }
    
    
    
}
