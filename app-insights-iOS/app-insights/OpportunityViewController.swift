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

class OpportunityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Discovery Manager
    let discoveryService = DiscoveryManager.sharedInstance
    
    // Default row height
    let kCellRowHeight = CGFloat(190.0)
    
    // Error title
    let kErrorTitle = "Error Fetching Reviews"
    
    // State tracking for expanding button.
    var reviewContainerWrappers = [ReviewContainerWrapper]()
    
    // Name of app, used when querying Discovery service
    fileprivate var appName:String? = nil {
        didSet {
            // Run on main thread
            DispatchQueue.main.async { [weak self] in
                // Fetch reviews
                self?.fetchData()
            }
        }
    }
    
    // Model
    fileprivate var reviews = [Review]() {
        didSet {
            // Set all reviews to expand for now.
            self.reviewContainerWrappers =  self.reviews.map {
                // Leave all reviews as expanded.
                ReviewContainerWrapper.init(expanded: true, review: $0)
            }
            // Run on main thread
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    @IBOutlet var tableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.register(UINib(nibName:"ReviewListTableViewCell", bundle: nil), forCellReuseIdentifier: ReviewListTableViewCell.kCellIdentifier)
        
        tableView.backgroundColor = UIColor.customBackgroundColor()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = kCellRowHeight
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Remove lines in table view.
        tableView.separatorStyle = .none
        
        self.view.backgroundColor = UIColor.customBackgroundColor()
    }
    
}

// MARK: Data Source
extension OpportunityViewController {

    // Number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReviewListTableViewCell.kCellIdentifier, for: indexPath)
        // Remove gray background when selecting
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if let reviewCell = cell as? ReviewListTableViewCell {
            // Set table view and reviews
            reviewCell.tableView = tableView
            reviewCell.setModel(reviewContainerWrapper: self.reviewContainerWrappers[indexPath.row])
            return reviewCell
        }
        return cell
    }
    
}

// MARK: API
extension OpportunityViewController {
    
    // Set the app name to query
    func setModel(appName:String) {
        self.appName = appName

    }
    
    // Check if the string should be expanded.
    func shouldExpand(string: String)  -> Bool {
        if string.characters.count >= 255 {
            return false
        }
        return true
    }
}

// MARK: - Private
extension OpportunityViewController {
    
    // Query Discovery service using App's name
    fileprivate func fetchData() {
        guard let name = self.appName else { return }
        discoveryService.queryForPositiveSentimentLowRatingReviews(
            appName: name,
            onSuccess: { [weak self] reviews in
                self?.reviews = reviews
            },
            onFailure: { [weak self] error in
                self?.showError(message: error.errorMessage)
        })
    }
    
    // Show Alert
    fileprivate func showError(message:String) {
        let alertVC = UIAlertController(title: self.kErrorTitle, message: message, preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] action in
            self?.fetchData()
        }
        let okAction = UIAlertAction(title:"Ok", style:.cancel) { _ in print("User cancelled operation")}
        alertVC.addAction(okAction)
        alertVC.addAction(retryAction)
        self.present(alertVC, animated: true) {
            
        }
    }
}
