//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by vito on 15/08/15.
//  Copyright (c) 2015 vito. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {
  
  var search: Search!
  private var firstTime = true
  private var downloadTasks = [NSURLSessionDownloadTask]()
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var pageControl: UIPageControl!
  
  @IBAction func pageChanged(sender: UIPageControl) {
    UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: {
      self.scrollView.contentOffset = CGPoint(
        x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage), y:0)
      }, completion: nil)
  }
  

    override func viewDidLoad() {
      super.viewDidLoad()
      
      view.removeConstraints(view.constraints())
      view.setTranslatesAutoresizingMaskIntoConstraints(true)
      
      pageControl.removeConstraints(pageControl.constraints())
      pageControl.setTranslatesAutoresizingMaskIntoConstraints(true)
      
      scrollView.removeConstraints(scrollView.constraints())
      scrollView.setTranslatesAutoresizingMaskIntoConstraints(true)
      
      scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
      
      pageControl.numberOfPages = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
      //println("deinit \(self)")
      for task in downloadTasks {
        task.cancel()
      }
    }
  
  override func viewWillLayoutSubviews() {
      super.viewWillLayoutSubviews()
      
      scrollView.frame = view.bounds
      pageControl.frame = CGRect(
        x: 0,
        y: view.frame.size.height - pageControl.frame.size.height,
        width: view.frame.size.width,
        height: pageControl.frame.size.height)
      if firstTime {
          firstTime = false
          switch search.state {
          case .NotSearchedYet:
            break
          case .Loading:
            break
          case .NoResults:
            break
          case .Results(let list):
          tileButtons(list)
          }
      }
  }
  
  private func tileButtons(searchResults: [SearchResult]) {
    var columnsPerPage = 5
    var rowsPerPage = 3
    var itemWidth: CGFloat = 96
    var itemHeight: CGFloat = 88
    var marginX: CGFloat = 0
    var marginY: CGFloat = 20
    
    let scrollViewWidth = scrollView.bounds.size.width
    
    switch scrollViewWidth {
    case 568:
      columnsPerPage = 6
      itemWidth = 94
      marginX = 2
      
    case 667:
      columnsPerPage = 7
      itemWidth = 95
      itemHeight = 98
      marginX = 1
      marginX = 29
      
    case 736:
      columnsPerPage = 8
      rowsPerPage = 4
      itemWidth = 92
      
    default:
      break
    }
    
    let buttonWidth: CGFloat = 82
    let buttonHeight: CGFloat = 82
    let paddingHorz = (itemWidth - buttonWidth)/2
    let paddingVert = (itemHeight - buttonHeight)/2
    
    var row = 0
    var column = 0
    var x = marginX
    // 1
    for (index, searchResult) in enumerate(searchResults) {
      // 2
      let button = UIButton.buttonWithType(.Custom) as! UIButton
      button.setBackgroundImage(UIImage(named: "LandscapeButton"), forState: .Normal)
      // 3
      button.frame = CGRect(
        x: x + paddingHorz,
        y: marginY + CGFloat(row)*itemHeight + paddingVert,
        width: buttonWidth,
        height: buttonHeight)
      downloadImageForSearchResult(searchResult, andPlaceOnButton: button)
      // 4
      scrollView.addSubview(button)
      // 5
      ++row
      if (row == rowsPerPage) {
        row = 0
        ++column
        x += itemWidth
        
        if column == columnsPerPage {
          column = 0
          x += marginX * 2
        }
      }
      let buttonsPerPage = columnsPerPage * rowsPerPage
      let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
      scrollView.contentSize = CGSize( width: CGFloat(numPages)*scrollViewWidth, height: scrollView.bounds.size.height)
      //println("Number of pages: \(numPages)")
      pageControl.numberOfPages = numPages
      pageControl.currentPage = 0
    }
  }
  
  private func downloadImageForSearchResult(searchResult: SearchResult, andPlaceOnButton button: UIButton) {
    if let url = NSURL(string: searchResult.artworkURL60) {
      let session = NSURLSession.sharedSession()
      let downloadTask = session.downloadTaskWithURL(url, completionHandler: { [weak button] url, response, error in
        if error == nil && url != nil {
          if let data = NSData(contentsOfURL: url) {
            if let image = UIImage(data: data) {
              dispatch_async(dispatch_get_main_queue()) {
              if let button = button {
                button.setImage(image, forState: .Normal)
              }
            }
          }
        }
      }
      })
    downloadTask.resume()
    downloadTasks.append(downloadTask)
    }
  }
    
}

extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
  let width = scrollView.bounds.size.width
  let currentePage = Int((scrollView.contentOffset.x + width/2) / width)
  pageControl.currentPage = currentePage
    }
}
