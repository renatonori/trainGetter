//
//  NaiveBayesClassifierRequests.swift
//  TrainGetter
//
//  Created by Renato Ioshida on 09/05/2018.
//  Copyright © 2018 Renato Ioshida. All rights reserved.
//

import Cocoa

class NaiveBayesClassifierRequests: NSObject {
    
    static let sharedInstance:NaiveBayesClassifierRequests = NaiveBayesClassifierRequests()
    
    let FirebaseReference = FirebaseStorage.sharedInstance.ref
    
    func updateTraining(categoryOccurrences:[String: Int],tokenOccurrences:[String: [String: Int]], trainingCount:Int,tokenCount:Int){
        let dictionaryToPost = ["categoryOccurrences":categoryOccurrences,
                                "tokenOccurrences":tokenOccurrences,
                                "trainingCount":trainingCount,
                                "tokenCount":tokenCount] as [String : Any]
        
        FirebaseReference.updateChildValues(dictionaryToPost)
    }
    func updateTraining(){
        let newValues = NaiveBayesClassifier.sharedInstance.getTrainedValues()
        
        print(newValues.categoryOccurrences)
        print(newValues.tokenOccurrences)
        print(newValues.trainingCount)
        print(newValues.tokenCount)
        
        let dictionaryToPost = ["categoryOccurrences":newValues.categoryOccurrences,
                                "tokenOccurrences":newValues.tokenOccurrences,
                                "trainingCount":newValues.trainingCount,
                                "tokenCount":newValues.tokenCount] as [String : Any]
        FirebaseReference.setValue(dictionaryToPost)
    }
    
    func clearTrainedValues(){
        FirebaseReference.setValue(nil)
    }
    func getTrainedValues(completion:@escaping (_ naiveBayesModel:NaiveBayesClassifierModel)->Void){
        FirebaseReference.observeSingleEvent(of: .value) { (snapshot) in
            
            var categoryOccurrences: [Category: Int] = [:]
            var tokenOccurrences: [String: [Category: Int]] = [:]
            var trainingCount = 0
            var tokenCount = 0
            
            if let dict = snapshot.value as? NSDictionary{
                categoryOccurrences = dict["categoryOccurrences"] as! [Category : Int]
                tokenOccurrences = dict["tokenOccurrences"] as! [String : [Category : Int]]
                trainingCount = dict["trainingCount"] as! Int
                tokenCount = dict["tokenCount"] as! Int
            }
            let nvModel = NaiveBayesClassifierModel()
            
            nvModel.categoryOccurrences = categoryOccurrences
            nvModel.tokenOccurrences = tokenOccurrences
            nvModel.trainingCount = trainingCount
            nvModel.tokenCount = tokenCount
            
            completion(nvModel)
        }
    }
}
