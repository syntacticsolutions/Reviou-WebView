//
//  ViewController.swift
//  RelateWebView
//
//  Created by Miguel Cabrera on 10/10/17.
//  Copyright © 2017 Miguel Cabrera. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController,
                        WKScriptMessageHandler,
                        UIImagePickerControllerDelegate,
                        UINavigationControllerDelegate {
    
    
    var webView: WKWebView?
    let userContentController = WKUserContentController()
    let picker = UIImagePickerController();
    
    func photoFromLibrary() {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    
    override func loadView() {
        super.loadView()
        
        
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        
        self.webView = WKWebView(frame: self.view.bounds, configuration: config)
        userContentController.add(self, name: "iOS")
        
        let url = URL(string:"https://relate.lavishweb.com/account")
        let request = URLRequest(url: url!)
        _ = webView?.load(request)
        
        self.view = self.webView
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
    }

    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        print(message);
        
        self.photoFromLibrary()
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let thumb = chosenImage.resized(toWidth: 200.0)
        
        let imageData:NSData = UIImagePNGRepresentation(thumb!)! as NSData
        
        let dataImage:String = imageData.base64EncodedString(options: .lineLength64Characters)
        
        let encodedString: String = dataImage.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
        
        webView?.evaluateJavaScript("window.settings.setImageBase64FromiOS('\(encodedString)');") { (result, error) in
            if error != nil {
                print(error!)
            } else {
                print(encodedString)
            }
        }
        dismiss(animated:true, completion: nil) //5
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    


}

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

