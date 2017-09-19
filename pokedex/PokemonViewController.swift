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
    var loadingView:UIImageView!
    let loadingSpinner = UIActivityIndicatorView()
    var typeView:Int?
    
    @IBOutlet weak var shinySwitch: UISwitch!
    
    @IBOutlet weak var pokedexNavButton: UIBarButtonItem!
    @IBOutlet weak var pokemonSprite: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var flavorText: UITextView!
    @IBOutlet weak var type1: UIButton!
    @IBOutlet weak var type2: UIButton!
    @IBOutlet weak var evo1: UIButton!
    @IBOutlet weak var evo2: UIButton!
    @IBOutlet weak var evo3: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        guard let pokeId = selectedPokemonId else {return print("noSelectedPokemonId")}
        
        self.loadingView = UIImageView(frame: UIScreen.main.bounds)
        self.loadingView.image = #imageLiteral(resourceName: "loading")
        self.loadingView.contentMode =  UIViewContentMode.scaleAspectFill
        self.view.insertSubview(loadingView, aboveSubview: self.view)
        
        evo1.tag = 0
        evo2.tag = 1
        evo3.tag = 2
        flavorText.layer.cornerRadius = 10.0
        flavorText.layer.borderWidth = 1
        flavorText.layer.borderColor = UIColor.black.cgColor
        
        type1.layer.cornerRadius = 10.0
        type2.layer.cornerRadius = 10.0
        
        pokemonSprite.layer.cornerRadius = 20.0
        
        loadingSpinner.activityIndicatorViewStyle = .gray
        loadingSpinner.hidesWhenStopped = true
        loadingSpinner.frame = self.view.bounds
        loadingSpinner.transform = CGAffineTransform.init(scaleX: 2.0, y: 2.0)
        loadingSpinner.center = self.view.center
        loadingSpinner.color = .white
        loadingSpinner.startAnimating()
        loadingView.insertSubview(loadingSpinner, aboveSubview: loadingView)
        
        let thisPokemon = Pokemon(id: pokeId)
        thisPokemon.fetchDataForView() {
            DispatchQueue.main.async{
                self.pokemon = thisPokemon
                self.initView()
            }
        }
        
        Networking.getPokemonImage(callType: .Background2, forId: nil) { [unowned self] (image, err) in
            guard err == nil else {return print(err!)}
            guard let image = image else {return}
            DispatchQueue.main.async {
                let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
                backgroundImage.image = image
                backgroundImage.contentMode =  UIViewContentMode.scaleAspectFill
                self.view.insertSubview(backgroundImage, at: 0)
                //                self.view.backgroundColor = UIColor(patternImage: image)
                //                let bgImageView = UIImageView(image: image)
                //                bgImageView.sendSubview(toBack: self.view)
            }
        }
    }
    
    func initView() {
        guard let pokeId = selectedPokemonId else {return print("noSelectedPokemonId")}
        var idText = String(pokeId);
        if idText.characters.count == 2 {idText = "0" + idText}
        if idText.characters.count == 1 {idText = "00" + idText}
        var basic = ""
        
        self.nameLabel.text = idText + " \(self.pokemon?.name?.capitalized ?? "")"
        basic = basic +  "\nHeight: \(self.pokemon?.height ?? 0)"
        basic = basic + "\nWeight: \(self.pokemon?.weight ?? 0)"
        basic = basic + "\n\n \(self.pokemon?.flavorText ?? "")"
        if let types = self.pokemon?.types {
            self.navigationController?.navigationBar.barTintColor = self.getColorForType(type: types[0])
            setTypeButtons(types: types)
        }
        
        self.flavorText.text = basic
        self.flavorText.sizeToFit()
        setPokeSprite()
        setEvolutionButtons()
        self.loadingView.removeFromSuperview()
        loadingSpinner.stopAnimating()
    }
    
    func setPokeSprite() {
        print("we here?")
        let user = Cache.shared.user
        guard let id = self.selectedPokemonId else {return print("bad id")}
        if user.favorites[id] == true {
            DispatchQueue.main.async{
                print("shiny image")
                self.pokemonSprite.image = self.pokemon?.shinyImage
            }
        } else {
            DispatchQueue.main.async{
                if let image = Cache.shared.imageHash[id] {
                    self.pokemonSprite.image = image
                }
            }
        }
    }
    
    func setTypeButtons(types:[String]) {
        guard let typeIds = self.pokemon?.typeUrlIds else {return print("failed type guard")}
        DispatchQueue.main.async {
            self.type1.tag = typeIds[0]
            if types.count == 1 {
                self.type2.isEnabled = false
                self.type2.isHidden = true
            } else {
                self.type2.tag = typeIds[1]
                self.type2.setTitle(types[1].capitalized, for: .normal)
                self.type2.backgroundColor = self.getColorForType(type: types[1])
            }
            self.type1.backgroundColor = self.getColorForType(type: types[0])
            self.type1.setTitle(types[0].capitalized, for: .normal)
        }
        
    }
    
    func setAbilityButtons(types:[String]) {
        guard let abilityIds = self.pokemon?.abilityUrlIds else {return print("failed type guard")}
        self.type1.tag = abilityIds[0]
        if types.count == 1 {
            self.type2.isEnabled = false
            self.type2.isHidden = true
        } else {
            self.type2.tag = abilityIds[1]
        }
    }
    
    func getColorForType(type:String) -> UIColor {
        switch type {
        case "fire":
            return UIColor.orange
        case "water":
            return UIColor.blue
        case "electric":
            return UIColor.yellow
        case "grass":
            return UIColor.green
        case "rock":
            fallthrough
        case "ground":
            return UIColor.brown
        case "psychic":
            fallthrough
        case "ghost":
            return UIColor.purple
        case "fighting":
            return UIColor.red
        case "dragon":
            return UIColor.blue
        case "fairy":
            return UIColor.red
        default:
            return UIColor.gray
        }
    }
    
    func setEvolutionButtons() {
        guard let evo = self.pokemon?.evos else {return print("failed evo guard 1")}
        let count = evo.count
        let evoStrings:[String] = evo.flatMap{String($0)}
        let evoImages:[UIImage] = evoStrings.flatMap{Cache.shared.imageCache.object(forKey: $0 as NSString)}
        switch count {
        case 3:
            self.evo1.setImage(evoImages[0], for: .normal)
            self.evo2.setImage(evoImages[1], for: .normal)
            self.evo3.setImage(evoImages[2], for: .normal)
        case 2:
            self.evo3.isHidden = true
            self.evo3.isEnabled = false
            self.evo1.setImage(evoImages[0], for: .normal)
            self.evo2.setImage(evoImages[1], for: .normal)
        case 1:
            self.evo3.isHidden = true
            self.evo3.isEnabled = false
            self.evo2.isHidden = true
            self.evo2.isEnabled = false
            self.evo1.isEnabled = false
            self.evo1.setImage(evoImages[0], for: .normal)
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func typeButtonTapped(_ sender:Any) {
        guard let button = sender as? UIButton else {return}
        self.typeView = button.tag
        
        //        guard let nextVC = storyboard?.instantiateViewController(withIdentifier: "PokeTypeVC") as? PokemonTypeVC else {return print("failed to instantiate new vc")}
        //        nextVC.selectedTypeId = typeId
        //        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func evoButtonTapped(_ sender:Any) {
        guard let button = sender as? UIButton else {return}
        guard let newId = self.pokemon?.evos[button.tag] else {return print("bad id")}
        guard let nextVC = storyboard?.instantiateViewController(withIdentifier: "PokeVC") as? PokemonViewController else {return print("failed to instantiate new vc")}
        nextVC.selectedPokemonId = newId
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let button = sender as? UIButton else {return}
        guard let identifier = segue.identifier else {return}
        guard identifier == "toTypeView" else {return}
        guard let nextView = segue.destination as? PokemonTypeVC else {return}
        nextView.selectedTypeId = button.tag
    }
    
    @IBAction func shinyTouched(_ sender: Any) {
        guard let id = selectedPokemonId else {return}
        let currentUser = Cache.shared.user
        
        if let fav = currentUser.favorites[id] {
            Cache.shared.user.favorites[id] = !fav
        } else {
            Cache.shared.user.favorites[id] = true
        }
        self.setPokeSprite()
    }
    
    @IBAction func pokedexNavButtonTouched() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

