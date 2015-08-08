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
    static let loadingCell = "LoadingCell"
  }
  
  var searchResults = [SearchResult]()
  var hasSearched = false
  var isLoading = false
  var dataTask: NSURLSessionDataTask?

  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  
  @IBAction func segmentedChanged(sender: UISegmentedControl) {
    performSearch()
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
    
    var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
    cellNib = UINib(nibName: TableViewCellIdentifiers.nothtingFoundCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothtingFoundCell)
    cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
    tableView.rowHeight = 80
    
    searchBar.becomeFirstResponder()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func urlWithSearchText(searchText: String, category: Int) -> NSURL {
    var entityName: String
    switch category {
    case 1: entityName = "musicTrack"
    case 2: entityName = "software"
    case 3: entityName = "ebook"
    default: entityName = ""
    }
    let escapedSearchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    let urlString = String(format: "http://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, entityName)
    println(urlString)
    let url = NSURL(string: urlString)
    return url!
  }
  
  func parseJSON(data: NSData) -> [String: AnyObject]? {
    var error: NSError?
    if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as? [String: AnyObject] {
      return json
    } else if let error = error {
        println("JSON Error: \(error)")
    } else {
        println("Unknon JSON Error")
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
}

extension SearchViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    performSearch()
  }
  
  func performSearch() {
    searchBar.resignFirstResponder()
    
    if !searchBar.text.isEmpty {
      searchBar.resignFirstResponder()
      
      dataTask?.cancel()
      isLoading = true
      tableView.reloadData()

      hasSearched = true
      searchResults = [SearchResult]()
      
      // 1
      let url = self.urlWithSearchText(searchBar.text, category: segmentedControl.selectedSegmentIndex)
      
      // 2
      let session = NSURLSession.sharedSession()
      // 3
      dataTask = session.dataTaskWithURL(url, completionHandler: {
        data, response, error in
        // 4
        if let error = error {
          println("Falilure! \(error)")
          if error.code == -999 {return}
        } else if let httpResponse = response as? NSHTTPURLResponse {
          if httpResponse.statusCode == 200 {
            if let dictionary = self.parseJSON(data){
              self.searchResults = self.parseDictionary(dictionary)
              self.searchResults.sort(<)

              dispatch_async(dispatch_get_main_queue()) {
                self.isLoading = false
                self.tableView.reloadData()
              }
              return
          } else {
            println("Failure! \(response)")
          }
        }
        }
        dispatch_async(dispatch_get_main_queue()) {
          self.hasSearched = false
          self.isLoading = false
          self.tableView.reloadData()
          self.showNetworkError()
        }
      })
      // 5
      dataTask?.resume()
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
  if isLoading {
  return 1
  } else if !hasSearched {
      return 0
    } else if searchResults.count == 0 {
      return 1
    } else {
      return searchResults.count
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if  isLoading {
    let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as! UITableViewCell
    let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
    spinner.startAnimating()
    return cell
  }
    else if searchResults.count == 0 {
      return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothtingFoundCell, forIndexPath: indexPath) as! UITableViewCell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
      
      let searchResult = searchResults[indexPath.row]
      cell.configureForSearchResult(searchResult)
      return cell
    }
  }
}

extension SearchViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if searchResults.count == 0 || isLoading {
      return nil
    } else {
      return indexPath
    }
  }
  
  
}

