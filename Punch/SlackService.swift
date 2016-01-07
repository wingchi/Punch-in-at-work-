//
//  SlackService.swift
//  Punch
//
//  Created by Stephen Wong on 1/6/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Foundation

enum SlackMessageError: ErrorType {
    case UnexpectedAPIResponse
}

enum SlackMessageResponse {
    case Success(response: String)
    case Failure(error: ErrorType)
}

class SlackService {
    static let sharedService = SlackService()
    
    private let session: NSURLSession = {
        let sessionConfig: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        return session
    }()
    
    func sendSlackWebhookMessage(message: String, completion: ((SlackMessageResponse) -> Void)) {
        let path = "https://hooks.slack.com/services/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"
        guard let url = NSURL(string: path) else {
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        do {
            let messageText = ["text": message]
            let jsonData = try NSJSONSerialization.dataWithJSONObject(messageText, options: [])
            let task = session.uploadTaskWithRequest(request, fromData: jsonData) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
                var result: SlackMessageResponse
                if let data = data {
                    let stringResult = NSString(data: data, encoding: NSUTF8StringEncoding)
                    print(stringResult)
                    if stringResult! == "ok" {
                        result = SlackMessageResponse.Success(response: "We told everyone on Slack!")
                    }
                    else {
                        result = SlackMessageResponse.Failure(error: SlackMessageError.UnexpectedAPIResponse)
                    }
                } else {
                    result = SlackMessageResponse.Failure(error: SlackMessageError.UnexpectedAPIResponse)
                }
                // Call our completion handler on the main queue
                dispatch_async(dispatch_get_main_queue()) {
                    completion(result)
                }
            }
            task.resume()
        } catch let error as NSError {
            completion(SlackMessageResponse.Failure(error: error))
        }
    }
}