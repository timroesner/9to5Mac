//
//  ViewController.swift
//  9to5Mac
//
//  Created by Tim Roesner on 7/18/17.
//

import UIKit
import SWXMLHash
import SwiftSoup
import Kingfisher
import SafariServices
import CoreUI

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var articles = [Article]()

    @IBOutlet weak var tableView: UITableView!
    
    private let loadingSpinner = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector:#selector(fetchArticles), name: UIApplication.willEnterForegroundNotification, object: nil)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.isAccessibilityElement = false
        tableView.shouldGroupAccessibilityChildren = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 275
		tableView.separatorStyle = .none
        
        loadingSpinner.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            loadingSpinner.style = .large
        }
        view.addAutoLayoutSubview(loadingSpinner)
        NSLayoutConstraint.activate([
            loadingSpinner.centerYAnchor ≈ view.safeAreaLayoutGuide.centerYAnchor,
            loadingSpinner.centerXAnchor ≈ view.safeAreaLayoutGuide.centerXAnchor,
        ])
        
        fetchArticles()
    }
    
    @objc func fetchArticles() {
        loadingSpinner.startAnimating()
        API.fetchArticles { [weak self] articles in
            self?.articles = articles
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.loadingSpinner.stopAnimating()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! TableViewCell
        let article = articles[safe: indexPath.row]
        cell.thumbnail.kf.setImage(with: article?.thumbnailURL, placeholder: #imageLiteral(resourceName: "Placeholder"))
        cell.title.text = article?.title
        cell.accessibilityLabel = article?.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = true
        let safariVC = SFSafariViewController(url: articles[indexPath.row].url, configuration: configuration)
        present(safariVC, animated: true, completion: nil)
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
