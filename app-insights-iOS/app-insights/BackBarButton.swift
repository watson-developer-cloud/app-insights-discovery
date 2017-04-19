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

class BackBarButtonItem: UIBarButtonItem {
    
    let backButton = UIButton()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
        
        setupBackIconButton()
    }
    
    @objc fileprivate func goBack() {
            if let currentVC = Utils.getCurrentViewController() as? UINavigationController {
                // Go back to previous view controller
                _ = currentVC.popViewController(animated: true)
            }
    }
    
    private func goBackButton() -> UIButton {
        backButton.setImage(UIImage(named: "Back_arrow"), for: .normal)
        backButton.addTarget(self, action: #selector(BackBarButtonItem.goBack), for: .touchUpInside)
        backButton.frame = CGRect(x: 13, y: 33.5, width: 22, height: 13.5)

        return backButton
    }
    
    private func setupBackIconButton() {
        self.customView = goBackButton()
    }
    
}
