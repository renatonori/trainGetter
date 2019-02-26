//
//  HTMLParserHelper.swift
//  TrainGetter
//
//  Created by Renato Ioshida on 24/09/17.
//  Copyright © 2017 Renato Ioshida. All rights reserved.
//

import Cocoa
import Alamofire
import Kanna

class HTMLParserHelper: NSObject {
    
    static let sharedInstance = HTMLParserHelper()
    
    func parseHtml(_ url:String,completionHandler: @escaping (Bool,Array<String>?) -> Void){
        
        Alamofire.request(url).responseString { response in
            if let html = response.result.value {
                self.parseHTML(html, completionHandler: { (success, arrayString) in
                    completionHandler(success,arrayString)
                })
            }else{
                completionHandler(false,nil)
            }
        }
    }
    private func parseHTML(_ html:String,completionHandler: @escaping (Bool,Array<String>) -> Void){
        let result = try? HTML(html: html, encoding: .utf8)
        var allArrayOfString:Array<String> = []
        var finishedWithSuccess = true
        if (result != nil){
            if let teste = result?.css("a"){
                for link in teste{
                    if let palavras = link.text, palavras != ""{
                        let palavrasFiltradas = palavras.cleared
        
                        let palavraParaAdicionar = palavrasFiltradas.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !palavraParaAdicionar.isEmpty{
                            allArrayOfString.append(palavraParaAdicionar)
                        }
                    }
                }
            }
        }else{
            finishedWithSuccess = false
        }
        completionHandler(finishedWithSuccess,allArrayOfString)
    }
    

}
extension String {
    
    var cleared: String {
        let bar = self.folding(options: .diacriticInsensitive, locale: .current)
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ")
        return String(bar.filter {okayChars.contains($0) }).lowercased()
    }
}
