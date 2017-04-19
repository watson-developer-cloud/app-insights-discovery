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

// Model describes app details pulled down from Cloudant.
struct App {
    let name:String
    let description: String
    let imageURL:URL
    let category: String
    let rating: Double
    let numberOfReviews: Int
    let topKeyword: String
    let numberOfTurnarounds: Int
    let appSentimentValue: Double

    init?(json:JSON){
        guard
            let name = json["name"].string,
            let description = json["description"].string,
            let imageURLString = json["image"].string,
            let imageURL = URL(string: imageURLString),
            let category = json["category"].string,
            let rating = json["rating"].double,
            let numberOfReviews = json["total_reviews"].int,
            let topKeyword = json["keyword"].string,
            let numberOfTurnarounds = json["turnarounds"].int,
            let appSentimentValue = json["sentiment"].double
        else {
            return nil
        }
        
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.category = category
        self.rating = rating
        self.numberOfReviews = numberOfReviews
        self.topKeyword = topKeyword
        self.numberOfTurnarounds = numberOfTurnarounds
        self.appSentimentValue = appSentimentValue
    }
}

/// The sentiment value converted into a letter grade scale. Sentiment value is
/// given on the range of [-1, 1], with lower values representing negative
/// sentiment and higher values representing positive sentiment.
///
/// - A: sentiment value falls within the range (0.6, 1]
/// - B: sentiment value falls within the range (0.2, 0.6]
/// - C: sentiment value falls within the range (-0.2, 0.2]
/// - D: sentiment value falls within the range (-0.6, -0.2]
/// - F: sentiment value falls within the range [-1.0, -0.6]

enum Grade: String {
    
    case A = "A"
    case B = "B"
    case C = "C"
    case D = "D"
    case F = "F"
    case None = ""
    
}
