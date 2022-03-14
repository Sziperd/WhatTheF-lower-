//
//  ViewController.swift
//  WhatTheF(lower)
//
//  Created by Patryk Piwowarczyk on 11/03/2022.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import ColorThiefSwift
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var label: UILabel!
    
    let wikipediaURL = "https://en.wikipedia.org/w/api.php"
    
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        // Do any additional setup after loading the view.
    }

    
    func requestInfo(flowerName: String){
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop"   : "extracts",
            "exintro": "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : "",
            "redirects" : "1",


        ]
        AF.request(wikipediaURL, method: .get, parameters: parameters).responseJSON { (response) in
        switch response.result {
        case .success(let value):

        print("got the wikipedia info")
        print(response.result)

        let flowerJSON: JSON = JSON(value)

        let pageid = flowerJSON["query"]["pageids"][0].stringValue

        let flowerDescription = flowerJSON["query"]["pages"][pageid]["extract"].stringValue

        print(flowerDescription)

        self.label.text = flowerDescription

        case .failure:
        print("did not get the wikipedia info")


        }
        }
        
     
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        
        present(imagePicker, animated: true, completion: nil)
        
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        self.imageView.image = userPickedImage
            
            guard  let ciimage = CIImage(image: userPickedImage) else{
                fatalError()
            }
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        
        
    }
    
    func detect(image: CIImage){
        
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else{
            fatalError()
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else{
                fatalError()
            }
            
            
            
            
            if let firstResult = results.first{
                print(results)
                self.navigationItem.title =  firstResult.identifier
                self.requestInfo(flowerName: firstResult.identifier)
               
            }
            
            
            
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        
        do {
        try handler.perform([request])
        }catch {
            print(error)
        }
    }
    
}

