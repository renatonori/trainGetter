//
//  NaiveBayesClassifier.swift
//  TrainGetter
//
//  Created by Renato Ioshida on 08/05/2018.
//  Copyright © 2018 Renato Ioshida. All rights reserved.
//

import Cocoa


typealias TaggedToken = (String, String?) // Can’t add tuples to an array without typealias. Compiler bug... Sigh.
func tag(text: String, scheme: String) -> [TaggedToken] {
    let options: NSLinguisticTagger.Options = [.omitWhitespace,.omitPunctuation,.omitOther]
    let tagger = NSLinguisticTagger(tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "en"),
                                    options: Int(options.rawValue))
    tagger.string = text
    
    var tokens: [TaggedToken] = []
    
    // Using NSLinguisticTagger
    
    tagger.enumerateTags(in: NSMakeRange(0, text.count), scheme:NSLinguisticTagScheme(rawValue: scheme), options: options) { tag, tokenRange, _, _ in
        let token = (text as NSString).substring(with: tokenRange)
        tokens.append((token, tag.map { $0.rawValue }))
    }
    return tokens
}

func partOfSpeech(text: String) -> [TaggedToken] {
    return tag(text: text, scheme: NSLinguisticTagScheme.lexicalClass.rawValue)
}
func lemmatize(text: String) -> [TaggedToken] {
    return tag(text: text, scheme:NSLinguisticTagScheme.lemma.rawValue)
}

func language(text: String) -> [TaggedToken] {
    return tag(text: text, scheme:NSLinguisticTagScheme.language.rawValue)
}
public typealias Category = String
public class NaiveBayesClassifier {
    static let sharedInstance: NaiveBayesClassifier = NaiveBayesClassifier()
    
    var model:NaiveBayesClassifierModel{
        didSet{
            categoryOccurrences = model.categoryOccurrences
            tokenOccurrences = model.tokenOccurrences
            trainingCount = model.trainingCount
            tokenCount = model.tokenCount
        }
    }
    private let tokenizer: (String) -> [String]
    
    private var categoryOccurrences: [Category: Int] = [:]
    private var tokenOccurrences: [String: [Category: Int]] = [:]
    private var trainingCount = 0
    private var tokenCount = 0
    
    private let smoothingParameter = 1.0
    
    init() {
        self.tokenizer = { (text: String) -> [String] in
            
            return lemmatize(text: text).map { (token, tag) in
                if let tag = tag, tag != ""{
                    return tag
                }else{
                    return token
                }
            }
        }
        self.model = NaiveBayesClassifierModel()
    }
    
    // MARK: - Training
    public func trainWithText(text: String, category: Category) {
        let training = clearNoEnglishToken(tokens: tokenizer(text))
        if training.count > 0{
            trainWithTokens(tokens: training, category: category)
        }
    }
    
    public func trainWithTokens(tokens: [String], category: Category) {
        print(tokens)
        let tokens = Set(tokens)
        for token in tokens {
            let tokenCleared = token.cleared
            incrementToken(token: tokenCleared, category: category)
        }
        incrementCategory(category: category)
        trainingCount += 1
    }
    
    public func classifyTokens(tokens: [String]) -> Category? {
        // Compute argmax_cat [log(P(C=cat)) + sum_token(log(P(W=token|C=cat)))]
        var maxCategory: Category?
        var maxCategoryScore = -Double.infinity
        for (category, _) in categoryOccurrences {
            let pCategory = P(category: category)
            let score = tokens.reduce(log(pCategory)) { (total, token) in
                // P(W=token|C=cat) = P(C=cat, W=token) / P(C=cat)
                total + log((P(category:category, token) + smoothingParameter) / (pCategory + smoothingParameter * Double(tokenCount)))
            }
            if score > maxCategoryScore {
                maxCategory = category
                maxCategoryScore = score
            }
        }
        return maxCategory
    }
    
    // MARK: - Probabilites
    private func P(category: Category, _ token: String) -> Double {
        return Double(tokenOccurrences[token]?[category] ?? 0) / Double(trainingCount)
    }
    
    private func P(category: Category) -> Double {
        return Double(totalOccurrencesOfCategory(category: category)) / Double(trainingCount)
    }
    
    // MARK: - Counting
    private func incrementToken(token: String, category: Category) {
        if tokenOccurrences[token] == nil {
            tokenCount += 1
            tokenOccurrences[token] = [:]
        }

        // Force unwrap to crash instead of providing faulty results.
        let count = tokenOccurrences[token]![category] ?? 0
        tokenOccurrences[token]![category] = count + 1
    }
    
    private func incrementCategory(category: Category) {
        categoryOccurrences[category] = totalOccurrencesOfCategory(category: category) + 1
    }
    
    private func totalOccurrencesOfToken(token: String) -> Int {
        if let occurrences = tokenOccurrences[token] {
            
            return occurrences.values.reduce(0,+)
        }
        return 0
    }
    
    private func totalOccurrencesOfCategory(category: Category) -> Int {
        return categoryOccurrences[category] ?? 0
    }
    func isEnglishLanguage(text:String)->Bool{
        let result = language(text: text)
        var isAcceptable = false
        for tokentagged in result{
            if let string = tokentagged.1, string == "en" {
                isAcceptable = true
            }else{
                return false
            }
        }
        return isAcceptable
    }
    func train(withArray:Array<[String:String]>, completion:()->Void){
        for trainingText in withArray{
            if let value = trainingText["value"], let type = trainingText["type"]{
                
                self.trainWithText(text: value, category: type)
            }
        }
        completion()
    }
    func detectedLangauge<T: StringProtocol>(_ forString: T) -> String? {
        if #available(OSX 10.13, *) {
            guard let languageCode = NSLinguisticTagger.dominantLanguage(for: String(forString)) else {
                return nil
            }
            let detectedLangauge = Locale.current.localizedString(forIdentifier: languageCode)
            
            return detectedLangauge
        } else {
            return nil
        }
        

    }
    func clearNoEnglishToken(tokens:[String])->[String]{
        let clearedTokens:[String] = tokens
        var tokensToClear:[String] = []
        for i in 0..<tokens.count {
            let lang = detectedLangauge(tokens[i])?.lowercased()
            if lang != "english",lang != "ingles", lang != "inglês"{
                tokensToClear.append(tokens[i])
            }
        }
        let result = clearedTokens.filter { element in
            return !tokensToClear.contains(element)
        }
        
        return result
    }
    func getTrainedValues()->NaiveBayesClassifierModel{
        let nvModel = NaiveBayesClassifierModel()
        
        nvModel.categoryOccurrences = categoryOccurrences
        nvModel.tokenOccurrences = tokenOccurrences
        nvModel.trainingCount = trainingCount
        nvModel.tokenCount = tokenCount
        
        return nvModel
    }
}



