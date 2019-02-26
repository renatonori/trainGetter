//
//  OutputJsonHelper.swift
//  TrainGetter
//
//  Created by Renato Ioshida on 01/10/17.
//  Copyright © 2017 Renato Ioshida. All rights reserved.
//

import Cocoa

class OutputJsonHelper: NSObject {
    static let sharedInstace = OutputJsonHelper()
    
    func arrayDePalavrasParaArrayDeDicionario(_ arrayOriginal:Array<[String:Any]>,_ arrayParaJuntar:Array<String>,_ type:String)->Array<[String:Any]>{
        var arrayFinal:Array<[String:Any]> = arrayOriginal
        for frase in arrayParaJuntar{
            arrayFinal.append(["text": frase, "label": type])
        }
        return arrayFinal
    }
    func dictArrayToString(_ dictArray:Array<[String:Any]>)->String?{
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictArray, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            let stringFromJson = String(data: jsonData, encoding: .utf8)!
            // here "decoded" is of type `Any`, decoded from JSON data
            return stringFromJson
            // you can now cast it with the right type
            
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    func convertToTrainingDictionary(text:String) -> [String: Any]?{
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options:[]) as? [String: Any]
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }else{
            return nil
        }
    }
    func getTrainingArray(dict:[String: Any]) -> Array<[String: Any]>? {
        return dict["traininginfo"]  as? Array<[String: Any]>
    }
    func writeTrainingJSON(array:Array<[String:Any]>,completionHandler: (Bool) -> Void){
        // Save data to file
        let fileName = "arquivoTeste"
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension("json")
        
        if let stringToWrite = self.dictArrayToString(array){
            do {
                // Write to the file
                try stringToWrite.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                completionHandler(false)
                print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
            }
            
        }
        completionHandler(true)
        
    }
}
