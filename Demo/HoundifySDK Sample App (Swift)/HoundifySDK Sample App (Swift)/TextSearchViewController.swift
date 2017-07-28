//
//  TextSearchViewController.swift
//  HoundifySDK Sample App (Swift)
//
//  Created by Ken Huang on 11/25/16.
//  Copyright © 2016 SoundHound. All rights reserved.
//

import Foundation
import HoundifySDK

class TextSearchViewController: UIViewController, UISearchBarDelegate {
    
	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var searchBar: UISearchBar!
		
	//MARK: UISearchBarDelegate
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		textView.text = ""
        textSearch(for: searchBar.text)
    }
    
    private func textSearch(for aQuery: String?) {
        guard let query = aQuery, !query.isEmpty else {
            return
        }
        
        HoundTextSearch.instance().search(withQuery: query, requestInfo: nil, completionHandler:
            
            { (error: Error?, myQuery: String, houndServer: HoundDataHoundServer?, dictionary: [String : Any]?, requestInfo: [String : Any]?) in
                if let error = error as NSError? {
                    self.textView.text = "\(error.domain) (\(error.code))\n\(error.localizedDescription)"
                } else if houndServer != nil, let dictionary = dictionary {
                    self.textView.attributedText = JSONAttributedFormatter.attributedString(from: dictionary, style: nil)
                }
            }
        )
    }
	
	//MARK: UIStatusBarStyle
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return .lightContent
    }
	
	//MARK: UISearchBarDelegate
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
    }
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		searchBar.showsCancelButton = true
    }
	
	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		searchBar.showsCancelButton = false
    }
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText.characters.count == 0 {
			self.textView.text = ""
        }
    }
}
