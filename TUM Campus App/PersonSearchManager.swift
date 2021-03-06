//
//  PersonSearchManager.swift
//  TUM Campus App
//
//  Created by Mathias Quintero on 12/8/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash

class PersonSearchManager: SearchManager {
    
    var request: Request?
    
    var main: TumDataManager?
    
    var query: String?
    
    func setQuery(_ query: String) {
        self.query = query
    }
    
    required init(mainManager: TumDataManager) {
        main = mainManager
    }
    
    func fetchData(_ handler: @escaping ([DataElement]) -> ()) {
        request?.cancel()
        let url = getURL()
        request = Alamofire.request(url).responseString() { (response) in
            if let value = response.result.value {
                let parsedXML = SWXMLHash.parse(value)
                let rows = parsedXML["rowset"]["row"].all
                if !rows.isEmpty {
                    var people = [DataElement]()
                    for i in 0...min(rows.count-1,20) {
                        let row = rows[i]
                        if let name = row["vorname"].element?.text, let lastname = row["familienname"].element?.text, let id = row["obfuscated_id"].element?.text {
                            let image = row["bild_url"].element?.text ?? ""
                            let newUser = UserData(name: name+" "+lastname, picture: image, id: id)
                            people.append(newUser)
                        }
                    }
                    handler(people)
                }
            }
        }
    }
    
    func getURL() -> String {
        let base = TUMOnlineWebServices.BaseUrl.rawValue + TUMOnlineWebServices.PersonSearch.rawValue
        if let token = main?.getToken(), let search = query {
            let url = base + "?" + TUMOnlineWebServices.TokenParameter.rawValue + "=" + token + "&pSuche=" + search
            if let value = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed) {
                return value
            }
        }
        return ""
    }
    
}
