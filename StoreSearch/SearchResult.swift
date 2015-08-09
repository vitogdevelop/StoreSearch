//
//  SearchResult.swift
//  StoreSearch
//
//  Created by vito on 26/07/15.
//  Copyright (c) 2015 vito. All rights reserved.
//

class SearchResult {
  var name = ""
  var artistName = ""
  var artworkURL60 = ""
  var artworkURL100 = ""
  var storeURL = ""
  var kind = ""
  var currency = ""
  var price = 0.0
  var genre = ""

  func kindForDisplay() -> String{
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
