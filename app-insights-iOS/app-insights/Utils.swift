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

import Foundation
import UIKit

struct Utils {
    /**
     Method sets up a startStackView with the number of stars defined by the numberOfStars parameter
     
     - parameter numberOfStars: Double
     - parameter starStackView: UIStackView
     */
    static func setUpStarStackView(numberOfStars : Double, starStackView : UIStackView){
        let floorStars = floor(numberOfStars)
        
        let remainder = numberOfStars - floorStars
        
        for (index, element) in starStackView.subviews.enumerated() {
            if let elem = element as? UIImageView {
                if(index < Int(floorStars)){
                    elem.image = UIImage(named: "Star")
                }
                else if(remainder > 0 && index == Int(floorStars)){
                    elem.image = UIImage(named: "Star_half")
                }
                else{
                    elem.image = UIImage(named: "Star_empty")
                }
            } else {
                break
            }
        }
    }
    
    // Convert sentiment value to letter grade.
    ///
    /// - Parameter sentiment: Sentiment value returned by Discovery service.
    /// - Returns: Returns letter grade.
    static func convertSentimentToLetterScore(sentiment: Double) -> Grade {
        var grade = Grade.None
        if (0.6 < sentiment && sentiment <= 1) { grade = Grade.A }
        if (0.2 < sentiment && sentiment <= 0.6) { grade = Grade.B }
        if (-0.2 < sentiment && sentiment <= 0.2) { grade = Grade.C }
        if (-0.6 < sentiment && sentiment <= -0.2) { grade = Grade.D }
        if (-1 <= sentiment && sentiment <= -0.6) { grade = Grade.F }
        return grade
    }
    
    /**
     Set up a dark navigation bar.
     - paramater viewController: UIViewController to change the navigation bar of.
     - paramater title: String to set the title of the view.
     */
    static func setupDarkNavBar(viewController: UIViewController, title: String) {
        
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        /// Configure title.
        
        if let navController = viewController.navigationController {
            /// Make the background transluscent and content a navy blue.
            navController.navigationBar.isTranslucent = false
            navController.navigationBar.barTintColor = UIColor.customNavBarColor()
        }
        setupNavigationTitleLabel(viewController: viewController, title: title, spacing: 1.0)
    }
    
    /** Define title's font name, spacing and color. */
    static fileprivate func setupNavigationTitleLabel(viewController: UIViewController, title: String, spacing: CGFloat) {
        
        let titleLabel = UILabel()
        let attributes: [String: Any] = [NSFontAttributeName: UIFont.boldSFNSDisplay(size: 17)!, NSForegroundColorAttributeName: UIColor.white, NSKernAttributeName : spacing]
        titleLabel.attributedText = NSAttributedString(string: title, attributes: attributes)
        
        titleLabel.sizeToFit()
        
        viewController.navigationController!.navigationBar.topItem!.titleView = titleLabel
        
    }
    
    static func getCurrentViewController() -> UIViewController? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let currentViewController = appDelegate.window?.rootViewController
        
        return currentViewController
    }
    
    static func getStoryboard(withName name: String) -> UIStoryboard {
        let storyboard = UIStoryboard.init(name: name, bundle: nil)
        return storyboard
    }
}
