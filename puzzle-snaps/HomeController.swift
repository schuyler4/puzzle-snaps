//
//  HomeController.swift
//  puzzle-snaps
//
//  Created by Marek Newton on 2/2/17.
//  Copyright © 2017 Marek Newton. All rights reserved.
//

import UIKit

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
        let isExist = FileManager.default.fileExists(atPath: imagesDirectoryPath,
                                                     isDirectory: &objcBool)
        
        if isExist == false{
            do{
                try FileManager.default.createDirectory(atPath:
                    imagesDirectoryPath, withIntermediateDirectories: true,
                                                        attributes: nil)
            }catch{
                print("Something went wrong while creating a new folder")
            }
        }
        
        images = loadImages()
    }
    
    var pickedImage: UIImage = UIImage()

    @IBAction func newButtonOnCLick(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.camera) {
            let imagePicker: UIImagePickerController = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            images = loadImages()
            tableView.reloadData()
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert: UIAlertController = UIAlertController(title:
                "Camera Not Found", message: "your camera was not found",
                                    preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        var imagePath: String = NSDate().description
        imagePath = imagePath.replacingOccurrences(of: " ", with: "")
        imagePath = imagesDirectoryPath.appending("/\(imagePath).png")
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let data: Data? = UIImagePNGRepresentation(pickedImage)
            FileManager.default.createFile(atPath: imagePath, contents: data,
                                                                attributes: nil)
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "puzzleView") as! PuzzleController
        vc.image = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        self.present(vc, animated: true, completion: nil)
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
                    let image: UIImage! = UIImage(data: data!)
                    theImages.append(image!)
                }

            }
            
            return theImages
        } catch {
            print("there was an error and nothing to do about it")
            return []
        }
    }
    
    /*override func tableView(_ tableView: UITableView, numberOfRowsInSection
        section: Int) -> Int {
        return images.count
    }*/
    
    /*override func tableView(_ tableView: UITableView, cellForRowAt indexPath:
        IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        print(cell)
        
        let image = images[indexPath.row] as UIImage
        print(image)
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 10, y: 10, width: image.size.width,
                                 height: image.size.height)
        cell?.addSubview(imageView)
        return cell!
    }*/
}

