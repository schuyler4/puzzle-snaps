//
//  HomeController.swift
//  puzzle-snaps
//
//  Created by Marek Newton on 2/2/17.
//  Copyright © 2017 Marek Newton. All rights reserved.
//

import UIKit
import Darwin

extension UIImage {
    func fixOrientation() -> UIImage {
        
        guard let cgImage = cgImage else { return self }
        
        if imageOrientation == .up { return self }
        
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
            
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
            
        case .up, .upMirrored:
            break
        }
        
        switch imageOrientation {
            
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
            
        case .up, .down, .left, .right:
            break
        }
        
        if let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                               bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space:cgImage.colorSpace!,
                               bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
            
            ctx.concatenate(transform)
            
            switch imageOrientation {
                
            case .left, .leftMirrored, .right, .rightMirrored:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
                
            default:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }
            
            if let finalImage = ctx.makeImage() {
                return (UIImage(cgImage: finalImage))
            }
        }
        
       
        return self
    }
    
    func cropToSquare() -> UIImage? {
        let height = self.size.height
        let width = self.size.width
        
        var crop = CGFloat()
        
        if width > height {
            crop = height
        }
        
        if height > width {
            crop = width
        }
        
        let rect = CGRect(x: 0,  y: 0, width: crop, height: crop)
        let imageRect = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRect!, scale: self.scale,
                            orientation: self.imageOrientation)
        
        return image
    }
}

class HomeController: UITableViewController, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    var imagesDirectoryPath: String!
    var images: [UIImage]!
    var titles: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                        .userDomainMask, true)
        let documentDirectorPath:String = paths[0]
       
        imagesDirectoryPath = documentDirectorPath.appending("/ImagePicker")
        var objcBool:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: imagesDirectoryPath, isDirectory: &objcBool)
        
        if isExist == false{
                try? FileManager.default.createDirectory(atPath:
                    imagesDirectoryPath, withIntermediateDirectories: true,
                                                        attributes: nil)
        }
        
        images = loadImages()
        images.remove(at: 0)
    }
    
    var pickedImage: UIImage = UIImage()

    @IBAction func newButtonOnCLick(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.camera) {
            let imagePicker: UIImagePickerController = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert: UIAlertController = UIAlertController(title:
                "Camera Not Found", message: "your camera was not found",
                                    preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var imagePath: String = NSDate().description
        imagePath = imagePath.replacingOccurrences(of: " ", with: "")
        imagePath = imagesDirectoryPath.appending("/\(imagePath).png")
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let data: Data? = UIImagePNGRepresentation(pickedImage.fixOrientation().cropToSquare()!)
            FileManager.default.createFile(atPath: imagePath, contents: data,
                                                                attributes: nil)
            print("saved image")
        }
        
        self.dismiss(animated: true) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "puzzleView") as! PuzzleController
            vc.image = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
            self.images = self.loadImages()
            vc.image = self.images[self.images.count - 1]
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    func loadImages() -> Array<UIImage> {
        do {
            var theImages: Array<UIImage> = [UIImage()]
            if imagesDirectoryPath != nil {
                titles = try FileManager.default.contentsOfDirectory(atPath:
                                                            imagesDirectoryPath)
                
                for image in titles {
                    let data: Data? = FileManager.default.contents(atPath:
                        imagesDirectoryPath.appending("/\(image)"))
                    let image: UIImage! =  UIImage(data: data!)
                    theImages.append(image)
                }

            }
            
            return theImages
        } catch {
            print("there was an error and nothing to do about it")
            return []
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection
        section: Int) -> Int {
        return images.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        let image = images[indexPath.row]
        cell?.imageView?.image = image
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "puzzleView") as! PuzzleController
        vc.image = images[indexPath.row]
        self.present(vc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("recived memory warning")
    }
}

