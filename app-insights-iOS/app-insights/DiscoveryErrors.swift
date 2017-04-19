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

enum DiscoveryErrors : Error {
    case noEnvironments
    case noCollections
    case unexpectedJSON
    case stringToIntFailed
    case other(String)
    
    var errorMessage:String {
        switch self {
        case .noEnvironments:
            return "No environments found."
        case .noCollections:
            return "No collections found."
        case .unexpectedJSON:
            return "Unexpected JSON response."
        case .stringToIntFailed:
            return "Unable to convert String to Int."
        case .other(let message):
            return message
        }
    }
}
