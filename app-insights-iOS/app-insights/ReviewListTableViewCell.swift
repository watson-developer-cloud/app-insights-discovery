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

class ReviewListTableViewCell: UITableViewCell {
    
    public var tableView: UITableView?
    
    static let kCellIdentifier = "ReviewListTableViewCell"
    
    @IBOutlet var reviewTitleText: UILabel!
    
    @IBOutlet var starStackView: UIStackView!
    @IBOutlet var starImage1: UIImageView!
    @IBOutlet var starImage2: UIImageView!
    @IBOutlet var starImage3: UIImageView!
    @IBOutlet var starImage4: UIImageView!
    @IBOutlet var starImage5: UIImageView!
    
    @IBOutlet var dateText: UILabel!
    @IBOutlet var reviewText: UILabel!
    @IBOutlet var readMoreButton: UIButton!
    
    // View seperating each review from each other.
    @IBOutlet var borderView: UIView!
    
    // Expand review text when button is pressed
    @IBAction func readMoreButtonPressed(_ sender: Any) {
        // Hide button upon expanding cell.
        self.reviewContainer.expanded = true
        
        // Run on main thread 
        DispatchQueue.main.async { [weak self] in
            self?.tableView?.beginUpdates()
            self?.readMoreButton.isHidden = true
            self?.reviewText.numberOfLines = 0
            self?.tableView?.endUpdates()
        }
    }
    
    // Constraint to adjust the height of the label.
    @IBOutlet var reviewLabelHeightConstraint: NSLayoutConstraint!
    
    // Model
    fileprivate var reviewContainer: ReviewContainerWrapper! {
        didSet {

            let review = reviewContainer.review
            
            self.reviewTitleText.text = review.title
            Utils.setUpStarStackView(numberOfStars: review.rating, starStackView: starStackView)
            dateText.text = review.date
            
            self.readMoreButton.isHidden = reviewContainer.expanded

            if self.readMoreButton.isHidden == true {
                reviewText.numberOfLines = 0
            } else {
                reviewText.numberOfLines = 4
            }
            reviewText.text = review.review
            
            reviewTitleText.font = UIFont.regularSFNSDisplay(size: 18)
            reviewTitleText.textColor = UIColor.white
            
            dateText.font = UIFont.regularSFNSDisplay(size: 11)
            dateText.textColor = UIColor.init(hex:"FFFFFF", alpha: 0.7)
            
            reviewText.font = UIFont.regularSFNSDisplay(size: 12)
            reviewText.addTextSpacing(spacing: 0.2)
            reviewText.textColor = UIColor.init(hex:"FFFFFF", alpha: 0.7)
            
            self.backgroundColor = UIColor.customBackgroundColor()
        }
    }
}

// MARK: Lifecycle
extension ReviewListTableViewCell {
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
extension ReviewListTableViewCell {
    
    // Set the model to update UI
    func setModel(reviewContainerWrapper:ReviewContainerWrapper) {
        self.reviewContainer = reviewContainerWrapper
    }
    
}
