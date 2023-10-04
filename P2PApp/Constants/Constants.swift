//
//  Constants.swift
//  P2PApp
//
//  Created by Abhishek Biswas on 29/09/23.
//

import Foundation
import UIKit
import Kingfisher


class Constants{
    static let shared = Constants()
    
    let BASE_URL = "https://api.jikan.moe/v4"
    let ANIME_URL_STREAM = "https://gogoanime-api-production-5509.up.railway.app"
    let ANIME_STREAM_ENDPOINT = "/anime-details/"
    let ANIME_ENDPOINT = "/anime"
    let MANGA_ENDPOINT = "/manga"
    let VIDEO_ENDPOINT = "/vidcdn/watch/"
    let MANGA_STREAM_URL = "https://api.consumet.org/"
    let MANGA_ENDPOINT_STREAM = "manga/mangahere/"
    
    func makeAlert(controller: UIViewController?, title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default))
        if let vc = controller {
            vc.present(alert, animated: true)
        }
    }
    
    func makeAlertWithAction(controller: UIViewController?, title: String, message: String, compleation: @escaping()->Void){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
            compleation()
        }))
        if let vc = controller {
            vc.present(alert, animated: true)
        }
    }
}


extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

