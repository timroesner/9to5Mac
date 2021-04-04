//
//  ArticleWidget.swift
//  9to5Mac
//
//  Created by Tim Roesner on 4/3/21.
//

import SwiftUI
import WidgetKit
import CoreUI
import Kingfisher

@main
struct ArticleWidget: Widget {
    private let kind: String = "article_widget"
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ArticleProvider()) { entry in
            ArticleWidgetView(entry: entry)
        }
        .configurationDisplayName("9to5Mac")
        .description("This widget displays the latest article from 9to5Mac")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ArticleWidgetView: View {
    let entry: ArticleEntry
    
    var body: some View {
        GeometryReader { reader in
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
                thumbnail
                    .zIndex(-10)
                    .frame(width: reader.size.width, height: reader.size.height)
                    .clipped()
                titleLabel
                    .zIndex(1)
            }
        }
    }
    
    @ViewBuilder
    var thumbnail: some View {
        if let image = entry.thumbnail {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Image("Placeholder")
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
    
    var titleLabel: some View {
        Text(entry.title)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .font(.headlineSmallStyle)
            .padding(.all, .standardMargin)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .background(linearGradient)
    }
    
    var linearGradient: some View {
        LinearGradient(
            gradient: Gradient(stops: [.init(color: .clear, location: 0), .init(color: Color.black.opacity(0.75), location: 0.35)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct WidgetPreviews: PreviewProvider {
    static let testEntry = ArticleEntry(
        date: Date(),
        title: "A long enough test title to see the layout with two lines",
        thumbnail: nil,
        relevance: nil
    )
    
    static var previews: some View {
        Group {
            ArticleWidgetView(entry: testEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            ArticleWidgetView(entry: testEntry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
