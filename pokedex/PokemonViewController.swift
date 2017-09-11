//
//  PokemonView.swift
//  pokedex
//
//  Created by Mac on 9/8/17.
//  Copyright © 2017 Mac. All rights reserved.
//


import Foundation
import UIKit

class PokemonViewController:UIViewController {
    var selectedPokemonId:Int?
    var pokemon:Pokemon?
    var imageView : UIImageView!
    
    @IBOutlet weak var nicknameField: UITextField!
    @IBOutlet weak var nicknameButton: UIButton!
    @IBOutlet weak var shinyButton: UIButton!
    @IBOutlet weak var pokemonSpriteButton: UIButton!
    @IBOutlet weak var pokemonSprite: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var flavorText: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var evo1: UIButton!
    @IBOutlet weak var evo2: UIButton!
    @IBOutlet weak var evo3: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let pokeId = selectedPokemonId else {return}
        self.pokemon = Pokemon(id: pokeId)
        let api = Networking()
        api.delegate = self
        
        api.getPokemonPage(callType: .Pokemon, forId: pokeId)
        api.getPokemonPage(callType: .SpeciesInfo, forId: pokeId)
        api.getPokemonImage(for: pokeId)
        flavorText.numberOfLines = 0
        flavorText.sizeToFit()
    }
    
    func initPageWithId(id:Int) {
        let api = Networking()
        api.delegate = self
        api.getPokemonPage(callType: .Pokemon, forId: id)
        api.getPokemonPage(callType: .SpeciesInfo, forId: id)
    }
    
    func updateView() {
        guard let pokeId = selectedPokemonId else {return}
        var idText = String(pokeId);
        if idText.characters.count == 2 {idText = "0" + idText}
        if idText.characters.count == 1 {idText = "00" + idText}
        nameLabel.text = idText + " \(pokemon?.name?.capitalized ?? "")"
        typeLabel.text = "Type: \(pokemon?.types?.joined(separator: ", ").capitalized ?? "")"
        heightLabel.text = "Height: \(pokemon?.height ?? 0)"
        weightLabel.text = "Weight: \(pokemon?.weight ?? 0)"
        flavorText.text = self.pokemon?.flavorText ?? ""
        if let type = pokemon?.types {
            selectBackground(type: type[0])
        }
    }
    
    func selectBackground(type: String) {
        switch type {
//                    case "fire":
//                        assignBackground(name: "fireBackground")
//                    case "grass":
//                        assignBackground(name: "grassBackground")
//                    case "water":
//                        assignBackground(name: "waterBackground")
//                    case "electric":
//                        assignBackground(name: "eletricBackground")
//                    case "fighting":
//                        assignBackground(name: "fightingBackground")
//                    case "psychic":
//                        fallthrough
//                    case "ghost":
//                        assignBackground(name: "psychicBackground")
//                        break
//                    case "ground":
//                        fallthrough
//                    case "rock":
//                        assignBackground(name: "groundBackground")
//                        break
//                    case "dragon":
//                        assignBackground(name: "dragonBackground")
        default:
            assignBackground(name: "defaultBackground")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func assignBackground(name: String){
        let background = UIImage(named: name)
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
    }
    
    @IBAction func evo1ButtonTapped() {
        guard let newSelectedPokemonId = self.pokemon?.evo?[0] else {return}
        self.selectedPokemonId = newSelectedPokemonId
        pokemonSprite.image = evo1.imageView?.image
        initPageWithId(id: newSelectedPokemonId)
    }
    @IBAction func evo2ButtonTapped() {
        guard let newSelectedPokemonId = self.pokemon?.evo?[1] else {return}
        self.selectedPokemonId = newSelectedPokemonId
        pokemonSprite.image = evo2.imageView?.image
        initPageWithId(id: newSelectedPokemonId)
        
    }
    @IBAction func evo3ButtonTapped() {
        guard let newSelectedPokemonId = self.pokemon?.evo?[2] else {return}
        initPageWithId(id: newSelectedPokemonId)
        pokemonSprite.image = evo3.imageView?.image
    }
}

extension PokemonViewController:NetworkingDelegate {
    func apiDidReturnWithJson(json:[String:Any], callType:ApiPage) {
        //        var currentPokemon:Pokemon
        let api = Networking()
        api.delegate = self
        DispatchQueue.main.async { // should only be used for UI updates
            switch callType {
            case .Pokemon:
                self.pokemon?.initWithJson(json: json)
                self.updateView()
            //                api.getPokemonPage(callType: .SpeciesInfo, forId: currentPokemon.id)
            case .SpeciesInfo:
                self.pokemon?.setFlavorText(json: json)
                api.getPokemonPage(callType: .EvolutionChain, forId: self.pokemon?.evolutionId)
                self.updateView()
            case .EvolutionChain:
                self.pokemon?.setEvolutionLine(json: json)
                guard let evoList = self.pokemon?.evo else {return print("broke at evoList")}
                for evoId in evoList {
                    api.getPokemonImage(for: evoId)
                }
                self.updateView()
                if evoList.count < 3 {
                    self.evo3.isHidden = true
                    self.evo3.isEnabled = false
                }
                if evoList.count < 2 {
                    self.evo2.isHidden = true
                    self.evo2.isEnabled = false
                }
                if evoList.count == 1 {
                    self.evo1.isEnabled = false
                }
            default:
                break
            }
        }
    }
    
    func apiDidReturnWithImage(image: UIImage) {
        if pokemonSprite.image == nil {
            pokemonSprite.image = image
        } else {
            guard let evo = pokemon?.evo else {return print("failed gaurd 1")}
            guard evo.count > 1 else {return print("failed guard 2")}
            let evoStrings = evo.flatMap{String($0)}
            if evoStrings.count == 2 {
                DispatchQueue.main.async {
                    if image.accessibilityIdentifier ==  evoStrings[0] {
                        self.evo1.setImage(image, for: .normal)
                    } else {
                        self.evo2.setImage(image, for: .normal)
                    }
                }
            }
            if evoStrings.count == 3 {
                guard let imageStr = image.accessibilityIdentifier else {return}
                DispatchQueue.main.async {
                    switch imageStr {
                    case evoStrings[0]:
                        self.evo1.setImage(image, for: .normal)
                    case evoStrings[1]:
                        self.evo2.setImage(image, for: .normal)
                    case evoStrings[2]:
                        self.evo3.setImage(image, for: .normal)
                    default: break
                    }
                    self.updateView()
                }
            }
        }
    }
    
    func apiDidFailWithError(error: NetworkError) {
        print(error)
    }
    func apiResponseFailure(status: NetworkError){
        print(status)
    }
}
