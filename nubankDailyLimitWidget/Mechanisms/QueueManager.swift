//
//  QueueManager.swift
//  nubankDailyLimitWidget
//
//  Created by Carlos Eduardo Millani on 19/08/18.
//  Copyright © 2018 Teste. All rights reserved.
//

import Foundation

class QueueManager {
    /// Queue types
    enum QueueType {
        case main
        case concurrent
        case serial
    }
    
    /// Available queues
    private var serialQueue: OperationQueue
    private var concurrentQueue: OperationQueue
    
    static let sharedInstance: QueueManager = QueueManager()
    
    /// Private initializer used to create and configure internal queues
    private init() {
        // initialize & configure serial queue
        serialQueue = OperationQueue()
        serialQueue.maxConcurrentOperationCount = 1
        
        // initialize & configure concurrent queue
        concurrentQueue = OperationQueue()
    }
    
    /// function responsible for executing a block of code in a particular queue
    /// - params:
    /// - NSBlockOperation: block operation to be executed
    /// - QueueType: queue where the operation will be executed
    func executeBlock(_ blockOperation: BlockOperation, queueType: QueueType) {
        // get queue where operation will be executed
        let queue: OperationQueue = self.getQueue(queueType)
        
        // execute operation
        queue.addOperation(blockOperation)
    }
    
    /// Function responsible for returning a specifi queue
    /// Parameters:
    /// - queueType: desired queue
    /// returns: queue in according to the given param
    private func getQueue(_ queueType: QueueType) -> OperationQueue {
        // Returns the requestes queue
        switch queueType {
        case .concurrent:
            return self.concurrentQueue
        case .main:
            return OperationQueue.main
        case .serial:
            return self.serialQueue
        }
    }
    
    func execute<ResponseType>(mechanism: @escaping () throws -> ResponseType, success: ((ResponseType) -> Void)?, error: ((Error) -> Void)?) {
        // Block to be executed in background
        let blockForExecutionInBackground: BlockOperation = BlockOperation {
            var response: ResponseType? = nil
            var responseError: Error?
            
            do {
                // Tries to execute the mechanism
                response = try mechanism()
            } catch let error {
                responseError = error
            }
            
            // Execute completion block on main thread
            let blockForExecutionInMain = BlockOperation {
                if let unwrapedError = responseError {
                    error?(unwrapedError)
                } else if let unwrappedResponse = response {
                    success?(unwrappedResponse)
                }
            }
            self.executeBlock(blockForExecutionInMain, queueType: .main)
        }
        
        // Execute block in background thread
        self.executeBlock(blockForExecutionInBackground, queueType: .serial)
    }
    

    func execute(mechanism: @escaping () throws -> Void, success: (() -> Void)?, error: ((Error) -> Void)?) {
        // Block to be executed in background
        let blockForExecutionInBackground: BlockOperation = BlockOperation {
            var responseError: Error?
            
            do {
                // Tries to execute the mechanism
                try mechanism()
            } catch let error {
                responseError = error
            }
            
            // Execute completion block on main thread
            let blockForExecutionInMain = BlockOperation {
                if let unwrapedError = responseError {
                    error?(unwrapedError)
                } else {
                    success?()
                }
            }
            self.executeBlock(blockForExecutionInMain, queueType: .main)
        }
        
        // Execute block in background thread
        self.executeBlock(blockForExecutionInBackground, queueType: .serial)
    }
}
