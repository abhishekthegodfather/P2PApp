//
//  Models.swift
//  P2PApp
//
//  Created by Abhishek Biswas on 29/09/23.
//

import Foundation


class AnimeTileModel{
    var title: String?
    var animeProfileImage: String?
    var status: String?
    var episode: String?
    var type: String?
    var startTime: String?
    var endTime: String?
    var source: String?
    var synopsis : String?
    
    init(title: String? = nil, animeProfileImage: String? = nil, status: String? = nil, episode: String? = nil, type: String? = nil, startTime: String? = nil, endTime: String? = nil, source: String? = nil, synopsis: String? = nil) {
        self.title = title
        self.animeProfileImage = animeProfileImage
        self.status = status
        self.episode = episode
        self.type = type
        self.startTime = startTime
        self.endTime = endTime
        self.source = source
        self.synopsis = synopsis
    }
    
    func parseResponse(responseDict: [String: Any]) -> [AnimeTileModel] {
        var dataArray : [AnimeTileModel] = []
        if let reponseData = responseDict["data"] as? [[String : Any]] {
            for dictItem in reponseData {
                let singleAnimeObject = AnimeTileModel()
                if let titleString = dictItem["title"] as? String, let typeString = dictItem["type"] as? String, let sourceString = dictItem["source"] as? String, let episodesString = dictItem["episodes"] as? Int, let statusString = dictItem["status"] as? String, let dateString = dictItem["aired"] as? [String: Any], let imageString = dictItem["images"] as? [String: Any], let storyString = dictItem["synopsis"] as? String{
                    singleAnimeObject.title = titleString
                    singleAnimeObject.status = statusString
                    singleAnimeObject.episode = String(episodesString)
                    singleAnimeObject.type = typeString
                    singleAnimeObject.source = sourceString
                    singleAnimeObject.synopsis = storyString
                    if let startTime = dateString["from"] as? String, let endTime = dateString["to"] as? String {
                        singleAnimeObject.startTime = startTime
                        singleAnimeObject.endTime = endTime
                    }
                    
                    if let imageUrlDict = imageString["jpg"] as? [String : Any] {
                        if let imageUrl = imageUrlDict["image_url"] as? String {
                            singleAnimeObject.animeProfileImage = imageUrl
                        }
                    }
                    dataArray.append(singleAnimeObject)
                }
                
            }
        }
        return dataArray
    }
}


class AnimeDetailsModel {
    var title: String?
    var status : String?
    var genres : [String]?
    var releasedDate : String?
    var synopsis : String?
    var animeURLImage : String?
    var episodesList : [AnimeEpisode]?
    var totalEpisode : String?
    
    init(title: String? = nil, status: String? = nil, genres: [String]? = nil, releasedDate: String? = nil, synopsis: String? = nil, animeURLImage: String? = nil, episodesList: [AnimeEpisode]? = nil, totalEpisode: String? = nil) {
        self.title = title
        self.status = status
        self.genres = genres
        self.releasedDate = releasedDate
        self.synopsis = synopsis
        self.animeURLImage = animeURLImage
        self.episodesList = episodesList
        self.totalEpisode = totalEpisode
    }
    
    func parseResponse(response: [String:Any]) -> AnimeDetailsModel?{
        if let title = response["animeTitle"] as? String, let releasedDate = response["releasedDate"] as? String, let genres = response["genres"] as? [String], let synopsis = response["synopsis"] as? String, let animeImg = response["animeImg"] as? String, let episodesList = response["episodesList"] as? [[String: Any]], let totalEpisodes = response["totalEpisodes"] as? String, let status = response["status"] as? String{
            
            let animeEpisodeArray = AnimeEpisode().pareseResponse(responses: episodesList)
            let singleAnime = AnimeDetailsModel(title: title, status: status, genres:genres, releasedDate: releasedDate, synopsis: synopsis, animeURLImage: animeImg, episodesList: animeEpisodeArray, totalEpisode: totalEpisodes)
            return singleAnime
        }
        return nil
    }
}

class AnimeEpisode {
    var episodeId : String?
    var episodeNum : String?
    var episodeUrl : String?
    var isSubed: Bool?
    var isDubed: Bool?
    init(episodeId: String? = nil, episodeNum: String? = nil, episodeUrl: String? = nil, isSubed: Bool? = nil, isDubed: Bool? = nil) {
        self.episodeId = episodeId
        self.episodeNum = episodeNum
        self.episodeUrl = episodeUrl
        self.isSubed = isSubed
        self.isDubed = isDubed
    }
    
