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

class CloudantManager {
    
    // Constants
    fileprivate let kAppsDBName = "app_db"
    
    fileprivate var cloudant:Cloudant!
    // Singleton
    static let sharedInstance: CloudantManager = CloudantManager()
    
    // Private init
    fileprivate init() { }
}

// MARK: API
extension CloudantManager {
    
    func setupCloudant(onSuccess success: @escaping () ->Void, onFailure failure: @escaping (CloudantErrors) ->Void) {
        self.cloudant = Cloudant()
        cloudant.authorize(onSuccess: success, onFailure: failure)
    }
    
    func fetchApps(onSuccess success: @escaping ([App]) ->Void, onFailure failure: @escaping (CloudantErrors) ->Void) {
        cloudant.fetchAllDocumentsOfDatabase(named: kAppsDBName,
            onSuccess: {json in
                if let array = json.dictionary?["rows"]?.array {
                    var apps = [App]()
                    for item in array {
                        if let json = item.dictionary?["doc"], let app = App(json: json) {
                            apps.append(app)
                        }
                    }
                    success(apps)
                }
                
            },
            onFailure: {error in
                failure(error)
        })
    }
    
}

