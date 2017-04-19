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

class AppListTableViewController: UITableViewController {
    
    let discoveryManager = DiscoveryManager.sharedInstance
    let cloudantManager = CloudantManager.sharedInstance
    var containerToShow: Container = .sentiment

    @IBOutlet weak var loader: UIActivityIndicatorView!

    // Constants
    let kShowAppDetailsSegue = "ShowAppDetails"
    
    // Model
    fileprivate var apps = [App]() {
        didSet {
            // Run on main thread
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
                self?.stopLoading()
            }
        }
    }
}

// MARK: Lifecycle
extension AppListTableViewController {

    override func viewWillAppear(_ animated: Bool) {
        // Setup and show navigation controller after nav bar is done setting up
        Utils.setupDarkNavBar(viewController: self, title: "INSIGHTS")
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName:"AppListTableViewCell",bundle: nil), forCellReuseIdentifier: AppListTableViewCell.kCellIdentifier)
        self.tableView.rowHeight = CGFloat(160.0)
        self.view.backgroundColor = UIColor.customBackgroundColor()
        tableView.separatorStyle = .none
        startLoading()
        fetchData()
        listenOnViewMoreButtonPress()
        listenOnSentimentButtonPress()
        listenOnKeywordButtonPress()
        listenOnTurnaroundButtonPress()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Hide navigation bar upon changing screens.
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kShowAppDetailsSegue {
            if
                let destination = segue.destination.contentViewController as? AppDetailsViewController,
                let cell = sender as? AppListTableViewCell,
                let index = self.tableView?.indexPath(for: cell)
            {
                destination.containerToShow = containerToShow
                destination.image = cell.appIcon.image
                destination.name = apps[index.row].name
                destination.category = apps[index.row].category
                destination.rating = apps[index.row].rating
                destination.numberOfReviews = apps[index.row].numberOfReviews
                destination.descriptionDetail = apps[index.row].description
                destination.sentiment = apps[index.row].appSentimentValue
            }
        }
    }
}

// MARK: Private
extension AppListTableViewController {
    
    fileprivate func listenOnViewMoreButtonPress() {
        let notificationName = Notification.Name(AppListTableViewCell.kButtonPressedNotificationName)
        NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil){ notification in
            print("notified!!")
            self.containerToShow = .sentiment
            DispatchQueue.main.async { [weak self] in
                if let strongSelf = self {
                    strongSelf.performSegue(withIdentifier: strongSelf.kShowAppDetailsSegue, sender: notification.object)
                }
            }
        }
    }
    
    fileprivate func listenOnSentimentButtonPress() {
        let notificationName = Notification.Name(AppListTableViewCell.kSentimentButtonPressedNotificationName)
        NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil){ notification in
            print("sentiment notified!!")
            self.containerToShow = .sentiment
            DispatchQueue.main.async { [weak self] in
                if let strongSelf = self {
                    strongSelf.performSegue(withIdentifier: strongSelf.kShowAppDetailsSegue, sender: notification.object)
                }
            }
        }
    }
    
    fileprivate func listenOnKeywordButtonPress() {
        let notificationName = Notification.Name(AppListTableViewCell.kKeywordButtonPressedNotificationName)
        NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil){ notification in
            print("keyword notified!!")
            self.containerToShow = .keywords
            DispatchQueue.main.async { [weak self] in
                if let strongSelf = self {
                    strongSelf.performSegue(withIdentifier: strongSelf.kShowAppDetailsSegue, sender: notification.object)
                }
            }
        }
    }
    
    fileprivate func listenOnTurnaroundButtonPress() {
        let notificationName = Notification.Name(AppListTableViewCell.kTurnaroundButtonPressedNotificationName)
        NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil){ notification in
            print("turnaround notified!!")
            self.containerToShow = .turnaround
            DispatchQueue.main.async { [weak self] in
                if let strongSelf = self {
                    strongSelf.performSegue(withIdentifier: strongSelf.kShowAppDetailsSegue, sender: notification.object)
                }
            }
        }
    }
    
    
    fileprivate func startLoading() {
        loader.startAnimating()
    }
    
    fileprivate func stopLoading() {
        loader.stopAnimating()
        loader.isHidden = true
    }
    
    fileprivate func showError(message:String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] action in
            self?.fetchData()
        }
        alertVC.addAction(retryAction)
        self.present(alertVC, animated: true) {
            
        }
    }
    
    fileprivate func fetchData() {
        // Setup discovery
        discoveryManager.setupDiscovery(
            onSuccess: { [weak self] in
                // Query Discovery for App Names
                self?.discoveryManager.queryForAppNames(
                    onSuccess: { appNames in
                        self?.fetchCloudantDocs(withNames: appNames)
                },
                    onFailure: { error in
                        self?.showError(message: error.errorMessage)
                })
            },
            onFailure: { [weak self] error in
                self?.showError(message: error.errorMessage)
        })
        
    }
    
    // Query Cloudant for App Documents
    fileprivate func fetchCloudantDocs(withNames:[String]) {
        // Setup Cloudant First
        cloudantManager.setupCloudant(
            onSuccess: { [weak self] in
                // Now query Cloudnat
                self?.cloudantManager.fetchApps(
                    onSuccess: { apps in
                        self?.apps = apps.reversed() },
                    onFailure: { error in
                        self?.showError(message: error.errorMessage)
                })
            },
            onFailure: { [weak self] error in
                self?.showError(message: error.errorMessage)})
    }
    
}

// MARK: Datasource
extension AppListTableViewController {
    
    // Number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apps.count
    }
    
    // Get Cell at for indexpath
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AppListTableViewCell.kCellIdentifier, for: indexPath)

        // Cast to AppListTableViewCell
        if let appListCell = cell as? AppListTableViewCell {
            // Configure cell
            appListCell.setModel(app: apps[indexPath.row])
            return appListCell
        }
        return cell
    }
 
}