    func pareseResponse(responses:[[String: Any]]) -> [AnimeEpisode] {
        var animeEpisode : [AnimeEpisode] = []
        for response in responses {
            if let episodeId = response["episodeId"] as? String, let episodeNum = response["episodeNum"] as? String, let episodeUrl = response["episodeUrl"] as? String, let isSubbed = response["isSubbed"] as? Bool, let isDubbed = response["isDubbed"] as? Bool{
                let singleAnimeEpisodeModel = AnimeEpisode(episodeId: episodeId, episodeNum: episodeNum, episodeUrl: episodeUrl, isSubed: isSubbed, isDubed: isDubbed)
                animeEpisode.append(singleAnimeEpisodeModel)
            }
        }
        return animeEpisode
    }
}

class MangaTileModel{
    var title: String?
    var mangaProfileImage: String?
    var status: String?
    var chapter: String?
    var volume: String?
    var startTime: String?
    var endTime: String?
    
    init(title: String? = nil, mangaProfileImage: String? = nil, status: String? = nil, chapter: String? = nil, volume: String? = nil, startTime: String? = nil, endTime: String? = nil) {
        self.title = title
        self.mangaProfileImage = mangaProfileImage
        self.status = status
        self.chapter = chapter
        self.volume = volume
        self.startTime = startTime
        self.endTime = endTime
    }
    
    func parseResponse(responseDict: [String: Any]) -> [MangaTileModel] {
        var dataArray : [MangaTileModel] = []
        if let reponseData = responseDict["data"] as? [[String : Any]] {
            for dictItem in reponseData {
                let singleAnimeObject = MangaTileModel()
                if let titleString = dictItem["title"] as? String,
                   let statusString = dictItem["status"] as? String,
                   let chapterString = dictItem["chapters"] as? Int,
                   let dateString = dictItem["published"] as? [String: Any],
                   let imageString = dictItem["images"] as? [String: Any], let volString = dictItem["volumes"] as? Int{
                    
                    singleAnimeObject.title = titleString
                    singleAnimeObject.status = statusString
                    singleAnimeObject.chapter = String(chapterString)
                    singleAnimeObject.status = statusString
                    singleAnimeObject.volume = String(volString)
                    if let startTime = dateString["from"] as? String, let endTime = dateString["to"] as? String {
                        singleAnimeObject.startTime = startTime
                        singleAnimeObject.endTime = endTime
                    }
                    
                    if let imageUrlDict = imageString["jpg"] as? [String : Any] {
                        if let imageUrl = imageUrlDict["image_url"] as? String {
                            singleAnimeObject.mangaProfileImage = imageUrl
                        }
                    }
                    dataArray.append(singleAnimeObject)
                }
                
            }
        }
        return dataArray
    }
}

class MangaDetailsModel {
    var titleString : String?
    var id : String?
    var headerForImage : String?
    var status : String?
    var description : String?
    init(titleString: String? = nil, id: String? = nil, headerForImage: String? = nil, status: String? = nil, description: String? = nil) {
        self.titleString = titleString
        self.id = id
        self.headerForImage = headerForImage
        self.status = status
        self.description = description
    }
    
    static func parseResult(response : [String: Any]) -> [MangaDetailsModel] {
        var resultArray : [MangaDetailsModel] = []
        if let results = response["results"] as? [[String:Any]] {
            for result in results {
                if let id = result["id"] as? String, let title = result["title"] as? String, let headerForImage = result["headerForImage"] as? [String:Any], let status = result["status"] as? String?, let description = result["description"] as? String {
                    if let imageUrl = headerForImage["Referer"] as? String{
                        let singleResult = MangaDetailsModel(titleString: title, id:id, headerForImage:imageUrl, status:status, description:description)
                        resultArray.append(singleResult)
                    }
                }
            }
        }
        return resultArray
    }
}

class MangaImageModel {
    var page: Int?
    var imageUrl : String?
    var headerForImage : String?
    init(page: Int? = nil, imageUrl: String? = nil, headerForImage: String? = nil) {
        self.page = page
        self.imageUrl = imageUrl
        self.headerForImage = headerForImage
    }
    static func parseResult(response : [[String: Any]]) -> [MangaImageModel] {
        var mangaPageArray : [MangaImageModel] = []
        for item in response {
            if let page = item["page"] as? Int, let img = item["img"] as? String, let headerForImage = item["headerForImage"] as? [String:Any] {
                if let imageUrl =  headerForImage["Referer"] as? String{
                    let singleModel = MangaImageModel(page: page, imageUrl: img, headerForImage: imageUrl)
                    mangaPageArray.append(singleModel)
                }
            }
        }
        return mangaPageArray
    }
}


class ChapterModel {
    var title : String
    var id : String
    
    init(title: String, id: String) {
        self.title = title
        self.id = id
    }
}


class DownlaodMangaModel {
    var title : String
    var imageData : [Data]
    var chpaterId : String
    
    init(title: String, imageData: [Data], chpaterId: String) {
        self.title = title
        self.imageData = imageData
        self.chpaterId = chpaterId
    }
}
