//
//  Types.swift
//  pokedex
//
//  Created by Mac on 9/18/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation

class PokemonType {
    let id:Int
    var name:String?
    
    var doubleDamageFrom:[String] = []
    var halfDamageFrom:[String] = []
    var noDamageFrom:[String] = []
    var doubleDamageTo:[String] = []
    var halfDamageTo:[String] = []
    var noDamageTo:[String] = []
    var damagesTypeCount:Int = 0
    
    var moves:[String] = []
    
    var pokemon:[(Int,String)] = []
    
    init(id:Int){
        self.id = id
    }
    
    private func initFromJSon(json: [String:Any]) {
        guard let name = json["name"] as? String else {return}
        guard let damageRelations = json["damage_relations"] as? [String:Any] else {return}
        
        guard let doubleDamagesFromJson = damageRelations["double_damage_from"] as? [[String:Any]] else {return}
        guard let halfDamagesFromJson = damageRelations["half_damage_from"] as? [[String:Any]] else {return}
        guard let noDamagesFromJson = damageRelations["no_damage_from"] as? [[String:Any]] else {return}
        guard let doubleDamagesToJson = damageRelations["double_damage_to"] as? [[String:Any]] else {return}
        guard let halfDamagesToJson = damageRelations["half_damage_to"] as? [[String:Any]] else {return}
        guard let noDamageToJson = damageRelations["no_damage_to"] as? [[String:Any]] else {return}
        guard let pokemonJson = json["pokemon"] as? [[String:Any]] else {return}
        let urlArray = pokemonJson.flatMap{$0["url"] as? String}
        let nameArray = pokemonJson.flatMap{$0["name"] as? String}
        let idArray = urlArray.flatMap{stripIdFromUrl(url: $0)}
        
        self.pokemon = zip(idArray,nameArray).map{($0,$1)}
        
        self.doubleDamageFrom = doubleDamagesFromJson.flatMap{$0["name"] as? String}
        self.halfDamageFrom = halfDamagesFromJson.flatMap{$0["name"] as? String}
        self.noDamageFrom = noDamagesFromJson.flatMap{$0["name"] as? String}
        self.doubleDamageTo = doubleDamagesToJson.flatMap{$0["name"] as? String}
        self.halfDamageTo = halfDamagesToJson.flatMap{$0["name"] as? String}
        self.noDamageTo = noDamageToJson.flatMap{$0["name"] as? String}
        self.name = name
    }
    
    
    func stripIdFromUrl(url:String)->Int?{
        return url.components(separatedBy: "/").filter{$0 != ""}.last.flatMap{Int($0)}
    }
    
    func fetchDataForView(callback:@escaping () -> ()) {
        
        Networking.getPokemonPage(callType: .TypeInfo, forId: self.id) { (json, err) in
            guard err == nil else {return print(err!)}
            guard let json = json else {return}
            self.initFromJSon(json: json)
            
            callback()
        }
    }
    
}
