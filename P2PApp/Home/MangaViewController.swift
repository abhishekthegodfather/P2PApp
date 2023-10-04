//
//  MangaViewController.swift
//  P2PApp
//
//  Created by Abhishek Biswas on 29/09/23.
//

import Foundation
import UIKit


class MangaViewController: UIViewController {
    
    @IBOutlet weak var searchView : UIView!
    @IBOutlet weak var searchBtn : UIButton!
    @IBOutlet weak var animeLabelView: UIView!
    @IBOutlet weak var searchCancel: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var downloadBtn: UIButton!
    
    var mangaArray : [MangaTileModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        self.getAnimeDataForHome()
        self.prepareForSetup()
        searchBtn.addTarget(self, action: #selector(searchBtnAction(_ :)), for: .touchUpInside)
        searchCancel.addTarget(self, action: #selector(searchCancelBtnAction(_ :)), for: .touchUpInside)
        downloadBtn.addTarget(self, action: #selector(downloadBtnAction(_ :)), for: .touchUpInside)
    }
    
    
    @objc func searchBtnAction(_ sender: UIButton){
        self.searchView.isHidden = false
        self.animeLabelView.isHidden = true
    }
    
    @objc func searchCancelBtnAction(_ sender: UIButton){
        self.searchView.isHidden = true
        self.animeLabelView.isHidden = false
    }
    
    @objc func downloadBtnAction(_ sender: UIButton){
        let downloadVC =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DownloadVC") as? DownloadVC
        downloadVC?.modalPresentationStyle = .fullScreen
        self.present(downloadVC ?? UIViewController(), animated: true)
    }
    
    
    func prepareForSetup(){
        self.searchView.isHidden = true
        collectionView.register(HomeCollectionViewCell.nib(), forCellWithReuseIdentifier: HomeCollectionViewCell.cellID)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func getAnimeDataForHome(){
        let finalURL = Constants.shared.BASE_URL + Constants.shared.MANGA_ENDPOINT
        let getCurrentDate = Date().string(format: "yyyy-MM-dd")
        var dateString : String?
        if let dateBefore30Days = Calendar.current.date(byAdding: .day, value: -365, to: Date()) {
            dateString = dateBefore30Days.string(format: "yyyy-MM-dd")
        }
        let parameterURl : [[String:Any]] = [
            [
                "name" : "start_date",
                "value" : dateString ?? ""
            ],
            [
                "name" : "end_date",
                "value" : getCurrentDate
            ]
        ]
        APIParser.shared.parseDataToDict(controller: self, urlString: finalURL, parameters: parameterURl, bodyParams: nil, requestType: "get") {[weak self] result in
            guard let self = self else {return}
            if let resultResponse =  result as? [String: Any] {
                let resultArray : [MangaTileModel] = MangaTileModel().parseResponse(responseDict: resultResponse)
                self.mangaArray = resultArray
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

extension MangaViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mangaArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let animeCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.cellID, for: indexPath) as? HomeCollectionViewCell
        animeCell?.imageAnimePreview.layer.cornerRadius = 10
        animeCell?.animeName.text = self.mangaArray[indexPath.row].title ?? ""
        if let imageUrl = self.mangaArray[indexPath.row].mangaProfileImage {
            if let url = URL(string: imageUrl) {
                animeCell?.imageAnimePreview.kf.setImage(with: url)
            }
        }
        
        return animeCell ?? UICollectionViewCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.frame.size.width / 3
        return CGSize(width: width, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mangaVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsMangaViewController") as? DetailsMangaViewController
        mangaVC?.modalPresentationStyle = .fullScreen
        mangaVC?.titleStringForManga = self.mangaArray[indexPath.row].title ?? ""
        mangaVC?.imageUrl = self.mangaArray[indexPath.row].mangaProfileImage ?? ""
        self.present(mangaVC ?? UIViewController(), animated: true, completion: nil)
    }
}
