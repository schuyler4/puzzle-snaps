//
//  PuzzleController.swift
//  puzzle-snaps
//
//  Created by Marek Newton on 2/3/17.
//  Copyright © 2017 Marek Newton. All rights reserved.
//

import UIKit

extension UIImage {
    
    func split() -> Array<UIImage> {
        let widthThird = CGFloat(self.size.width / 3)
        let heightThird = CGFloat(self.size.height / 3)
    
        var images = [UIImage]()
        
        for i in 1...8 {
            var rectX = CGFloat()
            var rectY = CGFloat()
            
            if i == 1 || i == 4 || i == 7{
                rectX = CGFloat(widthThird)
            } else if i == 3 || i == 6 {
                rectX = 0
            } else {
                rectX = widthThird * CGFloat(2)
            }
            
            if i == 1 || i == 2 {
                rectY = 0
            } else if i == 3 || i == 4 || i == 5  {
                rectY = CGFloat(heightThird)
            } else {
                rectY = heightThird * 2
            }
            
            let rect = CGRect(x: rectX, y: rectY, width: widthThird, height:
                heightThird)
            let imageRect = self.cgImage!.cropping(to: rect)
            let image = UIImage(cgImage: imageRect!, scale: self.scale,
                                orientation: self.imageOrientation)
            images.append(image)
        }
        
        return images
    }
}

extension Array {
    func findButton(element: UIButton) -> Int? {
        for(i, e) in enumerated() {
            if let button = e as? UIButton {
                if button == element {
                    return i
                }
            }
        }
        
        return nil
    }
    
    func findInt(element: Int) -> Int? {
        for(i, e) in enumerated() {
            if let int = e as? Int {
                if int == element {
                    return i
                }
            }
        }
        
        return nil
    }
}

class PuzzleController: UIViewController {
    
    var image: UIImage = UIImage()
    
    @IBOutlet var imageButtons: [Any]!
    
    var imageViews = [UIImageView]()
    var positions = Array<Int>()
    var blankPostion = Dictionary<String, CGFloat>()
    var scrabling = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageButtons.insert(contentsOf: [0], at: 0)
        
        for i in 0...imageButtons.count - 1 {
            if let btn = imageButtons[i] as? UIButton {
                print(image.split()[i - 1])
                btn.setBackgroundImage(image.split()[i - 1], for: .normal)
                btn.setTitle("", for: .normal)
            }
        }
        
        for button in imageButtons {
            if let btn = button as? UIButton {
                let downGesture = UISwipeGestureRecognizer(target: self, action:
                                    #selector(self.imageButtonDown(_:)))
                downGesture.direction = .down
        
                let upGesture = UISwipeGestureRecognizer(target: self, action:
                                #selector(self.imageButtonDown(_:)))
                upGesture.direction = .up
        
                let rightGesture = UISwipeGestureRecognizer(target: self,
                                action: #selector(self.imageButtonDown(_:)))
                rightGesture.direction = .right
        
                let leftGesture = UISwipeGestureRecognizer(target: self,
                                action: #selector(self.imageButtonDown(_:)))
                leftGesture.direction = .left

        
                btn.addGestureRecognizer(downGesture)
                btn.addGestureRecognizer(upGesture)
                btn.addGestureRecognizer(rightGesture)
                btn.addGestureRecognizer(leftGesture)
            }
        }
    }
    
    @IBAction func scrambleButtonClicked(_ sender: Any) {
        scrabling = true
        
        func randomInt(min: Int, max:Int) -> Int {
            return min + Int(arc4random_uniform(UInt32(max - min + 1)))
        }
        
        let rounds = randomInt(min: 30, max: 50)
        
        var blankX = CGFloat(142 - 91 - 8)
        var blankY = CGFloat(284 - 87 - 8)
        
        for _ in 0...rounds {
            var possibleSwitch = [Int]()
            let blankIndex = imageButtons.findInt(element: 0)

            if imageButtons.indices.contains(blankIndex! - 1) {
                possibleSwitch.append(blankIndex! - 1)
            }
            
            if imageButtons.indices.contains(blankIndex! + 1) {
                possibleSwitch.append(blankIndex! + 1)
            }
            
            if imageButtons.indices.contains(blankIndex! - 3) {
                possibleSwitch.append(blankIndex! - 3)
            }
            
            if imageButtons.indices.contains(blankIndex! + 3) {
                possibleSwitch.append(blankIndex! + 3)
            }

            let switchIndex = possibleSwitch[Int(arc4random_uniform(
                UInt32(possibleSwitch.count)))]
            swap(&imageButtons[switchIndex], &imageButtons[blankIndex!])
            let beforeX = (imageButtons[switchIndex] as! UIButton).frame.origin.x
            let beforeY = (imageButtons[switchIndex] as! UIButton).frame.origin.y
            (imageButtons[switchIndex] as! UIButton).frame.origin.x = CGFloat(blankX)
            (imageButtons[switchIndex] as! UIButton).frame.origin.y = CGFloat(blankY)
            blankX = beforeX
            blankY = beforeY
            
            print(blankX)
            print(blankY)
            print(imageButtons[switchIndex])
        }
       
    }
    
    func imageButtonDown(_ gesture: UIGestureRecognizer) {
        
        let blankIndex = imageButtons.findInt(element: 0)
        let buttonIndex = imageButtons.findButton(element: gesture.view as! UIButton)
        
    
        let width = gesture.view?.frame.width
        let height = gesture.view?.frame.height
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if swipeGesture.direction == UISwipeGestureRecognizerDirection.right
                && buttonIndex! + 1 == blankIndex! {
                gesture.view?.frame.origin.x += width! + 8
                swap(&imageButtons[buttonIndex!], &imageButtons[blankIndex!])
            } else if swipeGesture.direction == UISwipeGestureRecognizerDirection.down
                && buttonIndex! + 3 == blankIndex! {
                gesture.view?.frame.origin.y += height! + 8
                swap(&imageButtons[buttonIndex!], &imageButtons[blankIndex!])
            } else if swipeGesture.direction == UISwipeGestureRecognizerDirection.left
                && buttonIndex! - 1 == blankIndex {
                gesture.view?.frame.origin.x -= width! + 8
                swap(&imageButtons[buttonIndex!], &imageButtons[blankIndex!])
            } else if swipeGesture.direction == UISwipeGestureRecognizerDirection.up
                && buttonIndex! - 3 == blankIndex! {
                gesture.view?.frame.origin.y -= height! + 8
                swap(&imageButtons[buttonIndex!], &imageButtons[blankIndex!])
            }
                
        }
    }

}

