//
//  MeMe.swift
//  MeMeGenerator
//
//  Created by Janaki Burugula on Sep/21/2015.
//  Copyright (c) 2015 janaki. All rights reserved.
//

import Foundation
import UIKit

/*
  Structire to store MeMe images. It stores Top ,Bottom texts,original image and MeMed image
*/

struct Meme {
    var TopText:String?
    var BottomText:String?
    var originalImage:UIImage?
    var memedImage:UIImage!
}
