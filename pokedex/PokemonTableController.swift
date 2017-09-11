
//
//  TableViewController
//  pokedex
//
//  Created by Mac on 8/31/17.
//  Copyright © 2017 Mac. All rights reserved.
//
import UIKit

class PokemonTableController: UITableViewController {
    weak var imageView:UIImageView!
    
    var pokemonList:[String] = []
    func assignBackground() {
        let background = UIImage(named: "background")
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
        cell.textLabel?.text = self.pokemonList[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {return}
        guard identifier == "ToPokemonView" else {return}
        guard let nextView = segue.destination as? PokemonViewController else {return}
        guard let indexPath = self.tableView.indexPathForSelectedRow else {return}
        
        nextView.selectedPokemonId = indexPath.row + 1
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
    
    func apiDidReturnWithImage(image: UIImage) {
        return
    }
    
    func apiDidFailWithError(error: NetworkError) {
        print(error)
    }
    
    func apiResponseFailure(status: NetworkError){
        print(status)
    }
}
