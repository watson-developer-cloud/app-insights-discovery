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

class AppDetailsViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // Constants
    let kToInformationSegue = "toInformation"
    
    var containerToShow: Container = .sentiment
    
    // Containers
    @IBOutlet weak var sentimentContainer: UIView!
    @IBOutlet weak var turnaroundContainer: UIView!
    @IBOutlet weak var keywordsContainer: UIView!
    
    @IBOutlet var backBarButton: UIBarButtonItem!
    @IBOutlet var informationBarButton: UIBarButtonItem!
    
    @IBOutlet var appIcon: UIImageView!
    @IBOutlet var appName: UILabel!
    @IBOutlet var appCategory: UILabel!
    @IBOutlet var starStackView: UIStackView!
    @IBOutlet var starImage1: UIImageView!
    @IBOutlet var starImage2: UIImageView!
    @IBOutlet var starImage3: UIImageView!
    @IBOutlet var starImage4: UIImageView!
    @IBOutlet var starImage5: UIImageView!
    @IBOutlet var numberOfReviewsLabel: UILabel!
    
    @IBOutlet var navigationBar: UINavigationItem!
    @IBOutlet var sentimentView: UIView!
    @IBOutlet var sentimentScore: UILabel!
    
    var image: UIImage!
    var name: String?
    var category: String = ""
    var rating: Double?
    var numberOfReviews: Int?
    var descriptionDetail: String = ""
    var sentiment: Double?
    @IBAction func appSentimentButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: kToInformationSegue, sender: self)
    }
}

// MARK: Lifecycle
extension AppDetailsViewController {

    override func viewWillAppear(_ animated: Bool) {
        
        // Set up title
        createTitleLabel()

        // Show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        
        // Set background color
        self.view.backgroundColor = UIColor.customBackgroundColor()
        
        // Set actions for buttons
        backBarButton.target = self
        backBarButton.action = #selector(goBack)
        informationBarButton.target = self
        informationBarButton.action = #selector(goToInformation)
        
        onlyShowContainer(container: containerToShow, switchTab: true)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.customBackgroundColor()
        loadAppDetails()
    }

    // Setup controllers stored in Containers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case Segues.kReviews:
                if let vc = segue.destination as? OpportunityViewController, let name = self.name {
                    vc.setModel(appName: name)
                }
            case Segues.kKeywords:
                if let vc = segue.destination as? KeywordsTableViewController, let name = self.name {
                    vc.setModel(appName: name)
                    vc.setCategory(appCategory: category)
                }
            case Segues.kGraph:
                if let vc = segue.destination as? GraphViewController, let name = self.name {
                    vc.setModel(appName: name)
                }
            default:
                return
            }
        }
    }

}

// MARK: IBActions
extension AppDetailsViewController {
    
    @IBAction func segmentedControlClicked(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        switch index {
        case 0:
            print("Sentiment clicked!")
            containerToShow = .sentiment
        case 1:
            print("Keywords clicked!")
            containerToShow = .keywords
        case 2:
            print("Turnaround clicked!")
            containerToShow = .turnaround
        default:
            print("ERROR: Unrecognized tab clicked!")
            
        }
        
        onlyShowContainer(container: containerToShow, switchTab: false)
    }
    
}

// MARK: Private
extension AppDetailsViewController {

    fileprivate func onlyShowContainer(container: Container, switchTab: Bool) {
        // Hide all containers
        keywordsContainer.isHidden = true
        turnaroundContainer.isHidden = true
        sentimentContainer.isHidden = true
        switch container {
        case .sentiment:
            if switchTab {
                segmentedControl.selectedSegmentIndex = 0
                segmentedControl.sendActions(for: UIControlEvents.valueChanged)
            }
            sentimentContainer.isHidden = false
        case .keywords:
            if switchTab {
                segmentedControl.selectedSegmentIndex = 1
                segmentedControl.sendActions(for: UIControlEvents.valueChanged)
            }
            keywordsContainer.isHidden = false
        case .turnaround:
            if switchTab {
                segmentedControl.selectedSegmentIndex = 2
                segmentedControl.sendActions(for: UIControlEvents.valueChanged)
            }
            turnaroundContainer.isHidden = false
        }
    }
    
    fileprivate func resetContainer() {
        keywordsContainer.isHidden = true
        turnaroundContainer.isHidden = true
        sentimentContainer.isHidden = true
        segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    }
    
    fileprivate func loadAppDetails() {

        appIcon.image = image
        appName.text = name
        appName.textColor = UIColor.white
        appName.font = UIFont.regularSFNSDisplay(size: 16)
        
        appCategory.text = category
        appCategory.textColor = UIColor.init(hex: "FFFFFF", alpha: 0.5)
        appCategory.font = UIFont.regularSFNSDisplay(size: 12)
        appCategory.addTextSpacing(spacing: 0.1)
        
        
        let numReviews = numberOfReviews ?? 0
        numberOfReviewsLabel.text = "(\(numReviews))"
        numberOfReviewsLabel.font = UIFont.regularSFNSDisplay(size: 7.5)
        numberOfReviewsLabel.textColor = UIColor.customGrayColor()
        
        let r = rating ?? 0.0
        Utils.setUpStarStackView(numberOfStars: r, starStackView: starStackView)
        
        let s = sentiment ?? 0.0
        // Convert sentiment score to letter grade to display
        let grade = Utils.convertSentimentToLetterScore(sentiment: s)
        sentimentScore.text = grade.rawValue
        sentimentScore.textColor = UIColor.white
        sentimentScore.font = UIFont.boldSystemFont(ofSize: 30)
        
        // Change sentiment icon color corresponding to grade.
        switch grade {
            // Have all A-B grades be green
        case .A, .B:
            sentimentView.backgroundColor = UIColor.customSickGreen()
            // Have all C-D grades be Yellow 
        case .C, .D:
            sentimentView.backgroundColor = UIColor.customYellowColor()
            // Have F grade be red
        case .F:
            sentimentView.backgroundColor = UIColor.customPinkColor()
        default:
            sentimentView.backgroundColor = UIColor.clear
        }
        
    }
    
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
    }
}

// MARK: Navigation
extension AppDetailsViewController {
    @objc fileprivate func goBack() {
        _  = navigationController?.popViewController(animated: true)
        resetContainer()
    }
    
    @objc fileprivate func goToInformation() {
        performSegue(withIdentifier: kToInformationSegue, sender: self)
        onlyShowContainer(container: containerToShow, switchTab: false)
    }
}
