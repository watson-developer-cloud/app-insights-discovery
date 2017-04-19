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

class AppListTableViewCell: UITableViewCell {
    
    static let kButtonPressedNotificationName = "ViewMorePressed"
    static let kSentimentButtonPressedNotificationName = "SentimentPressed"
    static let kKeywordButtonPressedNotificationName = "KeywordPressed"
    static let kTurnaroundButtonPressedNotificationName = "TurnaroundPressed"
    static let kCellIdentifier = "AppListTableViewCell"
    
    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var appName: UILabel!
    @IBOutlet weak var appCategory: UILabel!

    
    @IBOutlet var starStackView: UIStackView!
    @IBOutlet var starImageView1: UIImageView!
    @IBOutlet var starImageView2: UIImageView!
    @IBOutlet var starImageView3: UIImageView!
    @IBOutlet var starImageView4: UIImageView!
    @IBOutlet var starImageView5: UIImageView!
    @IBOutlet var numberOfReviewsLabel: UILabel!
    
    @IBOutlet weak var viewMore: UIButton!
    
    @IBOutlet var sentimentScoreTitle: UILabel!
    @IBOutlet var sentimentScoreLabel: UILabel!

    @IBOutlet var topKeywordTitle: UILabel!
    @IBOutlet var topKeywordLabel: UILabel!
    
    @IBOutlet var turnaroundTitle: UILabel!
    @IBOutlet var turnaroundLabel: UILabel!
    
    // Model
    fileprivate var app:App! {
        didSet {
            // Run on main thread
            DispatchQueue.main.async { [weak self] in
                self?.updateUI()
            }
        }
    }
    
}

// MARK: Lifecycle
extension AppListTableViewCell {

    override func awakeFromNib() {
        self.setupButton()
        self.backgroundColor = UIColor.customBackgroundColor()
    }
    
}
// MARK: IBActions
extension AppListTableViewCell {
    
    // View More button pressed
    @IBAction func viewMorePressed(_ sender: UIButton) {
        // Send notification that button was pressed
        let notificationName = Notification.Name(AppListTableViewCell.kButtonPressedNotificationName)
        NotificationCenter.default.post(name: notificationName, object: self)
    }
    
    @IBAction func toSentimentButton(_ sender: Any) {
        let notificationName = Notification.Name(AppListTableViewCell.kSentimentButtonPressedNotificationName)
        NotificationCenter.default.post(name: notificationName, object:self)
        print ("sentiment button pressed")
    }
    
    @IBAction func toKeywordButton(_ sender: Any) {
        let notificationName = Notification.Name(AppListTableViewCell.kKeywordButtonPressedNotificationName)
        NotificationCenter.default.post(name: notificationName, object:self)
        print ("keyword button pressed")
        
    }
    
    @IBAction func toTurnaroundButton(_ sender: Any) {
        let notificationName = Notification.Name(AppListTableViewCell.kTurnaroundButtonPressedNotificationName)
        NotificationCenter.default.post(name: notificationName, object:self)
        print ("turnaround button pressed")
    }
}

// MARK: API
extension AppListTableViewCell {
    
    // Set the model to update UI
    func setModel(app:App) {
        self.app = app
    }
    
}

// MARK: Private
extension AppListTableViewCell {
    
    // Update the UI with model values
    fileprivate func updateUI() {
        loadimage()
        self.appName.text = app.name
        self.appCategory.text = app.category
        numberOfReviewsLabel.text = "(\(app.numberOfReviews))"
        turnaroundLabel.text = "\(app.numberOfTurnarounds)"
        topKeywordLabel.text = app.topKeyword
        sentimentScoreLabel.text = Utils.convertSentimentToLetterScore(sentiment: app.appSentimentValue).rawValue
        
        updateDiscoveryLabelFontFormat()
        updateAppInfoFontFormat()
    }
    
    fileprivate func updateAppInfoFontFormat() {
        appName.font = UIFont.regularSFNSDisplay(size: 16)
        appName.textColor = UIColor.white
        
        appCategory.font = UIFont.regularSFNSDisplay(size: 12)
        appCategory.addTextSpacing(spacing: 0.1)
        appCategory.textColor = UIColor(hex: "FFFFFF", alpha: 0.5)
        
        numberOfReviewsLabel.font = UIFont.regularSFNSDisplay(size: 8.5)
        numberOfReviewsLabel.textColor = UIColor.customGrayColor()
    }
    
    fileprivate func updateDiscoveryLabelFontFormat() {
        turnaroundTitle.font = UIFont.regularSFNSDisplay(size: 11)
        turnaroundTitle.addTextSpacing(spacing: 0.1)
        turnaroundTitle.textColor = UIColor(hex: "FFFFFF", alpha: 0.7)
        
        turnaroundLabel.font = UIFont.boldSFNSDisplay(size: 20)
        turnaroundLabel.addTextSpacing(spacing: 0.1)
        turnaroundLabel.textColor = UIColor(hex: "FFFFFF", alpha: 0.7)

        topKeywordTitle.font = UIFont.regularSFNSDisplay(size: 11)
        topKeywordTitle.addTextSpacing(spacing: 0.1)
        topKeywordTitle.textColor = UIColor(hex: "FFFFFF", alpha: 0.7)
        
        topKeywordLabel.font = UIFont.boldSFNSDisplay(size: 20)
        topKeywordLabel.addTextSpacing(spacing: 0.1)
        topKeywordLabel.textColor = UIColor(hex: "FFFFFF", alpha: 0.7)
        
        sentimentScoreTitle.font = UIFont.regularSFNSDisplay(size: 11)
        sentimentScoreTitle.addTextSpacing(spacing: 0.1)
        sentimentScoreTitle.textColor = UIColor(hex: "FFFFFF", alpha: 0.7)
        
        sentimentScoreLabel.font = UIFont.boldSFNSDisplay(size: 20)
        sentimentScoreLabel.addTextSpacing(spacing: 0.1)
        sentimentScoreLabel.textColor = UIColor(hex: "FFFFFF", alpha: 0.7)
    }
    
    // Add a border to "View More" button
    fileprivate func setupButton() {
        viewMore.layer.borderWidth = 2.0
        viewMore.layer.borderColor = self.tintColor.cgColor
    }
    
    // Asynchronously load the image
    fileprivate func loadimage() {
        let url = app.imageURL
        self.appIcon.isHidden = true
        Utils.setUpStarStackView(numberOfStars: app.rating, starStackView: starStackView)
        DispatchQueue.global(qos: .userInteractive).async {
            if let imageData = NSData(contentsOf: url) {
                DispatchQueue.main.async { [weak self] in
                    self?.appIcon?.image = UIImage(data: imageData as Data)
                    self?.appIcon?.isHidden = false
                }
            }
        }
    }
}

// MARK - IBActions

extension AppListTableViewCell {
    
}
