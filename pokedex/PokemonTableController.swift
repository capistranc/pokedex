
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
//    static var pokemons:[Int:Pokemon] = [:]
    var pokemonImages:[Int:UIImage] = [:]
    
    func assignBackground(background:UIImage) {
        DispatchQueue.main.async {
            self.tableView.backgroundView = UIImageView(image: background)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Networking.getPokemonPage(callType: .PokemonList, forId: nil) {[unowned self] json in
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
        
        Networking.getPokemonImage(callType: .Background1, forId: nil) { image in
            self.assignBackground(background: image)
        }
        
        for i in 1...151 {
            Networking.getPokemonImage(callType: .PokeSprite, forId: i) { [unowned self] image in
                guard let idStr = image.accessibilityIdentifier else {return print("badId")}
                guard let id = Int(idStr) else {return print("idNotAnInt")}
                DispatchQueue.main.async {
                    self.pokemonImages[i] = image
                }
                
            }
        }
        print("end of loading:", self.pokemonList)
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
        print(idText)
        print(thisId)
        if idText.characters.count == 2 {idText = "0" + idText}
        if idText.characters.count == 1 {idText = "00" + idText}
        cell.textLabel?.text = idText + " " + self.pokemonList[indexPath.row]
        cell.textLabel?.textColor = .white
        
        cell.detailTextLabel?.text = user.nicknames[thisId]
        cell.detailTextLabel?.textColor = .white
        cell.imageView?.image = pokemonImages[thisId]
        return cell
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
