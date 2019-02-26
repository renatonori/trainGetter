//
//  NaiveBayesClassifierViewModel.swift
//  TrainGetter
//
//  Created by Renato Ioshida on 09/05/2018.
//  Copyright © 2018 Renato Ioshida. All rights reserved.
//

import Cocoa

class NaiveBayesClassifierModel: NSObject {
    var categoryOccurrences: [Category: Int] = [:]
    var tokenOccurrences: [String: [Category: Int]] = [:]
    var trainingCount = 0
    var tokenCount = 0
}
