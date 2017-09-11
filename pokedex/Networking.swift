//
//  Networking.swift
//  pokedex
//
//  Created by Mac on 9/8/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import UIKit

enum NetworkError:Error {
    case ApiFailed(String)
    case ApiBadResponse(Int)
}

protocol NetworkingDelegate:class { // functions to return to master
    func apiDidReturnWithJson(json: [String:Any], callType: ApiPage)
    func apiDidReturnWithImage(image: UIImage)
    
    func apiDidFailWithError(error: NetworkError)
    func apiResponseFailure(status: NetworkError)
}

enum ApiPage {
    case PokemonList
    case Pokemon
    case EvolutionChain
    case SpeciesInfo
}

func setPage(for callType: ApiPage) -> String {
    switch callType {
    case .PokemonList:
        return "pokemon/?limit=151"
    case .Pokemon:
        return "pokemon/"
    case .EvolutionChain:
        return "evolution-chain/"
    case .SpeciesInfo:
        return "pokemon-species/"
    }
}

class Networking {
    weak var delegate:NetworkingDelegate? //This is our master
    let basePage = "https://pokeapi.co/api/v2/"
    
    func getPokemonPage(callType:ApiPage,forId id:Int?) {
        var page = setPage(for: callType)
        if let idStr = id {page = page + "\(idStr)"}
        
        guard let url = URL(string: basePage + page) else {
            self.delegate?.apiDidFailWithError(error: .ApiFailed("bad api endpoint"))
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                self.delegate?.apiDidFailWithError(error: .ApiFailed(error!.localizedDescription))
                return
            }
            guard let res = response as? HTTPURLResponse else {return}
            guard res.statusCode == 200 else {
                self.delegate?.apiResponseFailure(status: .ApiBadResponse(res.statusCode))
                return
            }
            guard let data = data else {return}
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data)
                guard let json = jsonObject as? [String:Any] else {return}
                self.delegate?.apiDidReturnWithJson(json: json, callType: callType)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func getPokemonImage(for id:Int) {
        let urlString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png"
        guard let url = URL(string: urlString) else {
            self.delegate?.apiDidFailWithError(error: .ApiFailed("bad api endpoint"))
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                self.delegate?.apiDidFailWithError(error: .ApiFailed(error!.localizedDescription))
                return
            }
            
            guard let res = response as? HTTPURLResponse else {return}
            guard res.statusCode == 200 else {
                self.delegate?.apiResponseFailure(status: .ApiBadResponse(res.statusCode))
                return
            }
            
            guard let data = data else {return}
            guard let image = UIImage(data:data) else {return}
            image.accessibilityIdentifier = "\(id)"
            self.delegate?.apiDidReturnWithImage(image: image)
        }
        
        task.resume()
    }
}
