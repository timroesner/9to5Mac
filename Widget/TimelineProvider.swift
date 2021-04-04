//
//  Widget.swift
//  Widget
//
//  Created by Tim Roesner on 4/3/21.
//

import WidgetKit
import SwiftUI

struct ArticleEntry: TimelineEntry {
    let date: Date
    let title: String
    let thumbnail: UIImage?
    let relevance: TimelineEntryRelevance?
}

extension ArticleEntry {
    init(_ article: Article) {
        self.date = Date()
        self.title = article.title
        self.relevance = .init(score: 25)
        
        let thumbnail: UIImage?
        if let thumbnailURL = article.thumbnailURL, let imageData = try? Data(contentsOf: thumbnailURL) {
            thumbnail = UIImage(data: imageData)
        } else {
            thumbnail = nil
        }
        self.thumbnail = thumbnail
    }
}

struct ArticleProvider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping (ArticleEntry) -> Void) {
        API.fetchArticles { articles in
            guard let article = articles.first else { return }
            completion(ArticleEntry(article))
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ArticleEntry>) -> Void) {
        API.fetchArticles { articles in
            guard let article = articles.first else { return }
            let timeline = Timeline(entries: [ArticleEntry(article)], policy: .after(Date() + 15 * 60))
            completion(timeline)
        }
    }
    
    func placeholder(in context: Context) -> ArticleEntry {
        ArticleEntry(date: Date(), title: "Some article title that is long enough to be in two lines", thumbnail: nil, relevance: nil)
    }
}
