//
//  Users.swift
//  JSONRESTful
//
//  Created by Gabriel Anderson Ccama Apaza on 6/11/24.
//

import Foundation
struct Users:Decodable {
    let id:Int
    let nombre:String
    let clave:String
    let email:String
}
