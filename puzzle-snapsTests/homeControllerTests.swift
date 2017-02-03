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
    
    func testLoadImage() {
        let viewController = HomeController()
        XCTAssert(viewController.loadImages().count > 0)
    }
    
}
