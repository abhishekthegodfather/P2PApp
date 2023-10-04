//
//  DownloadVC.swift
//  P2PApp
//
//  Created by Abhishek Biswas on 04/10/23.
//

import UIKit

class DownloadVC: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var backBtn : UIButton!
    var imageArray : [DownlaodMangaModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageArray = self.fetchImagesAndChapterNameFromCoreDB()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AnimeEpisodeCell.nib(), forCellReuseIdentifier: AnimeEpisodeCell.cellId)
        backBtn.addTarget(self, action: #selector(backAction(_ :)), for: .touchUpInside)
    }
    
    @objc func backAction(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}

extension DownloadVC {
    func fetchImagesAndChapterNameFromCoreDB() -> [DownlaodMangaModel] {
        var imageModel: [DownlaodMangaModel] = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return imageModel
        }
        do {
            let managedObjectContext = appDelegate.persistentContainer.viewContext
            let fetchMangaName = try managedObjectContext.fetch(Manga.fetchRequest()) as? [Manga]
            let fetchMangaImage = try managedObjectContext.fetch(MangaImage.fetchRequest()) as? [MangaImage]
            
            guard let mangas = fetchMangaName, let mangaImages = fetchMangaImage else {
                return imageModel
            }
            
            for manga in mangas {
                var imageData: [Data] = []
                
                for mangaImage in mangaImages {
                    if manga.id == mangaImage.id, let image = mangaImage.imageChapter {
                        imageData.append(image)
                    }
                }
                
                let singleImageModel = DownlaodMangaModel(title: manga.name ?? "", imageData: imageData, chpaterId: manga.id ?? "")
                imageModel.append(singleImageModel)
            }
        } catch {
            Constants.shared.makeAlert(controller: self, title: "Alert!!", message: "Sorry, Cannot Open Chapter Offline!!")
            print("Error fetching data: \(error)")
        }
        
        return imageModel
    }
}


extension DownloadVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.imageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let downloadCell = tableView.dequeueReusableCell(withIdentifier: AnimeEpisodeCell.cellId, for: indexPath) as? AnimeEpisodeCell
        downloadCell?.episodeLabel.text = self.imageArray[indexPath.row].title
        downloadCell?.selectionStyle = .none
        return downloadCell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let imageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController
        imageVC?.isDownloaded = true
        imageVC?.imageArray = self.imageArray[indexPath.row].imageData
        imageVC?.mangaTitle = self.imageArray[indexPath.row].title
        imageVC?.imageIDChapeter = self.imageArray[indexPath.row].chpaterId
        imageVC?.modalPresentationStyle = .fullScreen
        self.present(imageVC ?? UIViewController(), animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?{
        let DeleteAction = UIContextualAction(style: .normal, title:  "Delete Chapter", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let removedModel = self.imageArray.remove(at: indexPath.row)
            do{
                let fetchMangaRequest = Manga.fetchRequest()
                let fetchMangaImageRequest = MangaImage.fetchRequest()
                fetchMangaRequest.predicate = NSPredicate(format: "id == %@", removedModel.chpaterId)
                fetchMangaImageRequest.predicate = NSPredicate(format: "id == %@", removedModel.chpaterId)
                let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
                guard let contxt = appDelegate?.persistentContainer.viewContext else {return}
                let tasks = try contxt.fetch(fetchMangaRequest)
                let tasks2 = try contxt.fetch(fetchMangaImageRequest)
                guard let fetchObj = tasks.first else {return}
                guard let fetchObj1 = tasks2.first else {return}
                contxt.delete(fetchObj)
                contxt.delete(fetchObj1)
                appDelegate?.saveContext()
                print("Object Deleted from DB")
                Constants.shared.makeAlert(controller: self, title: "Alert!!", message: "Chapter Deleted")
            }catch{
                Constants.shared.makeAlert(controller: self, title: "Alert!!", message: "Sorry, Failed to Delete Chapter")
            }
            self.tableView.reloadData()
            success(true)
        })
        DeleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [DeleteAction])
    }
}
