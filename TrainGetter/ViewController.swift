//
//  ViewController.swift
//  TrainGetter
//
//  Created by Renato Ioshida on 16/09/17.
//  Copyright © 2017 Renato Ioshida. All rights reserved.
//

import Cocoa


class ViewController: NSViewController,NSTableViewDelegate,NSTableViewDataSource{
    
    @objc var csvReaded:Any?
    
    @IBOutlet weak var informationsTableView: NSTableView!
    
    @objc func newCSVReaded(_ CSVReaded:String){
        csvReaded = CSwiftV(with: CSVReaded, separator: ",", headers: ["URL","Type"])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func createTrainClicked(_ sender: Any) {
        
    }
}

