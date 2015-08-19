//
//  Search.swift
//  StoreSearch
//
//  Created by vito on 18/08/15.
//  Copyright (c) 2015 vito. All rights reserved.
//

import Foundation

typealias SearchComplete = (Bool) -> Void

class Search {
  var searchResults = [SearchResult]()
  var hasSearched = false
  var isLoading = false
  
  private var dataTask: NSURLSessionDataTask? = nil
  
  func performeSearchForText(text: String, category: Int, completion: SearchComplete) {
    
    if !text.isEmpty {
    dataTask?.cancel()
      
    isLoading = true
    hasSearched = true
    searchResults = [SearchResult]()
    
    // 1
    let url = self.urlWithSearchText(text, category: category)
    
    // 2
    let session = NSURLSession.sharedSession()
    // 3
    dataTask = session.dataTaskWithURL(url, completionHandler: {
      data, response, error in
      // 4
      var success = false
      if let error = error {
        if error.code == -999 {return}
      } else if let httpResponse = response as? NSHTTPURLResponse {
        if httpResponse.statusCode == 200 {
          if let dictionary = self.parseJSON(data){
            self.searchResults = self.parseDictionary(dictionary)
            self.searchResults.sort(<)
    
            println("Success!")
            self.isLoading = false
            success = true
          }
        }
      }
      if !success {
        self.hasSearched = false
        self.isLoading = false
      }
      
      dispatch_async(dispatch_get_main_queue()) {
        completion(success)
      }
      })
    // 5
    dataTask?.resume()
    }
  }
  
  private func urlWithSearchText(searchText: String, category: Int) -> NSURL {
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
  
  private func parseJSON(data: NSData) -> [String: AnyObject]? {
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
  
  private func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult] {
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
  
  private func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    
    searchResult.name = dictionary["trackName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
    searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
    searchResult.storeURL = dictionary["trackViewUrl"] as! String
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
