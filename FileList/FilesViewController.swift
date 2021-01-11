//
//  FilesViewController.swift
//  FileList
//
//  Created by Sharaf Nazaar on 1/9/21.
//

import UIKit
import QuickLook

class FilesViewController: UIViewController {
    lazy var previewItem = NSURL()
    var ascendingName = true
    var ascendingDate = false
    @IBOutlet weak var filesTableView: UITableView!
    var allFiles: [File] = []
    private let refreshControl = UIRefreshControl()
    
    internal var nameSortAction: UIAction!
    internal var menuBarButton : UIBarButtonItem!
    internal var createdAtSortAction: UIAction!


    @objc private func refreshData(_ sender: Any) {
        self.refreshControl.endRefreshing()
        loadFilesData()
    }

    func loadFilesData() {
        let api = APIClient()
        api.getFiles(completionHandler: { (response, error) in
            if let response = response {
                self.allFiles = response
                DispatchQueue.main.async {
                    self.filesTableView.reloadData()
                }
            }
            else {
                DispatchQueue.main.async {
                    self.showMessage("An unknown error occured. Please try Again")
                }
            }
        })
    }
    
    func addBarButton(){
        nameSortAction = UIAction(title: "Name", image: nil, state: .off) { action in
            if self.ascendingName {
                self.allFiles.sort(by: {$0.filename! < $1.filename!})
                self.ascendingName = false
            }
            else {
                self.allFiles.sort(by: {$0.filename! > $1.filename!})
                self.ascendingName = true
            }
            self.filesTableView.reloadData()
        }
        
        createdAtSortAction = UIAction(title: "Date", image: nil, state: .off) { action in
                if self.ascendingDate {
                    self.allFiles.sort(by: {$0.uploadedAt! < $1.uploadedAt!})
                    self.ascendingDate = false
                }
                else {
                    self.allFiles.sort(by: {$0.uploadedAt! > $1.uploadedAt!})
                    self.ascendingDate = true
                }
            self.filesTableView.reloadData()
        }
        
        menuBarButton = UIBarButtonItem(
                title: "Sort",
                image: UIImage(systemName:"arrow.up.arrow.down.square"),
                primaryAction: nil,
                menu: UIMenu(title: "", children: [nameSortAction, createdAtSortAction])
            )
        self.navigationItem.rightBarButtonItem = menuBarButton
    }
    
    func showMessage (_ message : String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    func setTableView(){
        filesTableView.delegate = self
        filesTableView.dataSource = self
        filesTableView.register(UINib(nibName: "FileCell", bundle: nil), forCellReuseIdentifier: "fileCell")
        filesTableView.separatorStyle = .singleLine
        
        if #available(iOS 10.0, *) {
            filesTableView.refreshControl = refreshControl
        } else {
            filesTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Files Data ...", attributes: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBarButton()
        self.title = "Files"
        setTableView()
        loadFilesData()
    }

    //Option 2: to load thumbnail and download file on selection
//    func downloadfile(fileURL: String, fileName: String, completion: @escaping (_ success: Bool,_ fileLocation: URL?) -> Void){
//
//        let itemUrl = URL(string: fileURL)
//
//        guard let filenameWithExt = fileURL.split(separator: "/").last else {
//            completion(false, nil)
//            return
//        }
//            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let destinationUrl = documentsDirectoryURL.appendingPathComponent(String(filenameWithExt))
//
//            if FileManager.default.fileExists(atPath: destinationUrl.path) {
//                completion(true, destinationUrl)
//            } else {
//                URLSession.shared.downloadTask(with: itemUrl!, completionHandler: { (location, response, error) -> Void in
//                    guard let tempLocation = location, error == nil else { return }
//                    do {
//                        try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
//                        completion(true, destinationUrl)
//                    } catch let error as Error {
//                        print(error.localizedDescription)
//                        completion(false, nil)
//                    }
//                }).resume()
//            }
//    }
}

extension FilesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFiles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 89
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath) as! FileCell
        cell.update(with: allFiles[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFile = allFiles[indexPath.row]
        guard let filenameWithExt = selectedFile.url!.split(separator: "/").last else {
            return
        }
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(String(filenameWithExt))
        self.previewItem = destinationUrl as NSURL
        let quickLookViewController = QLPreviewController()
        quickLookViewController.dataSource = self
        quickLookViewController.delegate = self
        self.present(quickLookViewController, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        //Option 2: to load thumbnail and download file on selection
//        self.downloadfile(fileURL:selectedFile.url!, fileName: selectedFile.filename! ,completion: {(success, fileLocationURL) in
//                    if success {
//                        DispatchQueue.main.async {
//                        self.previewItem = fileLocationURL! as NSURL
//                        let quickLookViewController = QLPreviewController()
//                        quickLookViewController.dataSource = self
//                        quickLookViewController.delegate = self
//                        self.present(quickLookViewController, animated: true)
//                        }
//                    }else{
//                        self.showMessage("Unable to download the file")
//                    }
//            })
        
    }
}

// MARK: - QLPreviewControllerDataSource
extension FilesViewController: QLPreviewControllerDataSource {
  func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
    1
  }
  func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
    return self.previewItem as QLPreviewItem
  }
}

// MARK: - QLPreviewControllerDelegate
extension FilesViewController: QLPreviewControllerDelegate {
    func previewController(_ controller: QLPreviewController, shouldOpen url: URL, for item: QLPreviewItem) -> Bool {
        return true
    }
}
