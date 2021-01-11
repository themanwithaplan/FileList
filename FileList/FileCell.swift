//
//  FileCell.swift
//  
//
//  Created by Sharaf Nazaar on 1/9/21.
//
import Foundation
import UIKit

class FileCell: UITableViewCell {

    static let reuseIdentifier = String(describing: FileCell.self)

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
    }
    
    func downloadfile(fileURL: String, fileName: String, completion: @escaping (_ success: Bool,_ fileLocation: URL?) -> Void){
            
        let itemUrl = URL(string: fileURL)
        
        guard let filenameWithExt = fileURL.split(separator: "/").last else {
            completion(false, nil)
            return
        }
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(String(filenameWithExt))
            
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                completion(true, destinationUrl)
            } else {
                URLSession.shared.downloadTask(with: itemUrl!, completionHandler: { (location, response, error) -> Void in
                    guard let tempLocation = location, error == nil else { return }
                    do {
                        try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                        completion(true, destinationUrl)
                    } catch let error {
                        print(error.localizedDescription)
                        completion(false, nil)
                    }
                }).resume()
            }
        }
    
    func update(with file: File) {
        nameLabel.text = file.filename
        descriptionLabel.text = file.fileDescription
        
        if let timeResult = (file.uploadedAt) {
            let date = Date(timeIntervalSince1970: timeResult)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.short
            dateFormatter.dateStyle = DateFormatter.Style.short
            dateFormatter.timeZone = .current
            let localDate = dateFormatter.string(from: date)
            createdAtLabel.text = localDate
        }
        
        //Option 2: to load thumbnail and download file on selection
//        if thumbnailImageView.image == nil && file.url != "" && file.url != nil {
//              let thumbnailSize = CGSize(width: 108, height: 128)
//                file.generatePdfThumbnail(of: thumbnailSize, for: URL(string: file.url!)!, atPage: 0) { [weak self] image in
//                      self?.thumbnailImageView.image = image
//                  }
//        }
        
        downloadfile(fileURL:file.url!, fileName: file.filename! ,completion: {(success, fileLocationURL) in
                    if success {
                        DispatchQueue.main.async {
                        guard let filenameWithExt = file.url!.split(separator: "/").last else {
                            return
                        }
                        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let destinationUrl = documentsDirectoryURL.appendingPathComponent(String(filenameWithExt))
                        self.thumbnailImageView.image = UIImage.icon(forFileURL: destinationUrl, preferredSize: .smallest)
                        }
                    }
            })
    }
}

extension UIImage {
    
    public enum FileIconSize {
            case smallest
            case largest
        }
    
    public class func icon(forFileURL fileURL: URL, preferredSize: FileIconSize = .smallest) -> UIImage {
            let myInteractionController = UIDocumentInteractionController(url: fileURL)
            let allIcons = myInteractionController.icons

            if allIcons.count > 0 {
                switch preferredSize {
                    case .smallest: return allIcons.first!
                    case .largest: return allIcons.last!
                }
            }
            else{
                return UIImage(systemName: "doc")!
            }
        }
}
