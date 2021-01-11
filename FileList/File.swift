//
//  Files.swift
//  FileList
//
//  Created by Sharaf Nazaar on 1/9/21.
//

import Foundation

// MARK: - File
class File: Codable {
    let filename: String?
    let url: String?
    let fileDescription: String?
    let uploadedAt: Double?

    enum CodingKeys: String, CodingKey {
        case filename, url
        case fileDescription = "description"
        case uploadedAt
    }

    init(filename: String, url: String, fileDescription: String, uploadedAt: Double) {
        self.filename = filename
        self.url = url
        self.fileDescription = fileDescription
        self.uploadedAt = uploadedAt
    }
}

typealias Files = [File]


//Option 2: to load thumbnail and download file on selection
//extension File {
//
//    func generatePdfThumbnail(of thumbnailSize: CGSize , for documentUrl: URL, atPage pageIndex: Int, completion: @escaping (UIImage) -> Void) {
//        let pdfDocument = PDFDocument(url: documentUrl)
//        let pdfDocumentPage = pdfDocument?.page(at: pageIndex)
//        if let thumbnail = pdfDocumentPage?.thumbnail(of: thumbnailSize, for: PDFDisplayBox.trimBox) {
//          completion(thumbnail)
//        } else  {
//
//        }
//    }
//}

