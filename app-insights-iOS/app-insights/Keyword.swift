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


/// Model reflects the response object returned by the Discovery service for keywords.
public struct Keyword {
    let keyword: String
    var positiveSentiment: Sentiment
    var neutralSentiment: Sentiment
    var negativeSentiment: Sentiment
    
    
    /// Include addition operation for the number of positive, negative and neutral sentiments
    /// between keywords.
    ///
    /// - Parameter withKeyword: keyword to add sentiment count results to.
    mutating func addSentiments(withKeyword: Keyword) {
        self.positiveSentiment.matchingResults += withKeyword.positiveSentiment.matchingResults
        self.negativeSentiment.matchingResults += withKeyword.negativeSentiment.matchingResults
        self.neutralSentiment.matchingResults += withKeyword.neutralSentiment.matchingResults
    }
}

/// Model reflects the Sentiment object returned by the Discovery service.
public struct Sentiment {
    let type: String
    var matchingResults: Int
}
