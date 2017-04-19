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
import RestKit
import SwiftyJSON

/// Initialize Cloudant instance
struct Cloudant {
    
    let credentials:RestKit.Credentials
    
    init(username:String = Credentials.CloudantUsername, password:String = Credentials.CloudantPassword){
        self.credentials = RestKit.Credentials.basicAuthentication(username: username, password: password)
        CloudantRouter.baseURL = "https://\(username).cloudant.com"
    }
}

// MARK: API
extension Cloudant {

    // Test credentials by fetching all DBs from Cloudant instance
    func authorize(onSuccess success: @escaping () ->Void, onFailure failure: @escaping (CloudantErrors) ->Void){
        let (method, url) = CloudantRouter.getAllDBs.params
        requestCloudant(method: method, url: url, onSuccess: {_ in success()}, onFailure: failure)
    }
    
    // Fetch all the documents of named Database
    func fetchAllDocumentsOfDatabase(named dbName:String, onSuccess success: @escaping (SwiftyJSON.JSON) ->Void, onFailure failure: @escaping (CloudantErrors) ->Void) {
        let (method, url) = CloudantRouter.getAllDocsOfDB(named:dbName, includeDocs: true).params
        requestCloudant(method: method, url: url,
            onSuccess: { json in
                success(json)},
            onFailure: failure)
    }
    
}

// MARK: Private
extension Cloudant {
    fileprivate func requestCloudant(method:String, url:String, headerParameters:[String:String] = [:], queryItems: [URLQueryItem]? = nil, onSuccess success: @escaping (SwiftyJSON.JSON) ->Void, onFailure failure: @escaping (CloudantErrors) ->Void){
        let request = RestRequest(method: method, url: url, credentials: self.credentials, headerParameters: headerParameters, queryItems:queryItems)
        request.response{data, response, error in
            if let errorMessage = error?.localizedDescription {
                failure(.other(errorMessage))
            } else if let data = data {
                let json = SwiftyJSON.JSON(data: data)
                // Even though data is valid and no error code, check for 'error' key
                if let _ = json.dictionary?["error"], let reason = json.dictionary?["reason"]?.string {
                    failure(.other(reason))
                } else {
                    success(json)
                }
                
                
            }
        }
    }
}
