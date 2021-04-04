//
//  API.swift
//  9to5Mac
//
//  Created by Tim Roesner on 4/3/21.
//

import SWXMLHash
import SwiftSoup
import Foundation

enum API {
    static func fetchArticles(completion: @escaping ([Article]) -> Void) {
        let task = URLSession.shared.dataTask(with: URL(string: "https://9to5mac.com/feed")!) { data, response, error in
            if let error = error {
                print(error)
                return
            }
            
            var articles = [Article]()
            
            let xml = SWXMLHash.parse(data!)
            
            for item in xml["rss"]["channel"]["item"].all {
                let title = item["title"].element?.text ?? "Title"
                guard let url = URL(string: item["link"].element?.text ?? "") else { continue }
                
                // To get the thumbnail image we need to do some vudu because it's embedded into the description 🙄
                let thumbnailURL: URL?
                do {
                    let description = try SwiftSoup.parse(item["description"].element?.text ?? "")
                    if let images = try? description.select("img").array(), !images.isEmpty {
                        let imageURLs = try images.compactMap { image -> URL? in
                            let imgSrc = try image.attr("src")
                            guard imgSrc.range(of:"9to5mac.com/wp-content") != nil, let url = URL(string: imgSrc) else { return nil }
                            return url
                        }
                        thumbnailURL = imageURLs.first
                    } else {
                        thumbnailURL = nil
                    }
                } catch {
                    print(error)
                    thumbnailURL = nil
                }
                
                articles.append(Article(title: title, thumbnailURL: thumbnailURL, url: url))
            }
            completion(articles)
        }
        task.resume()
    }
}
