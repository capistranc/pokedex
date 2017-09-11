
//
//  TableViewController
//  pokedex
//
//  Created by Mac on 8/31/17.
//  Copyright © 2017 Mac. All rights reserved.
//
import UIKit

class PokemonTableController: UITableViewController {
    var imageView:UIImageView!
    var user = User()
    var pokemonList:[String] = []
    
    func assignBackground(background:UIImage) {
        self.tableView.backgroundView = UIImageView(image: background)
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        assignBackground()
        let api = Networking()
        api.delegate = self
        
        api.getPokemonPage(callType: .PokemonList, forId: nil)
        api.getPokemonImage(type: .Background1, for: nil)
        
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
        
        let api = Networking()
        api.delegate = self
        
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") else {
            fatalError("No cell created, bad Identifier")}
        var idText = String(indexPath.row+1);
        if idText.characters.count == 2 {idText = "0" + idText}
        if idText.characters.count == 1 {idText = "00" + idText}
        cell.textLabel?.text = idText + " " + self.pokemonList[indexPath.row]
        cell.textLabel?.textColor = .white
        
        cell.detailTextLabel?.text = user.nicknames[indexPath.row+1]
        cell.detailTextLabel?.textColor = .white
        if cell.imageView?.image == nil {
            api.getPokemonImage(type: .PokeSprite, for: indexPath.row+1)
        }
        
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
            let i = IndexPath(row: id-1, section: 0)
            guard let cell = self.tableView.cellForRow(at: i) else {return print("badCellId")}
            cell.imageView?.image = image
                self.tableView.reloadData()
            }
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
