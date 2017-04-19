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

enum CloudantRouter {
    
    static var baseURL:String!
    
    case getAllDBs
    case getAllDocsOfDB(named:String, includeDocs:Bool)
    
    var params:(method:String, path:String) {
        switch self {
        case .getAllDBs:
            return ("GET", "\(CloudantRouter.baseURL!)/_all_dbs")
        case .getAllDocsOfDB(let dbName, let includeDocs):
            if includeDocs {
                return ("GET", "\(CloudantRouter.baseURL!)/\(dbName)/_all_docs?include_docs=true")
            } else {
                return ("GET", "\(CloudantRouter.baseURL!)/\(dbName)/_all_docs")
            }
            
        }
    }
}
