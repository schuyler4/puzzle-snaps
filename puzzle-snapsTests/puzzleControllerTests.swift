//
//  puzzleControllerTests.swift
//  puzzle-snaps
//
//  Created by Marek Newton on 2/5/17.
//  Copyright © 2017 Marek Newton. All rights reserved.
//

import XCTest
@testable import puzzle_snaps

class puzzleControllerTests: XCTestCase {
    
    var puzzleController: PuzzleController!
    
    override func setUp() {
        super.setUp()
        
        puzzleController = PuzzleController()
    }
    
    func testViewDidLoad() {
        puzzleController.viewDidLoad()
        
        if puzzleController.imageButtons != nil {
            
            for button in puzzleController.imageButtons {
                if let btn = button as? UIButton {
                    XCTAssert(btn.titleLabel?.text == "")
                    XCTAssert(btn.backgroundImage(for: UIControlState.normal) != nil)
                    XCTAssert(btn.gestureRecognizers != nil)
                } else if let num = button as? Int {
                    XCTAssert(num == 0)
                }
            }
        }
    }
    
    func testImageButtonDown() {
        if puzzleController.imageButtons != nil {
            if let button = puzzleController.imageButtons[1] as? UIButton {
                let startX = button.frame.origin.x
                let startY = button.frame.origin.y
                
                XCTAssert((button.gestureRecognizers?[0] != nil))
                
                puzzleController.imageButtonSwiped((button.gestureRecognizers?[0])!)
                XCTAssert(puzzleController.imageButtons.findInt(element: 0) == 1)
                XCTAssert(puzzleController.imageButtons.findButton(element: button) == 0)
                XCTAssert(button.frame.origin.x != startX)
                XCTAssert(button.frame.origin.y != startY)
            }
        }
    }
    
    func testScrambleButtonClicked() {
        if puzzleController.imageButtons != nil {
            if let button = puzzleController.imageButtons[1] as? UIButton {
                puzzleController.scrambleButtonClicked(button)
                XCTAssert(puzzleController.scrabling == true)
            }
        }
    }
}
