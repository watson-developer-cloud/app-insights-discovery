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

class InformationViewController: UIViewController {
    
    @IBOutlet var sentimentTitleLabel: UILabel!
    @IBOutlet var sentimentDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Create title label.
        createTitleLabel()
        
        // Show navigation bar once done loading.
        self.navigationController?.isNavigationBarHidden = false
        
        // Change background color.
        self.view.backgroundColor = UIColor.customBackgroundColor()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Hide navigation bar when changing screens.
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Private
extension InformationViewController {
    fileprivate func createTitleLabel() {
        let titleLabel = UILabel()
        
        let attributes: NSDictionary = [
            NSFontAttributeName:UIFont.boldSFNSDisplay(size: 17)!,
            NSForegroundColorAttributeName:UIColor.white,
            NSKernAttributeName:CGFloat(1.0)
        ]
        
        let attributedTitle = NSAttributedString(string: "INSIGHTS", attributes: attributes as? [String : AnyObject])
        
        titleLabel.attributedText = attributedTitle
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        
        self.navigationItem.leftBarButtonItem = BackBarButtonItem()
        
        
        
    }
}

// MARK: - Navigation
extension InformationViewController {
    // MARK: Navigation
    @objc fileprivate func goBack() {
        _  = navigationController?.popViewController(animated: true)
    }
}
