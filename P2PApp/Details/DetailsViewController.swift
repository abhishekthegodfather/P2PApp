//
//  DetailsViewController.swift
//  P2PApp
//
//  Created by Abhishek Biswas on 29/09/23.
//

import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var imageViewForAnimeManga: UIImageView!
    @IBOutlet weak var titleString: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var detailsString: UILabel!
    @IBOutlet weak var detailsTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reverseBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    var animeTitle : String?
    var descriptionString: String?
    var animeModel : AnimeDetailsModel?
    var selectedData : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        tableView.register(AnimeEpisodeCell.nib(), forCellReuseIdentifier: AnimeEpisodeCell.cellId)
        tableView.delegate = self
        tableView.dataSource = self
        self.getAnimeDetails(nameOfAnime: animeTitle ?? "")
        prepareForView()
        self.reverseBtn.addTarget(self, action: #selector(reverseBtnAction(_ :)), for: .touchUpInside)
    }
    
    func prepareForView(){
        self.imageViewForAnimeManga.layer.cornerRadius = 10
        self.imageViewForAnimeManga.isHidden = true
        self.titleString.isHidden = true
        self.status.isHidden = true
        self.detailsString.isHidden = true
        self.tableView.isHidden = true
        self.detailsTitle.isHidden = true
        self.backBtn.isHidden = true
        self.reverseBtn.isHidden = true
    }
    
    @objc func reverseBtnAction(_ sender: UIButton){
        animeModel?.episodesList = animeModel?.episodesList?.reversed()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension DetailsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(animeModel?.totalEpisode ?? "") ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let animeCell = tableView.dequeueReusableCell(withIdentifier: AnimeEpisodeCell.cellId, for: indexPath) as? AnimeEpisodeCell
        animeCell?.episodeLabel.text = "Episode " + (self.animeModel?.episodesList?[indexPath.row].episodeNum ?? "")
        animeCell?.selectionStyle = .none
        return animeCell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.selectedData = self.animeModel?.episodesList?[indexPath.row].episodeId ?? ""
        self.callVideoAPI(videoID: self.selectedData ?? "")
    }
}

extension DetailsViewController {
    func getAnimeDetails(nameOfAnime: String){
        var nameAnime = nameOfAnime.replacingOccurrences(of: " ", with: "-")
        nameAnime = nameAnime.lowercased()
        let finalAnimeUrl = "\(Constants.shared.ANIME_URL_STREAM)" + "\(Constants.shared.ANIME_STREAM_ENDPOINT)" +  nameAnime
        print(finalAnimeUrl)
        APIParser.shared.parseDataToDict(controller: self, urlString: finalAnimeUrl, parameters: nil, bodyParams: nil, requestType: "GET") { result in
            if let result = result as? [String : Any] {
                if let _ = result["error"] as? [String : Any]{
                    DispatchQueue.main.async{
                        Constants.shared.makeAlertWithAction(controller: self, title: "Alert", message: "Sorry, This Anime is Not Present in Gogoanime With this name") {
                            self.dismiss(animated: true)
                        }
                    }
                }else{
                    let result = AnimeDetailsModel().parseResponse(response: result)
                    DispatchQueue.main.async {[weak self] in
                        guard let self = self else {return}
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.animeModel = result
                        self.tableView.reloadData()
                        self.preparePostViewThing()
                    }
                }
            }
        }
    }
    
    func preparePostViewThing(){
        self.imageViewForAnimeManga.isHidden = false
        self.titleString.isHidden = false
        self.status.isHidden = false
        self.detailsString.isHidden = false
        self.tableView.isHidden = false
        self.detailsTitle.isHidden = false
        self.backBtn.isHidden = false
        self.reverseBtn.isHidden = false
        if let modelAnime  = self.animeModel {
            self.titleString.text = modelAnime.title
            self.status.text = modelAnime.status
            self.detailsString.text = descriptionString ?? ""
            guard let genureArray = self.animeModel?.genres else {return}
            var singleString = ""
            for item in genureArray {
                singleString += " \(item)"
            }
            self.detailsTitle.text = "Genre: " + singleString
            if let imageUrl = self.animeModel?.animeURLImage {
                if let url = URL(string: imageUrl) {
                    self.imageViewForAnimeManga.kf.setImage(with: url)
                }
            }
            
        }
    }
    
    func callVideoAPI(videoID: String) {
        let finalURL = Constants.shared.ANIME_URL_STREAM + Constants.shared.VIDEO_ENDPOINT + videoID
        APIParser.shared.parseDataToDict(controller: self, urlString: finalURL, parameters: nil, bodyParams: nil, requestType: "GET") { result in
            if let result = result as? [String: Any] {
                if let sources = result["sources"] as? [[String:Any]] {
                    if let sSource = sources.first{
                        if let file = sSource["file"] as? String {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.isHidden = true
                                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoPlayerViewController") as? VideoPlayerViewController
                                vc?.modalPresentationStyle = .fullScreen
                                vc?.dataUrl = file
                                self.present(vc ?? UIViewController(), animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
}



