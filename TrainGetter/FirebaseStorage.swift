//
//  FirebaseStorage.swift
//  TrainGetter
//
//  Created by Renato Ioshida on 09/05/2018.
//  Copyright © 2018 Renato Ioshida. All rights reserved.
//

import Cocoa
import FirebaseDatabase


class FirebaseStorage: NSObject {
    static let sharedInstance:FirebaseStorage = FirebaseStorage()
    let ref: DatabaseReference = Database.database().reference()
    

    
}
