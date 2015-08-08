//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by vito on 01/08/15.
//  Copyright (c) 2015 vito. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var artworkImageView: UIImageView!
  
  var downloadTask: NSURLSessionDownloadTask?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      let selectedView = UIView(frame: CGRect.zeroRect)
      selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
      selectedBackgroundView = selectedView
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  func configureForSearchResult(searchResult: SearchResult) {
    nameLabel.text = searchResult.name
    
    if searchResult.artistName.isEmpty {
      artistNameLabel.text = "Unkonwn"
    } else {
      artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, kindForDisplay(searchResult.kind))
    }
    artworkImageView.image = UIImage(named: "Placeholder")
    if let url = NSURL(string: searchResult.artworkURL60) {
      downloadTask = artworkImageView.loadImageWithURL(url)
    }
  
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
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    downloadTask?.cancel()
    downloadTask = nil
    
    nameLabel.text = nil
    artistNameLabel.text = nil
    artworkImageView.image = nil
    
    // println("prepare for Reuse")
  }

}
