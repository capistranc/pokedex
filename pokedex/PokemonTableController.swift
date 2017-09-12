
//
//  TableViewController
//  pokedex
//
//  Created by Mac on 8/31/17.
//  Copyright © 2017 Mac. All rights reserved.
//
import UIKit

class PokemonTableController: UITableViewController {
    var user = User()
    var pokemonList:[String] = []
    var pokemonImages:[Int:UIImage] = [:]
    
    func assignBackground(background:UIImage) {
        self.tableView.backgroundView = UIImageView(image: background)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let api = Networking()
        api.delegate = self
        
        api.getPokemonPage(callType: .PokemonList, forId: nil)
        api.getPokemonImage(type: .Background1, for: nil)
        
        for i in 1...151 {
            api.getPokemonImage(type: .PokeSprite, for: i)
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pokemonList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") else {
            fatalError("No cell created, bad Identifier")}
        let thisId = indexPath.row+1
        var idText = String(thisId);
        if idText.characters.count == 2 {idText = "0" + idText}
        if idText.characters.count == 1 {idText = "00" + idText}
        cell.textLabel?.text = idText + " " + self.pokemonList[indexPath.row]
        cell.textLabel?.textColor = .white
        
        cell.detailTextLabel?.text = user.nicknames[thisId]
        cell.detailTextLabel?.textColor = .white
        cell.imageView?.image = pokemonImages[thisId]
        return cell
    }
    
    func getPokeImage(id:Int) {
        let api = Networking()
        api.delegate = self
        api.getPokemonImage(type: .PokeSprite, for: id)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {return}
        guard identifier == "ToPokemonView" else {return}
        guard let nextView = segue.destination as? PokemonViewController else {return}
        guard let indexPath = self.tableView.indexPathForSelectedRow else {return}
        
        nextView.selectedPokemonId = indexPath.row + 1
        nextView.user = self.user
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension PokemonTableController:NetworkingDelegate {
    func apiDidReturnWithJson(json:[String:Any], callType:ApiPage) {
        if callType == .PokemonList {
            guard let results = json["results"] as? [[String:Any]] else {return}
            let pokeList = results.flatMap{ $0["name"] as? String}.map{$0.capitalized}
            DispatchQueue.main.async { // should only be used for UI updates
                if self.pokemonList != [] {
                    self.pokemonList.append(contentsOf: pokeList)
                } else {
                    self.pokemonList = pokeList
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func apiDidReturnWithImage(type:PokeImageType, image: UIImage) {
        switch type {
        case .Background1:
            DispatchQueue.main.async {
                self.assignBackground(background: image)
            }
        case .PokeSprite:
            DispatchQueue.main.async {
                guard let idStr = image.accessibilityIdentifier else {return print("badId")}
                guard let id = Int(idStr) else {return print("idNotAnInt")}
                self.pokemonImages[id] = image
                self.tableView.reloadData()
            }
            break
        default:
            break
        }
    }
    
    func apiDidFailWithError(error: NetworkError) {
        print(error)
    }
    func apiResponseFailure(status: NetworkError){
        print(status)
    }
}
