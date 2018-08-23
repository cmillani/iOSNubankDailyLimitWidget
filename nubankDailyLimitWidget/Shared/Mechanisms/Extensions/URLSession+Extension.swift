//
//  URLSession+Extension.swift
//  nubankDailyLimitWidget
//
//  Created by Carlos Eduardo Millani on 19/08/18.
//  Copyright © 2018 Teste. All rights reserved.
//

import Foundation

extension URLSession {
    
    /// Executes a URLSessionDataTask in synchronous way, returning the response information in the same queue
    ///
    /// - Parameter request: request to be executed
    /// - Returns: response of the request, with data, response and error
    func synchronousDataTask(withRequest request: URLRequest) -> (Data?, URLResponse?, Error?) {
        // All response obtained from the request, to be returned upon completion
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        // Declares semaphore, used to wait the response from the session and return on the same thread
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        
        // Defines task to be executed
        let dataTask: URLSessionDataTask = self.dataTask(with: request) {
            // Saves all result from the task
            data = $0
            response = $1
            error = $2
            
            // Make signal to free semaphore
            semaphore.signal()
        }
        // Starts the task
        dataTask.resume()
        
        // Wait until the task completes
        _ = semaphore.wait(timeout: .distantFuture)
        
        // Returns all respnse data from the task
        return (data, response, error)
    }
    
}
