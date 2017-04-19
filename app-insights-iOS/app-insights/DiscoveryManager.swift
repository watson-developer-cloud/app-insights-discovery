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
import DiscoveryV1
import SwiftyJSON

class DiscoveryManager {
    
    // Constants
    fileprivate let kEnvironmentName  = "byod"
    fileprivate let kDiscoveryVersion = "2017-02-14"
    fileprivate let kCollectionName   = "compiled_reviews_v4"
    
    fileprivate var discovery: Discovery!
    fileprivate var environmentID: String = ""
    fileprivate var collectionID: String  = ""
    
    // Singleton
    static let sharedInstance: DiscoveryManager = DiscoveryManager()
    
    // Private init
    fileprivate init() { }
}

// MARK: API
extension DiscoveryManager {
    
    /*
     Inits discovery instance + fetches environment/collection IDs.
     */
    func setupDiscovery(onSuccess success: @escaping () ->Void, onFailure failure: @escaping (DiscoveryErrors) ->Void) {
        discovery = Discovery(
            username: Credentials.DiscoveryUsername,
            password: Credentials.DiscoveryPassword,
            version: kDiscoveryVersion)
        // Fetch environment
        discovery.getEnvironments(withName: kEnvironmentName,
            failure: { error in
                print("Error - getEnvironments: \(error)")
                failure(.other(error.localizedDescription))},
            success: { environments in
                print("Environments: \(environments)")
                if let environmentID = environments.first?.environmentID {
                    self.environmentID = environmentID
                    // Fetch collection
                    self.getCollectionID(onSuccess: success, onFailure: failure)
                } else {
                    failure(DiscoveryErrors.noEnvironments)
                }
            })
    }
    
    func getCollectionID(onSuccess success: @escaping () ->Void, onFailure failure: @escaping (DiscoveryErrors) ->Void) {
        discovery.getCollections(withEnvironmentID: environmentID, withName: kCollectionName,
            failure: { error in
                print("Error - getCollections: \(error)")
                failure(.other(error.localizedDescription))},
            success: { collections in
                print("Collections: \(collections)")
                if let collectionID = collections.first?.collectionID {
                    self.collectionID = collectionID
                    success()
                } else {
                    failure(DiscoveryErrors.noCollections)
                }
            })
    }
    
    /// Query Discovery service to return app names by using Discovery's
    /// query language to search for all apps crawled and loaded into the service
    ///
    /// - Parameters:
    ///   - success: Returns an array of App objects.
    ///   - failure: Returns an error response of what may have failed.
    
    // TODO - Probably should append the ID's rather than the app name string..? Need to re-upload data to include corresponding app id's cause 
    // sarah was dumb and didn't upload the app id with the review. Note: The string form of these app names are not unicode.
    // TODO - short way around for now: just add a function that cleans the app names.
    func queryForAppNames(onSuccess success: @escaping ([String]) ->Void, onFailure failure: @escaping (DiscoveryErrors) ->Void) {
        discovery.queryDocumentsInCollection(
            withEnvironmentID: environmentID,
            withCollectionID: collectionID,
            withAggregation: "term(app_name)",
            return: "aggregations",
            failure: { error in
                print("Error - queryDocumentsInCollection: \(error)")
                failure(.other(error.localizedDescription))},
            success: { response in
                if let responseData = try? JSONSerialization.data(withJSONObject: response.json, options: []) {
                    var apps = [String]()
                    let json = JSON(data: responseData)
                    let appNameResults = json["aggregations"][0]["results"]
                    for (_, appName) in appNameResults {
                        let app = appName["key"].stringValue
                        apps.append(app)
                    }
                    print ("appNameResults = \(apps)")
                    success(apps)
                } else {
                    failure(DiscoveryErrors.unexpectedJSON)
                }
        })
    }
    
    /// Query Discovery service for the information to graph review sentiment
    /// over time.
    /// - Parameters:
    ///   - appName: Specifies which app to grab sentiment for.
    ///   - success: <#success description#>
    ///   - failure: <#failure description#>
    func queryForSentiment(appName: String, onSuccess success: @escaping ([GraphSentiment]) ->Void, onFailure failure: @escaping (DiscoveryErrors) ->Void) {
        discovery.queryDocumentsInCollection(
            withEnvironmentID: environmentID,
            withCollectionID: collectionID,
            withAggregation: "filter(app_name:\(appName)).timeslice(updated,1day).term(review_enriched.docSentiment.type)",
            return: "aggregations",
            failure: { error in
                print("Error - queryDocumentsInCollection: \(error)")
                failure(.other(error.localizedDescription))},
            success: { response in
                if let responseData = try? JSONSerialization.data(withJSONObject: response.json, options: []) {
                    var graphSentiments = [GraphSentiment]()
                    let json = JSON(data: responseData)
                    let timeSlice = json["aggregations"][0]["aggregations"][0]["results"]
                    for (_, timeSliceInterval) in timeSlice {
                        let time = timeSliceInterval["key_as_string"].stringValue
                        var positiveSentiment = Sentiment(type: "positive", matchingResults: 0)
                        var negativeSentiment = Sentiment(type: "negative", matchingResults: 0)
                        for (_, sentiment) in timeSliceInterval["aggregations"][0]["results"] {
                            guard let matchingResults = Int(sentiment["matching_results"].stringValue) else {
                                failure(DiscoveryErrors.stringToIntFailed)
                                break
                            }
                            if sentiment["key"] == "positive" {
                                positiveSentiment.matchingResults = matchingResults
                            }
                            if sentiment["key"] == "negative" {
                                negativeSentiment.matchingResults = matchingResults
                            }
                        }
                        let graphSentiment = GraphSentiment(date: time, positiveSentiment: positiveSentiment, negativeSentiment: negativeSentiment)
                        graphSentiments.append(graphSentiment)
                        success(graphSentiments)
                    }
                }
        })
    }
    
