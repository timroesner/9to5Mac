//
//  ViewController.swift
//  9to5Mac
//
//  Created by Tim Roesner on 7/18/17.
//

import UIKit
import SWXMLHash
import SVProgressHUD
import SwiftSoup
import SDWebImage
import SafariServices

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var titles = [String]()
    var imageURLs = [URL]()
    var articleURLs = [URL]()
    var xml: XMLIndexer!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector:#selector(parseXML), name:NSNotification.Name.UIApplicationWillEnterForeground, object:UIApplication.shared
        )
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.isAccessibilityElement = false
        tableView.shouldGroupAccessibilityChildren = true
        
        parseXML()
    }
    
    func parseXML(){
        if(self.isViewLoaded && (self.view.window != nil)){
            SVProgressHUD.show()
        }
        let task = URLSession.shared.dataTask(with: URL(string: "https://9to5mac.com/feed")!) { data, response, error in
            if error != nil {
                print(error as Any)
                return
            }
            // Get XML from RSS feed with SWXMLHash
            let xml = SWXMLHash.parse(data!)
            
            // In case we are reloading remove all old values
            self.titles.removeAll()
            self.articleURLs.removeAll()
            self.imageURLs.removeAll()
            
            // loop through items
            for item in xml["rss"]["channel"]["item"].all {
                self.titles.append(item["title"].element!.text)
                self.articleURLs.append(URL(string: item["link"].element!.text)!)
                
                // To get the thumnail image we need to do some vudu because it's embedded into the description 🙄
                do{
                    let doc = try SwiftSoup.parse((item["description"].element?.text)!)
                    for element in try doc.select("img").array(){
                        let imgSrc = try element.attr("src")
                        // Check if thumbnail and not an image of a pixel ?!
                        if imgSrc.range(of:"9to5mac.files.wordpress.com") != nil {
                            self.imageURLs.append(URL(string: imgSrc)!)
                        }
                    }
                    if(try doc.select("img").array().count == 0){
                        self.imageURLs.append(URL(string: "None")!)
                    }
                }catch Exception.Error( _, let message){
                    print(message)
                }catch{
                    print("error")
                }
            }
            // Get main thread and reload tableView
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! TableViewCell
        cell.thumbnail.sd_setImage(with: imageURLs[indexPath.row])
        cell.title.text = titles[indexPath.row]
        cell.accessibilityLabel = titles[indexPath.row]
        SVProgressHUD.dismiss()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let safariVC = SFSafariViewController(url: articleURLs[indexPath.row], entersReaderIfAvailable: true)
        present(safariVC, animated: true, completion: nil)
    }

}

