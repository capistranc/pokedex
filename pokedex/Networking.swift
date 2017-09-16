//
//  Networking.swift
//  pokedex
//
//  Created by Mac on 9/8/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import UIKit

enum ApiPage {
    case PokemonList
    case Pokemon
    case EvolutionChain
    case SpeciesInfo
    
    func setPage() -> String {
        switch self {
        case .PokemonList:
            return "pokemon/?offset="
        case .Pokemon:
            return "pokemon/"
        case .EvolutionChain:
            return "evolution-chain/"
        case .SpeciesInfo:
            return "pokemon-species/"
        }
    }
}


enum PokeImageType {
    case ShinySprite
    case PokeSprite
    case Background1
    case Background2
    case EvoSprite
    func setImageLocation() -> String {
        switch self {
        case .Background1:
            return "https://raw.githubusercontent.com/capistranc/pokedex/master/pokedex/Assets.xcassets/background1.imageset/background1.jpeg"
        case .Background2:
            return "https://raw.githubusercontent.com/capistranc/pokedex/master/pokedex/Assets.xcassets/defaultBackground.imageset/defaultBackground.jpg"
        case .PokeSprite:
            return "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/"
        case .EvoSprite:
            return "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/"
        case .ShinySprite:
            return "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/"
            
        }
    }
}

class Networking {
    static func getPokemonPage(callType:ApiPage, forId id:Int?, completion:@escaping ([String:Any])->()) {
        let basePage = "https://pokeapi.co/api/v2/"
        var page = callType.setPage()
        if let idStr = id {page = page + "\(idStr)"}
        guard let url = URL(string: basePage + page) else {return}
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, res, error) in
            guard error == nil else {return}
            guard let res = res as? HTTPURLResponse else {return}
            guard res.statusCode == 200 else {return print(res.statusCode)}
            
            guard let data = data else {return}
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                guard let dictionary = json as? [String:Any] else {return print("bad json data")}
                completion(dictionary)
            } catch {
                print("something went wrong")
            }
        }
        task.resume()
    }
    
    static func getPokemonImage(callType:PokeImageType, forId id:Int?, completion:@escaping (UIImage)->()) {
        var urlString = callType.setImageLocation()
        if let idStr = id {urlString = urlString + "\(idStr).png"}
        
        guard let url = URL(string: urlString) else {return}
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {return}
            guard let res = response as? HTTPURLResponse else {return}
            guard res.statusCode == 200 else {return print(res.statusCode)}
            guard let data = data else {return print("bad data")}
            guard let image = UIImage(data:data) else {return print("bad image data")}
            
            if let idNum = id {
                image.accessibilityIdentifier = "\(idNum)"
            } else {
                image.accessibilityIdentifier = "background"
            }
            completion(image)
        }
        task.resume()
    }
}