    /// Query Discovery service for reviews that give 3 or less stars, but
    /// have positive sentiments associated with their reviews. 
    ///
    /// - Parameters:
    ///   - appName: Specify which app to grab reviews from.
    ///   - success: Returns an array of review objects.
    ///   - failure: Return any failure received when parsing Discovery service's
    ///              response.
    func queryForPositiveSentimentLowRatingReviews(appName: String, onSuccess success: @escaping ([Review]) ->Void, onFailure failure: @escaping (DiscoveryErrors) -> Void) {
        discovery.queryDocumentsInCollection(
            withEnvironmentID: environmentID,
            withCollectionID: collectionID,
            withFilter: "app_name:\(appName),review_enriched.docSentiment.type:positive,rating<3",
            return: "rating,review,version,app_name,title,updated",
            failure: { error in
                print ("\(error)")
                failure(.other(error.localizedDescription)) })
        { response in
            if let responseData = try? JSONSerialization.data(withJSONObject: response.json, options: []) {
                var reviews = [Review]()
                let json = JSON(data: responseData)
                let reviewResults = json["results"]
                for (_, reviewResult) in reviewResults {
                    guard let rating = Double(reviewResult["rating"].stringValue) else {
                        failure(DiscoveryErrors.stringToIntFailed)
                        break
                    }
                    let version = reviewResult["version"].stringValue
                    let date = self.transformDateToString(date: reviewResult["updated"].stringValue)
                    let review = Review(appName: reviewResult["app_name"].stringValue,
                                        title: reviewResult["title"].stringValue,
                                        rating: rating,
                                        review: reviewResult["review"].stringValue,
                                        version: version,
                                        date: date)
                    reviews.append(review)
                }
//                print ("review results = \(reviews)")
                success(reviews)
            }
        }
    }
    
    /// Query discovery service for reviews' keywords and their corresponding 
    /// sentiment value.
    ///
    /// - Parameters:
    ///   - appName: Specify which reviews to grab corresponding to the app name.
    ///   - success: Returns an array of keywords that contain the keyword text
    ///              and the number of reviews that contain positive and negative
    ///              sentiment values.
    ///   - failure: Returns a DiscoveryManager error. 
    func queryForKeywordsAndSentiment(appName: String, onSuccess success: @escaping ([Keyword]) ->Void, onFailure failure: @escaping (DiscoveryErrors) -> Void) {
        discovery.queryDocumentsInCollection(
            withEnvironmentID: environmentID,
            withCollectionID: collectionID,
            withAggregation: "filter(app_name:\(appName)).term(review_enriched.keywords.text).term(review_enriched.keywords.sentiment.type)",
            count: 1,
            return: "keywords",
            failure: { error in
                print ("\(error)")
                failure(.other(error.localizedDescription)) })
        { response in
            if let responseData = try? JSONSerialization.data(withJSONObject: response.json, options: []) {
                var keywords = [Keyword]()
                let json = JSON(data: responseData)
                let keywordResults = json["aggregations"][0]["aggregations"][0]["results"]
                print ("keywordAndSentiment Results = \(keywordResults)")
                for (_, keywordResult) in keywordResults {
                    let keyword = keywordResult["key"].stringValue
                    var positiveSentiment = Sentiment(type: "positive", matchingResults: 0)
                    var neutralSentiment = Sentiment(type: "neutral", matchingResults: 0)
                    var negativeSentiment = Sentiment(type: "negative", matchingResults: 0)
                    for (_, sentiment) in keywordResult["aggregations"][0]["results"] {
                        guard let matchingResults = Int(sentiment["matching_results"].stringValue) else {
                            failure(DiscoveryErrors.stringToIntFailed)
                            break
                        }
                        if sentiment["key"] == "positive" {
                            positiveSentiment.matchingResults = matchingResults
                        }
                        if sentiment["key"] == "neutral" {
                            neutralSentiment.matchingResults = matchingResults
                        }
                        if sentiment["key"] == "negative" {
                            negativeSentiment.matchingResults = matchingResults
                        }
                    }
                    let decodedKeyword = Keyword(keyword: keyword, positiveSentiment: positiveSentiment, neutralSentiment: neutralSentiment, negativeSentiment: negativeSentiment)
                    keywords.append(decodedKeyword)
//                    print ("keyword result = \(keywords)")
                    success(keywords)
                }
            }
        }
    }
}

// MARK: Utils
extension DiscoveryManager {
    
    /// Transform date time to string.
    func transformDateToString(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd\'T\'HH:mm:ssZZZZZ"
        if let formattedDate = dateFormatter.date(from: date) {
            // convert Date to TimeInterval (typealias for Double)
            let timeInterval = formattedDate.timeIntervalSince1970
            
            // convert to Integer
            let timeSincePOSIX = Int(timeInterval)
            return doubleDateToString(date: Double(timeSincePOSIX))
        } else {
            return ""
        }
    }
    
    /// Format Double to readable string value in form i.e. Mar 3, 2017.
    func doubleDateToString(date: Double) -> String {
        let date = Date(timeIntervalSince1970: date)
        // Setting output date format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        // Use defined date format to format date
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
