//
//  DetailsMangaViewController.swift
//  P2PApp
//
//  Created by Abhishek Biswas on 03/10/23.
//

import UIKit
import Kingfisher

class DetailsMangaViewController: UIViewController {
    
    @IBOutlet weak var imageProfileManga: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var reverseBtn: UIButton!
    @IBOutlet weak var activityindicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var categoryString: UILabel!
    
    var titleStringForManga : String?
    var imageUrl : String?
    var mangaDetails : MangaDetailsModel?
    var chapterIDArray : [ChapterModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchResult(title: titleStringForManga ?? "")
        self.prepForView()
    }
    
    
    @IBAction func reverseAction(_ sender: UIButton) {
        self.chapterIDArray = self.chapterIDArray.reversed()
        self.tableView.reloadData()
    }
    
    func prepForView(){
        self.imageProfileManga.isHidden = true
        self.titleLabel.isHidden = true
        self.descLabel.isHidden = true
        self.reverseBtn.isHidden = true
        self.tableView.isHidden = true
        self.activityindicator.startAnimating()
        self.statusLabel.isHidden = true
        self.backBtn.isHidden = true
        self.categoryString.isHidden = true
        self.imageProfileManga.layer.cornerRadius = 10
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AnimeEpisodeCell.nib(), forCellReuseIdentifier: AnimeEpisodeCell.cellId)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension DetailsMangaViewController {
    func fetchResult(title: String) {
        var encodedString = title.lowercased()
        encodedString = encodedString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let finalURL = Constants.shared.MANGA_STREAM_URL + Constants.shared.MANGA_ENDPOINT_STREAM + encodedString
        APIParser.shared.parseDataToDict(controller: self, urlString: finalURL, parameters: nil, bodyParams: nil, requestType: "GET") { result in
            if let result =  result as? [String:Any] {
                let resultArray = MangaDetailsModel.parseResult(response: result)
                if let firstElement = resultArray.first {
                    self.mangaDetails = firstElement
                    DispatchQueue.main.async {
                        self.putValueInLabel(response: self.mangaDetails)
                    }
                }
            }
        }
    }
    
    func putValueInLabel(response: MangaDetailsModel?){
        guard let response = response else {return}
        self.imageProfileManga.isHidden = false
        self.titleLabel.isHidden = false
        self.descLabel.isHidden = false
        self.reverseBtn.isHidden = false
        self.tableView.isHidden = false
        self.activityindicator.stopAnimating()
        self.activityindicator.isHidden = true
        self.statusLabel.isHidden = false
        self.backBtn.isHidden = false
        self.categoryString.isHidden = false
        
        
        self.titleLabel.text = self.titleStringForManga ?? ""
        self.descLabel.text =  response.description
        self.statusLabel.text = response.status
        if let imageUrlString = self.imageUrl {
            if let url = URL(string: imageUrlString) {
                self.imageProfileManga.kf.setImage(with: url)
            }
        }
        self.categoryString.text = "List of Chapter"
        self.fetchMangaChapter(response: response.id ?? "")
        
    }
    
    
    func fetchMangaChapter(response: String){
        var queryString = "info?id=\(response)"
        queryString = queryString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let finalURL = Constants.shared.MANGA_STREAM_URL + Constants.shared.MANGA_ENDPOINT_STREAM + queryString
        APIParser.shared.parseDataToDict(controller: self, urlString: finalURL, parameters: nil, bodyParams: nil, requestType: "GET") { result in
            if let results = result as? [String: Any] {
                if let chapter = results["chapters"] as? [[String: Any]] {
                    for item in chapter {
                        if let idChap = item["id"] as? String, let chapterName = item["title"] as? String{
                            let singleModel = ChapterModel(title: chapterName, id: idChap)
                            self.chapterIDArray.append(singleModel)
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}


extension DetailsMangaViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chapterIDArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mangeCell = tableView.dequeueReusableCell(withIdentifier: AnimeEpisodeCell.cellId, for: indexPath) as? AnimeEpisodeCell
        var titleStr = self.chapterIDArray[indexPath.row].title
        titleStr = titleStr.replacingOccurrences(of: "Ch.", with: "Chapter ")
        mangeCell?.selectionStyle = .none
        mangeCell?.episodeLabel.text = titleStr
        return mangeCell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let imageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController
        imageVC?.imageIDChapeter = self.chapterIDArray[indexPath.row].id
        imageVC?.modalPresentationStyle = .fullScreen
        imageVC?.mangaTitle = self.titleStringForManga ?? ""
        self.present(imageVC ?? UIViewController(), animated: true, completion: nil)
    }
}

