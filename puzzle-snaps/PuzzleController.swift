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
    @IBOutlet var scrambleButton: UIButton!
    
    var positions: Array<Int>  = Array<Int>()
    var blankPostion :Dictionary<String, CGFloat> = Dictionary<String, CGFloat>()
    var scrambled: Bool = false
    var imageSpacing: CGFloat = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageButtons?.insert(contentsOf: [0], at: 0)
        
        if imageButtons != nil {
            for i in 0...imageButtons.count - 1 {
                if let btn = imageButtons[i] as? UIButton {
                    btn.setBackgroundImage(image.split()[i - 1], for: .normal)
                }
            }
            
            for button in imageButtons {
                if let btn = button as? UIButton {
                    let downGesture = UISwipeGestureRecognizer(target: self, action:
                        #selector(self.imageButtonSwiped(_:)))
                    downGesture.direction = .down
                    
                    let upGesture = UISwipeGestureRecognizer(target: self, action:
                        #selector(self.imageButtonSwiped(_:)))
                    upGesture.direction = .up
                    
                    let rightGesture = UISwipeGestureRecognizer(target: self,
                                    action: #selector(self.imageButtonSwiped(_:)))
                    rightGesture.direction = .right
                    
                    let leftGesture = UISwipeGestureRecognizer(target: self,
                                    action: #selector(self.imageButtonSwiped(_:)))
                    leftGesture.direction = .left
                    
                    
                    btn.addGestureRecognizer(downGesture)
                    btn.addGestureRecognizer(upGesture)
                    btn.addGestureRecognizer(rightGesture)
                    btn.addGestureRecognizer(leftGesture)
                    btn.setTitle("", for: .normal)
                }
            }
        }
    }
    
    func getPositionData() -> String {
        var data: Array<Array<String>> = []
        
        if imageButtons != nil {
            for button in imageButtons {
                if let imageBtn = button as? UIButton {
                    let o = imageBtn.frame.origin
                    data.append([String(describing: o.x), String(describing: o.y)])
                }
            }
        } else {
            return "none"
        }
    
        return String(describing: data)
    }
    
    @IBAction func scrambleButtonClicked(_ sender: Any) {
        
        func randomInt(min: Int, max:Int) -> Int {
            return min + Int(arc4random_uniform(UInt32(max - min + 1)))
        }
        
        let rounds = randomInt(min: 30, max: 50)
        
        for _ in 0...rounds {
            let firstIndex = randomInt(min: 0, max: imageButtons.count - 1)
            let secoundIndex = randomInt(min: 0, max: imageButtons.count - 1)
            
            let firstButton = imageButtons[firstIndex]
            let secoundButton = imageButtons[secoundIndex]
            
            if firstIndex != secoundIndex {
                if let button1 = firstButton as? UIButton {
                    if let button2 = secoundButton as? UIButton {
                        let firstPos: CGPoint = button1.frame.origin
                        let secoundPos: CGPoint = button2.frame.origin
                        
                        button1.frame.origin = secoundPos
                        button2.frame.origin = firstPos
                        swap(&imageButtons[firstIndex], &imageButtons[secoundIndex])
                    }
                }
            }
        }
        
        scrambled = true
        scrambleButton.isHidden = true
        print("got through")
    }
    
    func imageButtonSwiped(_ gesture: UIGestureRecognizer) {
        
        let blankIndex = imageButtons.findInt(element: 0)
        let buttonIndex = imageButtons.findButton(element: gesture.view as! UIButton)
    
        let width = gesture.view?.frame.width
        let height = gesture.view?.frame.height
        
        if scrambled {
            if let swipeGesture = gesture as? UISwipeGestureRecognizer {
                if swipeGesture.direction == UISwipeGestureRecognizerDirection.right
                    && buttonIndex! + 1 == blankIndex! {
                    gesture.view?.frame.origin.x += width! + imageSpacing
                    swap(&imageButtons[buttonIndex!], &imageButtons[blankIndex!])
                } else if swipeGesture.direction == UISwipeGestureRecognizerDirection.down
                    && buttonIndex! + 3 == blankIndex! {
                    gesture.view?.frame.origin.y += height! + imageSpacing
                    swap(&imageButtons[buttonIndex!], &imageButtons[blankIndex!])
                } else if swipeGesture.direction == UISwipeGestureRecognizerDirection.left
                    && buttonIndex! - 1 == blankIndex {
                    gesture.view?.frame.origin.x -= width! + imageSpacing
                    swap(&imageButtons[buttonIndex!], &imageButtons[blankIndex!])
                } else if swipeGesture.direction == UISwipeGestureRecognizerDirection.up
                    && buttonIndex! - 3 == blankIndex! {
                    gesture.view?.frame.origin.y -= height! + imageSpacing
                    swap(&imageButtons[buttonIndex!], &imageButtons[blankIndex!])
                }
                    
            }
        }
    }

}

