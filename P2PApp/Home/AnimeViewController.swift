//
//  ViewController.swift
//  P2PApp
//
//  Created by Abhishek Biswas on 29/09/23.
//

import UIKit
import DropDown


class AnimeViewController: UIViewController {
    
    @IBOutlet weak var searchView : UIView!
    @IBOutlet weak var searchBtn : UIButton!
    @IBOutlet weak var animeLabelView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var searchBarTextBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var animeArray : [AnimeTileModel] = []
    var filteredAnimeList: [AnimeTileModel] = []
    var isSearching : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        self.getAnimeDataForHome()
        self.prepareForSetup()
        searchBarTextBar.delegate = self
        searchBtn.addTarget(self, action: #selector(searchBtnAction(_ :)), for: .touchUpInside)
        moreBtn.addTarget(self, action: #selector(dropDownAction(_ :)), for: .touchUpInside)
    }
    
    
    @objc func searchBtnAction(_ sender: UIButton){
        self.searchView.isHidden = false
        self.animeLabelView.isHidden = true
    }
    
    @IBAction func searchCancelBtnAction(_ sender: UIButton){
        self.searchView.isHidden = true
        self.animeLabelView.isHidden = false
        self.isSearching = false
        self.searchBarTextBar.text = ""
        self.searchBarTextBar.endEditing(true)
        self.collectionView.reloadData()
    }
    
    
    func prepareForSetup(){
        self.searchView.isHidden = true
        collectionView.register(HomeCollectionViewCell.nib(), forCellWithReuseIdentifier: HomeCollectionViewCell.cellID)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func getAnimeDataForHome(){
        let finalURL = Constants.shared.BASE_URL + Constants.shared.ANIME_ENDPOINT
        let getCurrentDate = Date().string(format: "yyyy-MM-dd")
        var dateString : String?
        if let dateBefore30Days = Calendar.current.date(byAdding: .day, value: -90, to: Date()) {
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
                let resultArray : [AnimeTileModel] = AnimeTileModel().parseResponse(responseDict: resultResponse)
                self.animeArray = resultArray
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidesWhenStopped = true
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

extension AnimeViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isSearching {
            return self.filteredAnimeList.count
        }else{
            return self.animeArray.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let animeCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.cellID, for: indexPath) as? HomeCollectionViewCell
        animeCell?.imageAnimePreview.layer.cornerRadius = 10
        if !self.isSearching {
            animeCell?.animeName.text = self.animeArray[indexPath.row].title ?? ""
            if let imageUrl = self.animeArray[indexPath.row].animeProfileImage {
                if let url = URL(string: imageUrl) {
                    animeCell?.imageAnimePreview.kf.setImage(with: url)
                }
            }
        }else {
            animeCell?.animeName.text = self.filteredAnimeList[indexPath.row].title ?? ""
            if let imageUrl = self.filteredAnimeList[indexPath.row].animeProfileImage {
                if let url = URL(string: imageUrl) {
                    animeCell?.imageAnimePreview.kf.setImage(with: url)
                }
            }
        }
        return animeCell ?? UICollectionViewCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.frame.size.width / 3
        return CGSize(width: width, height: 250)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController
        detailsVC?.modalPresentationStyle = .fullScreen
        detailsVC?.animeTitle = self.animeArray[indexPath.row].title
        detailsVC?.descriptionString = self.animeArray[indexPath.row].status
        self.present(detailsVC ?? UIViewController(), animated: true, completion: nil)
    }
    
    
    @IBAction func dropDownAction(_ sender: UIButton){
        let dropDown = DropDown()
        dropDown.anchorView = sender
        dropDown.dataSource = ["Filter Via Date", "Filter Via Genre"]
        dropDown.selectionAction = {(index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            switch index {
            case 0:
                break
            case 1:
                break
            default:
                print("No Filter Option Found!!")
            }
        }
        dropDown.width = 200
        dropDown.show()
    }
}

extension AnimeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.filteredAnimeList = self.animeArray
        } else {
            self.isSearching = true
            self.filteredAnimeList = self.animeArray.filter { anime in
                return anime.title?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
        collectionView.reloadData()
    }
}

