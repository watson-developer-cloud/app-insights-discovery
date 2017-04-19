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

class KeywordsTableViewController: UITableViewController {

    let discoveryService = DiscoveryManager.sharedInstance

    // Default row height
    let kCellRowHeight = CGFloat(130.0)
    
    // Name of app, used when querying Discovery service
    fileprivate var appName:String? = nil {
        didSet {
            // Run on main thread
            DispatchQueue.main.async { [weak self] in
                self?.fetchData()
            }
        }
    }
    
    // Category of app, used to remove similar keyword
    fileprivate var appCategory: String? = nil
    
    // Common keywords to remove from being displayed
    fileprivate var commonKeywords = ["app"]
    
    // Model
    fileprivate var keywords = [Keyword]() {
        didSet {
            // Run on main thread
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
}

// MARK: Lifecycle
extension KeywordsTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName:"KeywordListTableViewCell", bundle: nil), forCellReuseIdentifier: KeywordListTableViewCell.kCellIdentifier)
        self.tableView.rowHeight = kCellRowHeight
        self.tableView.backgroundColor = UIColor.customBackgroundColor()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.separatorStyle = .none
    }

}

// MARk: API
extension KeywordsTableViewController {
    
    // Set the app name to query
    func setModel(appName:String) {
        self.appName = appName
    }
    
    func setCategory(appCategory: String) {
        self.appCategory = appCategory
    }
    
}

// MARK: Private
extension KeywordsTableViewController {
    
    fileprivate func fetchData() {
        guard let name = self.appName else { return }
        discoveryService.queryForKeywordsAndSentiment(
            appName: name,
            onSuccess: { [weak self] keywords in
                guard let cleanedKeywords = self?.removeSimilarKeywords(appName: name, keywords: keywords) else {
                    self?.keywords = keywords
                    return
                }
                self?.keywords = cleanedKeywords
            },
            onFailure: {error in
                print(error)
                print("ERORR")
        })
    }
    
    /// Removes keywords related to app name and category. Also removes keywords that are similar.
    ///
    /// - Parameters:
    ///   - appName: name of the app to remove keywords from
    ///   - keywords: keywords found and returned by the discovery service.
    /// - Returns: Returns new list of keywords.
    fileprivate func removeSimilarKeywords(appName: String, keywords: [Keyword]) -> [Keyword] {
        guard let category = self.appCategory else { return [] }
        // keywords to display
        var display: [Keyword] = []
        // array containing app name, category, common keywords
        var appInfo: [String]
        // array to store similar keywords
        var similarKeywords: [String] = []
        // Seperate multiple words of app name into an array of strings
        appInfo = appName.components(separatedBy: " ")
        // Append words making up the app category
        appInfo.append(contentsOf: category.components(separatedBy: " "))
        appInfo.append(contentsOf: commonKeywords)
        
        for var keyword in keywords {
            var checkSimilar = keywords
            for (i, str) in checkSimilar.enumerated() {
                if str.keyword == keyword.keyword {
                    checkSimilar.remove(at: i)
                }
            }
            var foundSimilarWord = false
            for word in appInfo {
                if containsWord(word1: keyword.keyword, word2: word) {
                    foundSimilarWord = true
                    break
                }
            }
            // If we've already displayed similar keyword, do not display the keyword
            // found similar to the first keyword.
            if similarKeywords.contains(keyword.keyword) {
                foundSimilarWord = true
            }
            // If we find a similar keyword, store in list
            // Increase counts for displayed word.
            if let similar = foundMatchingKeyword(word: keyword.keyword, keywords: checkSimilar) {
                similarKeywords.append(similar.keyword)
                
                // TODO - fix this bug. 
                keyword.addSentiments(withKeyword: similar)
            }
            if !foundSimilarWord {
                display.append(keyword)
            }
        }
        return display
    }
    
    /// Checks if words are contained within each other.
    ///
    /// - Parameters:
    ///   - word1: Any string value word
    ///   - word2: Any string value word
    /// - Returns: Returns boolean for if word is contained in one or other. (i.e. cat vs cats)
    fileprivate func containsWord(word1: String, word2: String) -> Bool {
        // If word 1 contains word 2
        if word1.lowercased().range(of: word2.lowercased()) != nil {
            return true
        }
        // If word 2 contains word 1
        if word2.lowercased().range(of: word1.lowercased()) != nil {
            return true
        }
        return false
    }
    
    
    /// Checks if a word is similar to other keywords
    ///
    /// - Parameters:
    ///   - word: the word to check similarity with a list of keywords
    ///   - keywords: Keywords that do not contain that word that's being checked against other keywords.
    /// - Returns: Returns boolean for if the word is similar to other keywords.
    fileprivate func foundMatchingKeyword(word: String, keywords: [Keyword]) -> Keyword? {
        for keyword in keywords {
            if containsWord(word1: keyword.keyword, word2: word) {
                return keyword
            }
        }
        return nil
    }
}

// MARK: Data Source
extension KeywordsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keywords.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: KeywordListTableViewCell.kCellIdentifier, for: indexPath)
        
        // Remove gray background when selecting
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        // Cast to KeywordListTableViewCell
        if let keywordCell = cell as? KeywordListTableViewCell {
            keywordCell.setModel(keyword: self.keywords[indexPath.row])
            return keywordCell
        }
        return cell
    }
    
}
