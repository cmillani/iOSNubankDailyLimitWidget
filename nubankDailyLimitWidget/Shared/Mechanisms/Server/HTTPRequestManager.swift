//
//  HTTPRequestManager.swift
//  nubankDailyLimitWidget
//
//  Created by Carlos Eduardo Millani on 19/08/18.
//  Copyright © 2018 Teste. All rights reserved.
//

import Foundation

protocol HTTPRequestTokenDataSource {
    func getToken() throws -> String?
    func getTokenType() throws -> String?
    func renewToken() throws
}

/// Class responsible for managing http requests
class HTTPRequestManager {
    
    /// singleton instance for request manager
    static let shared: HTTPRequestManager = HTTPRequestManager()
    
    /// Data Source used to retrieve token information and handle token expiration
    var tokenDataSource: HTTPRequestTokenDataSource?
    
    /// Private default constructor to avoid external instantiation
    private init() { }
    
    // MARK: - Public Methods
    
    /// Makes a request to a specified server, parsing the response using the utf8 encoding to return it as string
    ///
    /// - Parameters:
    ///   - url: url to be requested
    ///   - contentType: contentyType Header to be used
    ///   - requestData: request body to be sent
    ///   - method: HTTP method to be used
    ///   - isSecondTry: indicated if this is the second try of the request, used to handle auth errors
    /// - Returns: Valid response returned from a server response with status code 200
    /// - Throws: If the status code is not 200 or any system error ocurred, it is thrown
    func request(toUrl url: String, withBodyContentType contentType: String?, withBody requestData: Data?, usingMethod method: RequestMethod, useToken: Bool = true, isSecondTry: Bool = false) throws -> String {
        do {
            // Creates the environment for the request
            let request: URLRequest = try createURLRequest(toUrl: url, withBodyContentType: contentType, withBody: requestData, usingMethod: method.rawValue, useToken: useToken)
            let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
            
            // Executes the request
            let (rawDataResponse, response, error) = session.synchronousDataTask(withRequest: request)
            
            // Parses the response data into an string
            let responseData: Data = try handleResponse(rawDataResponse, response, error)
            guard let responseString = String(data: responseData, encoding: .utf8) else {
                // No valid response, throws error
                throw NubankPlannerError.emptyResponse
            }
            // Return parsed stirng
            return responseString
        } catch (NubankPlannerError.authError) {
            // Auth errors are handled renewing the token information
            if !isSecondTry {
                // Clears the token data
                try self.tokenDataSource?.renewToken()
                // Try the request again
                return try request(toUrl: url, withBodyContentType: contentType, withBody: requestData, usingMethod: method, useToken: useToken, isSecondTry: true)
            } else {
                // If has already tried 2 times, throws error
                throw NubankPlannerError.authError
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Creates a url request with the provided data to be sent to the server
    ///
    /// - Parameters:
    ///   - url: url to be called
    ///   - contentType: content type of the request
    ///   - data: data of the body to be sent
    ///   - method: HTTP method to be used
    /// - Returns: URLRequest with given parameters
    /// - Throws: In case of failure to retrieve a token, an error is thrown
    private func createURLRequest(toUrl url: String, withBodyContentType contentType: String?, withBody data: Data?, usingMethod method: String, useToken: Bool) throws -> URLRequest {
        // Generate the request
        var request: URLRequest = URLRequest(url: URL(string: url)!)
        request.httpMethod = method

        // Insets a token if available
        if useToken, let token = try tokenDataSource?.getToken(), let tokenType = try tokenDataSource?.getTokenType() {
            // add as header
            request.addValue("\(tokenType) \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add content type if available
        if (contentType != nil) {
            request.addValue(contentType!, forHTTPHeaderField: "Content-Type")
        }
        
        // If there is any data to be added to request, do it
        if (data != nil) {
            request.httpBody = data
        }
        
        // Returns the fully build request
        return request
    }
    
    /// Handles the response information from a URLRequest, extracting meaningful information and validating response code
    ///
    /// - Parameters:
    ///   - data: data returned
    ///   - response: response returned
    ///   - error: error retorned
    /// - Returns: A valid Data, parsed from the received Data
    /// - Throws: If there is an error, nil Data or invalid status code, an error is thrown
    private func handleResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) throws -> Data {
        // if and error had occurred rethrow it
        if let error = error {
            throw error
        }
        
        // if nor response provided, stop execution with a error
        guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse else {
            throw NubankPlannerError.serverErrorWithInvalidRequestOrResponse
        }
        
        // check for response body
        guard let responseData: Data = data else {
            // A succeeded request should return a body
            throw NubankPlannerError.serverErrorWithInvalidRequestOrResponse
        }
        
        // if status code comming from response is different from 200 stop the execution
        switch (httpResponse.statusCode) {
        case 200: break
        case 401:
            // Throw auth exception
            throw NubankPlannerError.authError
        default:
            // Log the issue
            print("Request returned an error (\(httpResponse.statusCode)) and contents: \(String(data: responseData, encoding: .utf8) ?? "")")
            
            // Throw exception
            throw NubankPlannerError.serverErrorStatusCode(httpCode: httpResponse.statusCode)
        }
        
        // Returns valid response
        return responseData
    }
}

/// Enum used to define all request methods available
enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
