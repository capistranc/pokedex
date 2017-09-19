//
//  Pokemon.swift
//  pokedex
//
//  Created by Mac on 9/8/17.
//  Copyright © 2017 Mac. All rights reserved.
//


import Foundation
import UIKit



class Pokemon {
    let id:Int
    var name:String?
    var types:[String] = []
    var abilities:[String] = []
    
    var height:Int?
    var weight:Int?
    var flavorText:String?
    var evos:[Int] = []
    
    var evolutionId:Int?
    var typeUrlIds:[Int] = []
    var abilityUrlIds:[Int] = []
    
    var shinyImage:UIImage?
    
    init(id:Int) {
        self.id = id
    }
    
    private func initWithJson(json:[String:Any]) {
        var types:[String] = []
        var typeUrls:[Int] = []
        guard let name = json["name"] as? String else {return print("bad json")}
        //        guard let id = json["id"] as? Int else {fatalError("bad json")}
        guard let weight = json["weight"] as? Int else {return print("bad json")}
        guard let height = json["height"] as? Int else {return print("bad json")}
        guard let typesDict = json["types"] as? [[String:Any]] else {return print("bad json")}
        
        if typesDict.count == 2 {
            guard let type1 = (typesDict[1]["type"] as? [String:Any])?["name"] as? String else {return print("bad json")}
            types.append(type1)
            
            guard let type1Url = (typesDict[1]["type"] as? [String:Any])?["url"] as? String else {return print("bad json")}
            guard let type1Id = (type1Url.components(separatedBy: "/").filter{$0 != ""}.last.flatMap{Int($0)}) else {return}
            typeUrls.append(type1Id)
        }
        guard let type2 = (typesDict[0]["type"] as? [String:Any])?["name"] as? String else {return print("bad json")}
        guard let type2Url = (typesDict[0]["type"] as? [String:Any])?["url"] as? String else {return print("bad json")}
        guard let type2Id = (type2Url.components(separatedBy: "/").filter{$0 != ""}.last.flatMap{Int($0)}) else {return print("failed strip")}
        typeUrls.append(type2Id)
        types.append(type2)
        
        self.typeUrlIds = typeUrls
        self.types = types
        self.name = name
        self.weight = weight
        self.height = height
    }
    
    private func setSpeciesInfo(json:[String:Any]) {
        guard let flavorText = (json["flavor_text_entries"] as? [[String:Any]])?[1]["flavor_text"] as? String else {return}
        guard let evoUrl = (json["evolution_chain"] as? [String:Any])?["url"] as? String else {return}
        
        let evoId = evoUrl.components(separatedBy: "/").filter{$0 != ""}.last.flatMap{Int($0)}
        
        self.evolutionId = evoId
        self.flavorText = flavorText.replacingOccurrences(of: "\n", with: " ")
    }
    
    private func setEvolutionLine(json:[String:Any]) {
        var evoIdChain:[Int] = []
        
        guard let chain = json["chain"] as? [String:Any] else {return}
        guard let evo1Url = (chain["species"] as? [String:Any])?["url"] as? String else {return}
        
        guard let evo1Id = (evo1Url.components(separatedBy: "/").filter{$0 != ""}.last.flatMap{Int($0)}) else {return}
        evoIdChain.append(evo1Id)
        
        guard let evo2Json = chain["evolves_to"] as? [[String:Any]] else {return}
        if !evo2Json.isEmpty {
            guard let evo2Url = (evo2Json[0]["species"] as? [String:Any])?["url"] as? String else {return}
            guard let evo2Id = (evo2Url.components(separatedBy: "/").filter{$0 != ""}.last.flatMap{Int($0)}) else {return}
            
            evoIdChain.append(evo2Id)
            
            guard let evo3Json = evo2Json[0]["evolves_to"] as? [[String:Any]] else {return}
            if !evo3Json.isEmpty {
                guard let evo3Url = (evo3Json[0]["species"] as? [String:Any])?["url"] as? String else {return}
                guard let evo3Id = (evo3Url.components(separatedBy: "/").filter{$0 != ""}.last.flatMap{Int($0)}) else {return}
                
                evoIdChain.append(evo3Id)
            }
        }
        
        let evoChain = evoIdChain.filter{ $0 <= 151}
        self.evos = evoChain
    }
    
    func fetchDataForView(callback:@escaping () -> ()) {
        let id = self.id
        Networking.getPokemonPage(callType: .Pokemon, forId: id) { (json, err) in
            guard err == nil else {return print(err!)}
            guard let json = json else {return}
            self.initWithJson(json: json)
        }
        
        Networking.getPokemonImage(callType: .ShinySprite, forId: id) { (image, err) in
            guard err == nil else {return print(err!)}
            guard let image = image else {return}
            self.shinyImage = image
        }
        
        Networking.getPokemonPage(callType: .SpeciesInfo, forId: id) {(json, err) in
            guard err == nil else {return print(err!)}
            guard let json = json else {return}
            self.setSpeciesInfo(json: json)
            Networking.getPokemonPage(callType: .EvolutionChain, forId: self.evolutionId) { (json, err) in
                guard err == nil else {return print(err!)}
                guard let json = json else {return}
                self.setEvolutionLine(json: json)
                Cache.shared.pokeCache[id] = self
                self.cacheEvoImages()
                callback()
            }
        }
        
    }
    
    func cacheEvoImages() {
        if evos.isEmpty {return}
        for evoId in evos{
            if Cache.shared.imageHash[evoId] == nil {
                Networking.getPokemonImage(callType: .PokeSprite, forId: Int(evoId)){ (image, err) in
                    guard err == nil else {return print(err!)}
                    guard let image = image else {return}
                    Cache.shared.imageHash[evoId] = image
                }
            }
        }
    }
    
    //End
}

