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

class KeywordListTableViewCell: UITableViewCell {

    static let kCellIdentifier = "KeywordListTableViewCell"
    
    @IBOutlet var positiveMentionsLabel: UILabel!
    @IBOutlet var neutralMentionsLabel: UILabel!
    @IBOutlet var negativeMentionsLabel: UILabel!
    @IBOutlet var keywordText: UILabel!
    @IBOutlet var numberOfPositiveSentiment: UILabel!
    @IBOutlet var numberOfNeutralSentiment: UILabel!
    @IBOutlet var numberOfNegativeSentiment: UILabel!
    
    // Model 
    fileprivate var keyword: Keyword! {
        didSet {
            // Run on main thread
            DispatchQueue.main.async { [weak self] in
                self?.updateUI()
            }
        }
    }
}

// MARK: Lifecycle
extension KeywordListTableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

// MARK: API
extension KeywordListTableViewCell {
    
    // Set the model to update UI
    func setModel(keyword:Keyword) {
        self.keyword = keyword
    }
    
}

// MARK: Private
extension KeywordListTableViewCell {
    
    // Update the UI with model values
    fileprivate func updateUI() {
        self.keywordText.text = keyword.keyword
        self.keywordText.textColor = UIColor.white
        keywordText.font = UIFont.regularSFNSDisplay(size: 18)
        keywordText.addTextSpacing(spacing: 0.1)
        
        numberOfPositiveSentiment.text = String(keyword.positiveSentiment.matchingResults)
        numberOfPositiveSentiment.textColor = UIColor.customSickGreen()
        numberOfPositiveSentiment.font = UIFont.boldSFNSDisplay(size: 20)
        numberOfPositiveSentiment.addTextSpacing(spacing: 0.1)
        
        numberOfNeutralSentiment.text = String(keyword.neutralSentiment.matchingResults)
        numberOfNeutralSentiment.textColor = UIColor.init(hex:"FFFFFF", alpha: 0.7)
        numberOfNeutralSentiment.font = UIFont.boldSFNSDisplay(size: 20)
        numberOfNeutralSentiment.addTextSpacing(spacing: 0.1)
        
        numberOfNegativeSentiment.text = String(keyword.negativeSentiment.matchingResults)
        numberOfNegativeSentiment.textColor = UIColor.customRedColor()
        numberOfNegativeSentiment.font = UIFont.boldSFNSDisplay(size: 20)
        numberOfNegativeSentiment.addTextSpacing(spacing: 0.1)
        
        positiveMentionsLabel.textColor = UIColor.customSickGreen()
        positiveMentionsLabel.font = UIFont.regularSFNSDisplay(size: 11)
        positiveMentionsLabel.addTextSpacing(spacing: 0.1)

        neutralMentionsLabel.textColor = UIColor.init(hex:"FFFFFF", alpha: 0.7)
        neutralMentionsLabel.font = UIFont.regularSFNSDisplay(size: 11)
        neutralMentionsLabel.addTextSpacing(spacing: 0.1)
        
        negativeMentionsLabel.textColor = UIColor.customRedColor()
        negativeMentionsLabel.font = UIFont.regularSFNSDisplay(size: 11)
        negativeMentionsLabel.addTextSpacing(spacing: 0.1)
    }
}
