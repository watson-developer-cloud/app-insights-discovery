/**
 * Copyright IBM Corporation 2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import UIKit

extension UIColor {
    
    class func customYellowColor() -> UIColor { return UIColor.init(hex: "ffc600") }
    
    class func customPinkColor() -> UIColor { return UIColor.init(hex: "ff6477") }
    
    class func customSickGreen() -> UIColor { return UIColor.init(hex: "9fca3a")}
    
    class func customBackgroundColor() -> UIColor { return UIColor.init(hex: "1d2731") }
    
    class func customNavBarColor() -> UIColor { return UIColor.init(hex: "13191e") }
    
    class func customBlueColor() -> UIColor { return UIColor.init(hex: "007AFF") }
    
    class func customRedColor() -> UIColor { return UIColor.init(hex: "D0021B") }
    
    class func customGrayColor() -> UIColor { return UIColor.init(hex: "9b9b9b") }
    
    class func customGraphBackgroundColor() -> UIColor { return UIColor.init(hex: "313a43") }
    
    class func customWhiteOpacityHalfColor() -> UIColor { return UIColor.init(hex: "FFFFFF", alpha: 0.5) }
    
    class func customWhiteOpacityTenColor() -> UIColor { return UIColor.init(hex: "FFFFFF", alpha: 0.1) }
    
    /**
     Method called upon init that accepts a HEX string and creates a UIColor.
     
     - parameter hex:   String
     - parameter alpha: CGFloat
     
     - returns: UIColor
     */
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        
        var hexString = ""
        
        if hex.hasPrefix("#") {
            let nsHex = hex as NSString
            hexString = nsHex.substring(from: 1)
            
        } else {
            hexString = hex
        }
        
        let scanner = Scanner(string: hexString)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexInt64(&hexValue) {
            switch (hexString.characters.count) {
            case 3:
                red = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                blue = CGFloat(hexValue & 0x00F)              / 15.0
            case 6:
                red = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                blue = CGFloat(hexValue & 0x0000FF)           / 255.0
            default:
                print("Invalid HEX string, number of characters after '#' should be either 3, 6")
            }
        } else {
            //MQALogger.log("Scan hex error")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
}
