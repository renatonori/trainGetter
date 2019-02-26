//
//  ViewController.swift
//  TrainGetter
//
//  Created by Renato Ioshida on 16/09/17.
//  Copyright © 2017 Renato Ioshida. All rights reserved.
//

import Cocoa

class ViewController: NSViewController,NSTableViewDelegate,NSTableViewDataSource{

    @IBOutlet weak var loadingView: NSView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var progressLabel: NSTextField!
    @IBOutlet weak var actionButton: NSButton!
    
    var loadingCount = 0
    var continueGetingInformations:Bool = false
    var csvObject:CSwiftV?
    var csvReaded:String? {
        didSet{
            if let readed = csvReaded{
                self.csvObject = CSwiftV(with: readed, separator: ",", headers: ["URL","Tipo"])
            }
            self.informationsTableView.reloadData()
        }
    }
    var document:Document?
    @IBOutlet weak var informationsTableView: NSTableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.informationsTableView.delegate = self
        self.informationsTableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.actionButton.isEnabled = false
        document = self.view.window?.windowController?.document as? Document
        if let doc = self.document{
            if let readedData = doc.readedData{
                csvReaded = readedData
            }
        }
    }

    @IBAction func updateClicked(_ sender: Any) {
        NaiveBayesClassifierRequests.sharedInstance.getTrainedValues { (model) in
            self.actionButton.isEnabled = true
            NaiveBayesClassifier.sharedInstance.model = model
            
        }
    }
    @IBAction func createTrainClicked(_ sender: Any) {

        self.loadingCount = 0
        self.continueGetingInformations = false

        self.startCreateTrain()
    }
    
    @IBAction func clearTrainingClicked(_ sender: Any) {
        NaiveBayesClassifierRequests.sharedInstance.clearTrainedValues()
    }
    @IBOutlet weak var clearTrain: NSButton!
    var arrayToBeTrained:Array<[String:Any]> = Array.init()
    
    func parseResult(array: Array<String>?, type:String)->Array<[String:String]>{
        var arrayFinal:Array<[String:String]> = []
        if let arrayToParse = array{
            let characterSet = CharacterSet.init(charactersIn: ".#$/[]")
            for value in arrayToParse{
                if value.rangeOfCharacter(from: characterSet) == nil{
                    arrayFinal.append(["type":type,
                                       "value":value])
                }
            }
        }
        
        return arrayFinal
    }
    func startCreateTrain(){
        
        if let readed = csvObject, readed.rows.count > self.loadingCount{
            let row = readed.rows[self.loadingCount]
            if let url = row.first, let type = row.last, type != ""{
                print(url)
                HTMLParserHelper.sharedInstance.parseHtml(url, completionHandler: { (success,result) in
                    let parsedResult = self.parseResult(array: result,type: type)
                    NaiveBayesClassifier.sharedInstance.train(withArray: parsedResult, completion: {
                        if success{
                            self.loadingCount += 1
                            self.startCreateTrain()
                        }else{
                            print("ERROR")
                            self.loadingCount += 1
                            self.startCreateTrain()
                        }
                    })
                })
            }
        }else{
            print("Finalizado")
            NaiveBayesClassifierRequests.sharedInstance.updateTraining()
            self.loadingCount = 0

        }
    }
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if let readed = csvObject, let tableC = tableColumn{
            let objToShow = readed.keyedRows?[row][tableC.title]
            return objToShow
        }
        
        return "No Value"
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let readed = self.csvObject{
            return readed.rows.count
        }else{
            return 0
        }
    }
    
}


