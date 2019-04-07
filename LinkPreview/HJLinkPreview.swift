//
//  HJLinkPreview.swift
//  LinkPreview
//
//  Created by Manu Singh on 07/04/19.
//  Copyright © 2019 Manu Singh. All rights reserved.
//

import Foundation

typealias linkPreviewHandler = (NGLinkPreview)->Void

func generatePreview(for linkUrl : String, completion:@escaping linkPreviewHandler){
    getLinkHtml(url: linkUrl, completion: {
        htmlString in
        guard htmlString != nil else { return }
        DispatchQueue.main.async {
            completion(createHTMLPreview(html: htmlString!, url: linkUrl))
        }
    })
}

fileprivate func getLinkHtml(url : String, completion : @escaping (String?)->Void){
    sendUrlRequest(url: url, completion: completion)
}

fileprivate func sendUrlRequest(url:String, completion : @escaping (String?)->Void){
    
    guard let httpUrl = URL(string: url) else { return }
    
    let task = URLSession.shared.dataTask(with: httpUrl, completionHandler: {
        data, response, error in
        guard error == nil else { return }
        guard data != nil else { return }
        completion(convertToString(data: data!))
    })
    task.resume()
    
}

fileprivate func convertToString(data : Data)->String?{
    let convertedString = String(data: data, encoding: .utf8)
    return convertedString
}

fileprivate func createHTMLPreview(html : String, url : String)-> NGLinkPreview{
    
    let title = html.getStringFor(startTag: "<title", endTag: "</title>", separator: ">")
    let imagePath = html.getMetaTag(startTag: "<meta property=\"og:image\"", endTag: ">")
    let imageUrl = checkBaseUrl(string: imagePath, url: url)
    let description = html.getStringFor(startTag: "<meta property=\"og:description\"", endTag: ">", separator: "=")
    
    return NGLinkPreview(url: url, title: title, imageUrl: imageUrl, description: description)
    
}

fileprivate func checkBaseUrl(string : String,url:String)->String {
    if !string.contains("http") {
        return "\(url)\(string)"
    }
    return string
}



class NGLinkPreview: NSObject {
    var url : String
    var title : String?
    var previewImageUrl : String?
    var linkDescription : String?
    
    init(url : String, title:String?, imageUrl : String?, description:String?) {
        self.url = url
        self.title = title
        self.previewImageUrl = imageUrl
        self.linkDescription = description
    }
}

extension String {
    func getLink()->String?{
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        
        for match in matches {
            guard let range = Range(match.range, in: self) else { continue }
            let url = self[range]
            return String(url)
        }
        return nil
    }
    
    func getStringFor(startTag : String, endTag : String,separator : String)-> String{
        let titleSubstring = getTextBetween(startTag: startTag, endTag: endTag)
        return String(titleSubstring).components(separatedBy: separator).last ?? ""
        
    }
    
    func getTextBetween(startTag : String, endTag : String)->String{
        let titleStartRange = self.range(of: startTag,options: .caseInsensitive)
        guard titleStartRange != nil else { return "" }
        let lastRange = Range(uncheckedBounds: (titleStartRange!.upperBound,self.endIndex))
        let titleEndRange = self.range(of: endTag, options: .caseInsensitive, range: lastRange, locale: nil)
        
        guard titleEndRange != nil else { return "" }
        
        let titleRange = Range(uncheckedBounds: (titleStartRange!.upperBound,titleEndRange!.lowerBound))
        let titleSubstring = self[titleRange]
        var stringBetween = String(titleSubstring)
        if "\(stringBetween.last!)" == "/" {
            stringBetween.removeLast()
        }
        
        return stringBetween
    }
    
    func getMetaTag(startTag : String, endTag : String)->String{
        let ogImageMetaContent = getStringFor(startTag: startTag, endTag: endTag, separator: "=")
        return ogImageMetaContent.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: " ", with: "")
    }
    
}
