//
//  TextSearchViewController.swift
//  HoundifySDK Sample App (Swift)
//
//  Created by Ken Huang on 11/25/16.
//  Copyright © 2016 SoundHound. All rights reserved.
//

import Foundation
import HoundifySDK

class TextSearchViewController: UIViewController, HoundTextSearchQueryDelegate, UISearchBarDelegate {
    
	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var searchBar: UISearchBar!
    
    private var query: HoundTextSearchQuery?

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    private func textSearch(for searchText: String?) {
        guard let search = searchText, !search.isEmpty else {
            return
        }
        
        searchBar.text = "Searching: " + search
        
        query?.cancel()
        
        query = HoundTextSearch.instance().newTextSearch(withSearchText: search)
        
        query?.delegate = self
        
        // An example of how to use RequestInfo: set the location to SoundHound HQ.
        // a real application, of course, one would use location services to determine
        // the device's location.
        
        query?.requestInfoBuilder.latitude = 37.4089054
        query?.requestInfoBuilder.longitude = -121.9849621
        query?.requestInfoBuilder.positionTime = Int(Date().timeIntervalSince1970)
        query?.requestInfoBuilder.positionHorizontalAccuracy = 10

        self.query?.start(completion: nil)
    }
    
    // MARK: - HoundTextSearchQueryDelegate
    
    func houndTextSearchQuery(_ query: HoundTextSearchQuery, didReceiveSearchResult houndServer: HoundDataHoundServer, dictionary: [AnyHashable : Any]) {
        searchBar.resignFirstResponder()
        
        // Domains that work with client features often return incomplete results that need
        // to be completed by the application before they are ready to use. See this method for
        // an example
        tryUpdateQueryResponse(query)
        
        let commandResult = houndServer.allResults?.first
        
        // This sample app includes more detailed examples of how to use a CommandResult
        // for some queries. See HoundDataCommandResult-Extras.swift
        if let exampleText = commandResult?.exampleResultText() {
            textView.attributedText = exampleText
        } else {
            textView.attributedText = JSONAttributedFormatter.attributedString(from: dictionary, style: nil)
        }
        
        if let nativeData = commandResult?["NativeData"]
        {
            print("NativeData: \(nativeData)")
        }

        searchBar.showsCancelButton = false
        searchBar.text = nil
        self.query = nil
    }
    
    func houndTextSearchQuery(_ query: HoundTextSearchQuery, didFailWithError error: Error) {
        searchBar.resignFirstResponder()

        let nserror = error as NSError
        
        textView.text = "\(nserror.domain) (\(nserror.code))\n\(nserror.localizedDescription)"
        
        searchBar.showsCancelButton = false
        searchBar.text = nil
        self.query = nil
    }
    
    func houndTextSearchQueryDidCancel(_ query: HoundTextSearchQuery) {
        self.textView.text = "Canceled"

        searchBar.showsCancelButton = false
        searchBar.text = nil
        self.query = nil
    }
    
    // MARK: - Client Integration Example
    
    public func tryUpdateQueryResponse(_ query: HoundTextSearchQuery) {
        // Some HoundServer responses need information from the client before they are "complete"
        // For more general information, start here: https://www.houndify.com/docs#dynamic-responses
        
        // In this example, let's look at ClientClearScreenCommand. Make sure the "Client Control"
        // domain is enabled in your Houndify Dashboard while you try this example, and type
        // "Clear the screen" to try it.
        
        // First, let's make sure we've got a ClientClearScreenCommand to work with.
        let commandResult📦 = query.response?.allResults?.first
        
        // See HoundDataCommandResult-Extras.swift for the implementation of isClientClearScreenCommand
        guard let commandResult = commandResult📦, commandResult.isClientClearScreenCommand else {
            return
        }
        
        // ClientClearScreenCommand arrives from the server with a spoken response of
        // "This client does not support clearing the screen." by default.
        // This is because houndify does not know whether your application can clear
        // the screen when the command is received.
        
        // Let us suppose for the sake of this example that we'll only consider it a success
        // if the screen has contents to clear.
        
        if textView.text?.isEmpty == false {
            
            // CommandResult comes with a DynamicResponse in the clientActionSucceededResult
            // field which contains updates for the success case.
            
            if let clientActionSucceededResult = commandResult.clientActionSucceededResult {
                // Use Hound.handleDynamicResponse to copy values from clientActionSucceeded
                // to the command result, and to update the conversation state.
                Hound.handleDynamicResponse(clientActionSucceededResult, andUpdate: commandResult)
                
                // Now the spoken response is "Screen is now cleared."
            }
        } else if let clientActionFailedResult = commandResult.clientActionFailedResult {
            Hound.handleDynamicResponse(clientActionFailedResult, andUpdate: commandResult)
            
            // Now the spoken response is, "I couldn't clear the screen."
            // Just for fun, let's add our own explanation.
            commandResult.spokenResponse += " There was nothing to clear."
        }
        
        // Also, since we're clearing screen and can't see the written response,
        // let's speak the response.
        query.speakResponse()
    }

	// MARK: - UISearchBarDelegate
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Don't permit a new search to begin while the old one is running.
        if query != nil {
            return
        }
        
        textSearch(for: searchBar.text)
    }
    
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
        
        query?.cancel()
    }
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		searchBar.showsCancelButton = true
    }
	
}
