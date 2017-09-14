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
    var user:User?
    var pokemon:Pokemon?
    var backgroundImageView : UIImageView!
    
    @IBOutlet weak var mainViewContainer: UIStackView!
    
    @IBOutlet weak var shinySwitch: UISwitch!
    @IBOutlet weak var nicknameField: UITextField!
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
        evo1.tag = 0
        evo2.tag = 1
        evo3.tag = 2
        
        initPageWithId(id: pokeId)
        
        
        flavorText.numberOfLines = 0
        flavorText.sizeToFit()
    }
    
    func initPageWithId(id:Int) {
        guard let user = user else {return}
        
        Networking.getPokemonImage(callType: .Background2, forId: nil) { [weak self] image in
            self?.assignBackground(background: image)
        }
        Networking.getPokemonPage(callType: .Pokemon, forId: id) { [weak self] json in
            DispatchQueue.main.async {
                self?.pokemon?.initWithJson(json: json)
                self?.updateView()
            }
        }
        
        Networking.getPokemonPage(callType: .SpeciesInfo, forId: id) { [weak self] json in
            DispatchQueue.main.async{
                self?.pokemon?.setFlavorText(json: json)
                self?.updateView()
                Networking.getPokemonPage(callType: .EvolutionChain, forId: self?.pokemon?.evolutionId){ [weak self] json in
                    DispatchQueue.main.async {
                        
                        self?.pokemon?.setEvolutionLine(json: json)
                        
                        guard let evoList = self?.pokemon?.evo else {return print("broke at evoList")}
                        for evoId in evoList {
                            guard let this = self else {return}
                            Networking.getPokemonImage(callType: .EvoSprite, forId: evoId, completion: this.setEvolutionImages)
                        }
                        self?.setEvolutionButtons(count: evoList.count)
                        self?.updateView()
                    }
                }
            }
        }
        
        if (user.favorites[id] == true) {
            Networking.getPokemonImage(callType: .ShinySprite, forId: id) { [weak self] image in
                DispatchQueue.main.async{self?.pokemonSprite.image = image}
            }
            shinySwitch.isOn = true
        } else {
            Networking.getPokemonImage(callType: .PokeSprite, forId: id) { [weak self] image in
                DispatchQueue.main.async{self?.pokemonSprite.image = image}
            }
            shinySwitch.isOn = false
        }
    }
    
    func setEvolutionButtons(count:Int) {
        DispatchQueue.main.async{
            if count < 3 {
                self.evo3.isHidden = true
                self.evo3.isEnabled = false
            }
            if count < 2 {
                self.evo2.isHidden = true
                self.evo2.isEnabled = false
            }
            if count == 1 {
                self.evo1.isEnabled = false
            }
        }
    }
    
    func setEvolutionImages(image:UIImage) {
        guard let evo = self.pokemon?.evo else {return print("failed gaurd 1")}
        if evo.count == 1 {self.evo1.setImage(image, for: .normal)}
        
        let evoStrings:[String] = evo.flatMap{String($0)}
        if evoStrings.count == 2 {
            guard let imageStr = image.accessibilityIdentifier else {return print("failedAtImageAccessID")}
            DispatchQueue.main.async{
                if imageStr == evoStrings[0] {
                    self.evo1.setImage(image, for: .normal)
                } else {
                    self.evo2.setImage(image, for: .normal)
                }
            }
        }
        
        if evoStrings.count == 3 {
            guard let imageStr = image.accessibilityIdentifier else {return print("failedAtImageAccessID")}
            
            DispatchQueue.main.async{
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
    
    func updateView() {
        DispatchQueue.main.async{
            guard let pokeId = self.selectedPokemonId else {return}
            var idText = String(pokeId);
            if idText.characters.count == 2 {idText = "0" + idText}
            if idText.characters.count == 1 {idText = "00" + idText}
            self.nameLabel.text = idText + " \(self.pokemon?.name?.capitalized ?? "")"
            self.typeLabel.text = "Type: \(self.pokemon?.types?.joined(separator: ", ").capitalized ?? "")"
            self.heightLabel.text = "Height: \(self.pokemon?.height ?? 0)"
            self.weightLabel.text = "Weight: \(self.pokemon?.weight ?? 0)"
            self.flavorText.text = self.pokemon?.flavorText ?? ""
            if let type = self.pokemon?.types {
                self.selectBackground(type: type[0])
            }
        }
    }
    
    func selectBackground(type: String) {
        switch type {
        default:
            //            assignBackground(name: "defaultBackground")
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func assignBackground(background:UIImage) {
        DispatchQueue.main.async {
            self.backgroundImageView = UIImageView(frame: self.view.bounds)
            self.backgroundImageView.contentMode =  UIViewContentMode.scaleAspectFill
            self.backgroundImageView.clipsToBounds = true
            self.backgroundImageView.image = background
            self.backgroundImageView.center = self.view.center
            self.view.addSubview(self.backgroundImageView)
            self.view.sendSubview(toBack: self.backgroundImageView)
        }
    }
    
    @IBAction func evoButtonTapped(_ sender:Any) {
        guard let button = sender as? UIButton else {return}
        guard let newSelectedPokemonId = self.pokemon?.evo?[button.tag] else {return}
        DispatchQueue.main.async {
            self.selectedPokemonId = newSelectedPokemonId
            self.pokemonSprite.image = button.imageView?.image
        }
        initPageWithId(id: newSelectedPokemonId)
    }
    
    @IBAction func shinyTouched(_ sender: Any) {
        guard let id = selectedPokemonId else {return}
        guard let currentUser = user else {return}
        
        if let fav = currentUser.favorites[id] {
            user?.favorites[id] = !fav
        } else {
            user?.favorites[id] = true
        }
        initPageWithId(id: id)
    }
}
