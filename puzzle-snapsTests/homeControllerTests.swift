//
//  homeControllerTests.swift
//  puzzle-snaps
//
//  Created by Marek Newton on 2/2/17.
//  Copyright © 2017 Marek Newton. All rights reserved.
//

import XCTest
import UIKit
@testable import puzzle_snaps

class homeControllerTests: XCTestCase {
    
    var homeController: HomeController!
    
    override func setUp() {
        super.setUp()
        
        homeController = HomeController()
    }
    
    func testViewDidLoad() {
        homeController.viewDidLoad()
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)
        let documentDirectorPath:String = paths[0]
        
        XCTAssert(homeController.imagesDirectoryPath == documentDirectorPath.appending("/ImagePicker"))
        XCTAssert(homeController.images.count > 0)
    }
    
    func testLoadImage() {
        XCTAssert(homeController.loadImages().count > 0)
    }
}
