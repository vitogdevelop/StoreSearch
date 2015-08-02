//
//  ViewController.swift
//  StoreSearch
//
//  Created by vito on 25/07/15.
//  Copyright (c) 2015 vito. All rights reserved.
//
import Foundation

func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
  return lhs.artistName.localizedStandardCompare(rhs.artistName) == NSComparisonResult.OrderedAscending
}

func > (lhs: SearchResult, rhs: SearchResult) -> Bool {
  return lhs.name.localizedStandardCompare(rhs.name) == NSComparisonResult.OrderedDescending
}

import UIKit

class SearchViewController: UIViewController {
  
  struct TableViewCellIdentifiers {
    static let searchResultCell = "SearchResultCell"
    static let nothtingFoundCell = "NothingFoundCell"
  }
  
  var searchResults = [SearchResult]()
  var hasSearched = false

  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
    
    var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
    cellNib = UINib(nibName: TableViewCellIdentifiers.nothtingFoundCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothtingFoundCell)
    tableView.rowHeight = 80
    
    searchBar.becomeFirstResponder()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func urlWithSearchText(searchText: String) -> NSURL {
    let escapedSearchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    let urlString = String(format: "http://itunes.apple.com/search?term=%@", escapedSearchText)
    let url = NSURL(string: urlString)
    return url!
  }
  
  func performStoreRequestWithURL(url: NSURL) -> String? {
    var error: NSError?
    if let resultString = String(contentsOfURL: url, encoding: NSUTF8StringEncoding, error: &error) {
      return resultString
    } else if let error = error {
      println("Download Error: \(error)")
    } else {
      println("Unknown Download Error")
    }
    return nil
  }
  
  func parseJSON(jsonString: String) -> [String: AnyObject]? {
    if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
      var error: NSError?
      if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as? [String: AnyObject] {
        return json
      } else if let error = error {
        println("JSON Error: \(error)")
      } else {
        println("Unknon JSON Error")
      }
    }
    return nil
  }
  
  func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult] {
    var searchResults = [SearchResult]()
    // 1
    if let array: AnyObject = dictionary["results"] {
      // 2 
      for resultDict in array as! [AnyObject] {
        // 3
        if let resultDict = resultDict as? [String: AnyObject] {
          // 4
          var searchResult: SearchResult?
          
          if let wrapperType = resultDict["wrapperType"] as? String {
            switch wrapperType {
              case "track":
              searchResult = parseTrack(resultDict)
            default:
              break
            }
          }
          if let result = searchResult {
            searchResults.append(result)
          }
          // 5
        } else {
          println("Expected a dictionay")
        }
      }
    } else {
      println("Expected a 'result' array")
    }
    return searchResults
  }
  
  func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    
    searchResult.name = dictionary["trackName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
    searchResult.atrworkURL100 = dictionary["artworkUrl100"] as! String
    searchResult.storeURl = dictionary["trackViewUrl"] as! String
    searchResult.kind = dictionary["kind"] as! String
    searchResult.currency = dictionary["currency"] as! String
    if let price = dictionary["trackPrice"] as? Double {
      searchResult.price = price
    }
    if let genre = dictionary["primaryGenreName"] as? String {
      searchResult.genre = genre
    }
    return searchResult
   }
  
  func kindForDisplay(kind: String) -> String{
    switch kind {
    case "album": return "Album"
    case "audiobook": return "Audio Book"
    case "ebook": return "E-Book"
    case "feature-movie": return "Movie"
    case "Music-video": return "Movie"
    case "podcast": return "Podcast"
    case "software": return "App"
    case "song": return "Song"
    case "tv-episode": return "TV Episide"
    default: return kind
    }
  }
}

extension SearchViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    
    if !searchBar.text.isEmpty {
      searchBar.resignFirstResponder()
      hasSearched = true
      searchResults = [SearchResult]()
      
      let url = urlWithSearchText(searchBar.text)
      println("URL: '\(url)'")
      if let jsonString = performStoreRequestWithURL(url) {
        //println("Received JSON string '\(jsonString)'")
        if let dictionary = parseJSON(jsonString) {
          //println("Dictionary \(dictionary)")
          searchResults = parseDictionary(dictionary)
        searchResults.sort(<)
          tableView.reloadData()
          return
        }
      }
      showNetworkError()
    }
  }
  
  func showNetworkError() {
    let alert = UIAlertController(
      title: "Whoops ...",
      message: "There was an error reading from the iTune Store. Please try again.",
      preferredStyle: .Alert)
    
    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alert.addAction(action)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return .TopAttached
  }
}

extension SearchViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if !hasSearched {
      return 0
    } else if searchResults.count == 0 {
      return 1
    } else {
      return searchResults.count
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if searchResults.count == 0 {
      return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothtingFoundCell, forIndexPath: indexPath) as! UITableViewCell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
      
      let searchResult = searchResults[indexPath.row]
      cell.nameLabel.text = searchResult.name
      if searchResult.artistName.isEmpty {
        cell.artistNameLabel.text = "Unknown"
      } else {
        cell.artistNameLabel.text =  String(format: "%@ (%@)", searchResult.artistName, kindForDisplay(searchResult.kind))
      }
      return cell
    }
  }
}

extension SearchViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if searchResults.count == 0 {
      return nil
    } else {
      return indexPath
    }
  }
  
  
}

