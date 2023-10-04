//
//  ImageViewController.swift
//  P2PApp
//
//  Created by Abhishek Biswas on 03/10/23.
//

import UIKit
import DropDown
import CoreData

class ImageViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityStackView : UIStackView!
    
    var imageIDChapeter: String?
    var chapterArray : [MangaImageModel] = []
    var imageArray : [Data] = []
    var mangaTitle : String?
    var isDownloaded : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if !self.isDownloaded {
            self.activityIndicator.startAnimating()
            self.fetchImageChpater(imageiD: imageIDChapeter ?? "")
        }else{
            self.activityStackView.isHidden = true
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MangaCollectionViewCell.nib(), forCellWithReuseIdentifier: MangaCollectionViewCell.cellID)
    }

}

extension ImageViewController {
    func fetchImageChpater(imageiD: String){
        let finalUrl = Constants.shared.MANGA_STREAM_URL + Constants.shared.MANGA_ENDPOINT_STREAM + "read?chapterId=\(imageiD)"
        print(finalUrl)
        APIParser.shared.parseDataToArray(controller: self, urlString: finalUrl, parameters: nil, bodyParams: nil, requestType: "GET") { result in
            if let response = result as? [[String: Any]] {
                let responseParsed = MangaImageModel.parseResult(response: response)
                self.chapterArray = responseParsed
                self.fetchImage(model: self.chapterArray)
            }
        }
    }
    
    func fetchImage(model: [MangaImageModel]) {
        var tempArray : [Data] = []
        let dispatchGroup = DispatchGroup()

        for item in model {
            dispatchGroup.enter()
            guard let url = URL(string: item.imageUrl ?? "") else {
                dispatchGroup.leave()
                continue
            }
            
            var urlReq = URLRequest(url: url)
            urlReq.httpMethod = "GET"
            urlReq.addValue(item.headerForImage ?? "", forHTTPHeaderField: "Referer")
            let dataTask = URLSession.shared.dataTask(with: urlReq) { (data, response, error) in
                defer { dispatchGroup.leave() }

                if error != nil {
                    DispatchQueue.main.async {
                        Constants.shared.makeAlertWithAction(controller: self, title: "Alert!!", message: "Sorry, Cannot Fetch Chapter For this Manga") {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                if let data = data {
                    DispatchQueue.global(qos: .background).async {
                        tempArray.append(data)
                    }
                }
            }
            dataTask.resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.activityIndicator.stopAnimating()
            self.activityStackView.isHidden = true
            self.imageArray = tempArray
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

}

extension ImageViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArray.count
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: MangaCollectionViewCell.cellID, for: indexPath) as? MangaCollectionViewCell
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        swipeLeft.direction = .right
        collectionCell?.addGestureRecognizer(swipeLeft)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(socialViewTapped(_ :)))
        tapGestureRecognizer.numberOfTapsRequired = 2
        collectionCell?.addGestureRecognizer(tapGestureRecognizer)
        collectionCell?.isUserInteractionEnabled = true
        collectionCell?.imageManga.image = UIImage(data: self.imageArray[indexPath.row])
        return collectionCell ?? UICollectionViewCell()
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            self.dismiss(animated: true)
        }
    }
    
    @objc func socialViewTapped(_ sender: UITapGestureRecognizer){
        if let tappedView = sender.view {
            let tapLocation = sender.location(in: tappedView)
            let dummyView = UIView(frame: CGRect(x: tapLocation.x, y: tapLocation.y, width: 100, height: 70))
            dummyView.backgroundColor = .clear
            tappedView.addSubview(dummyView)
            
            let dropDown = DropDown()
            dropDown.anchorView = dummyView
            dropDown.dataSource = ["Download This Chapter"]
            dropDown.selectionAction = {(index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                switch index {
                case 0:
                    self.saveChapterInCoreData(images: self.imageArray, chapterID: self.imageIDChapeter ?? "", chapterName: self.mangaTitle ?? "")
                    break
                default:
                    print("Cannot Download the Chapter")
                }
            }
            dropDown.width = 200
            dropDown.cellHeight = 70
            dropDown.show()
        }
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.size.width, height: self.collectionView.frame.size.height)
    }
}


extension ImageViewController {
    func saveChapterInCoreData(images:[Data], chapterID: String, chapterName: String){
        let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
        guard let context = appDelegate?.persistentContainer.viewContext else {return}
        let mangaOfflineModel = Manga(context: context)
        mangaOfflineModel.id = chapterID
        mangaOfflineModel.name = chapterName
        for item in images {
            let mangaImageOfflineModel = MangaImage(context: context)
            mangaImageOfflineModel.id = chapterID
            mangaImageOfflineModel.imageChapter = item
        }
        do{
            try context.save()
            Constants.shared.makeAlert(controller: self, title: "Alert!!", message: "Chapter Downloaded!!")
        }catch{
            Constants.shared.makeAlert(controller: self, title: "Alert!!", message: "Sorry, Chapter Failed to Download!!!")
        }
    }
}
