//
//  APICaller.swift
//  P2PApp
//
//  Created by Abhishek Biswas on 29/09/23.
//

import Foundation
import UIKit

class APICaller {
    static let shared = APICaller()
    func prepareForAPICall(controller: UIViewController?, urlString: String, parameters: [[String: Any]]?, bodyParams: [String: Any]?, requestType: String, compleation: @escaping(Data) -> Void){
        if !urlString.isEmpty {
            guard var url = URL(string: urlString) else {return}
            if !(parameters?.isEmpty ?? false) {
                var queryItems : [URLQueryItem] = []
                if let parms = parameters {
                    for item in parms {
                        queryItems.append(URLQueryItem(name: (item["name"] as? String) ?? "", value: (item["value"] as? String) ?? ""))
                    }
                    url = url.appending(queryItems: queryItems)
                }
            }
            var request = URLRequest(url: url)
            request.httpMethod = requestType.uppercased()
            let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let _ = error {
                    compleation(Data())
                }else if let data  = data {
                    compleation(data)
                }
            }
            dataTask.resume()
        }else{
            Constants.shared.makeAlert(controller: controller, title: "Error", message: "Cannot Fetch Data From Server")
        }
    }
}

class APIParser{
    static let shared = APIParser()
    func parseDataToDict(controller: UIViewController?, urlString: String, parameters: [[String: Any]]?, bodyParams: [String: Any]?, requestType: String, compleation: @escaping(Any?) -> Void){
        APICaller.shared.prepareForAPICall(controller: controller, urlString: urlString, parameters: parameters, bodyParams: bodyParams, requestType: requestType) { result in
            if !result.isEmpty {
                do{
                    let decodedResult = try JSONSerialization.jsonObject(with: result, options: []) as? [String: Any]
                    compleation(decodedResult)
                }catch{
                    compleation(nil)
                }
            }else{
                print("Cannot Connect with API")
                compleation(nil)
            }
        }
    }
    
    func parseDataToArray(controller: UIViewController?, urlString: String, parameters: [[String: Any]]?, bodyParams: [String: Any]?, requestType: String, compleation: @escaping(Any?) -> Void){
        APICaller.shared.prepareForAPICall(controller: controller, urlString: urlString, parameters: parameters, bodyParams: bodyParams, requestType: requestType) { result in
            if !result.isEmpty {
                do{
                    let decodedResult = try JSONSerialization.jsonObject(with: result, options: []) as? [[String: Any]]
                    compleation(decodedResult)
                }catch{
                    compleation(nil)
                }
            }else{
                print("Cannot Connect with API")
                compleation(nil)
            }
        }
    }
}


extension URL {
    func appending(_ queryItems: [URLQueryItem]) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems
        return urlComponents.url
    }
}
