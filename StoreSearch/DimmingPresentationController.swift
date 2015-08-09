//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by vito on 08/08/15.
//  Copyright (c) 2015 vito. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
  override func shouldRemovePresentersView() -> Bool {
    return false
  }
}
