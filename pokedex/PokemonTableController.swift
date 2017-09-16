
//
//  TableViewController
//  pokedex
//
//  Created by Mac on 8/31/17.
//  Copyright © 2017 Mac. All rights reserved.
//
import UIKit

class PokemonTableController: UITableViewController {
    var pokemonList:[String] = []
    var pokemonImages:[Int:UIImage] = [:]
    var calledSet = Set<Int>()
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    func assignBackground(background:UIImage) {
        DispatchQueue.main.async {
            self.tableView.backgroundView = UIImageView(image: background)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calledSet.insert(0)
        loadingIndicator.activityIndicatorViewStyle = .gray
        
        loadingIndicator.startAnimating()
        loadingIndicator.hidesWhenStopped = true
        Networking.getPokemonPage(callType: .PokemonList, forId: 0) {[unowned self] json in
            guard let results = json["results"] as? [[String:Any]] else {return}
            let pokeList = results.flatMap{ $0["name"] as? String}.map{$0.capitalized}
            DispatchQueue.main.async { // should only be used for UI updates
                self.pokemonList = pokeList
                self.tableView.reloadData()
            }
        }
        
        Networking.getPokemonImage(callType: .Background1, forId: nil) { image in
            self.assignBackground(background: image)
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.height
        let atBottom:Bool = scrollView.contentOffset.y >= bottomEdge
        let pokeLen = pokemonList.count
        print("at bottom?", atBottom)
        loadingIndicator.startAnimating()
        if atBottom && pokeLen < 151 && !calledSet.contains(pokeLen) {
            calledSet.insert(pokeLen)
            Networking.getPokemonPage(callType: .PokemonList, forId: pokemonList.count){
                [unowned self] json in
                guard let results = json["results"] as? [[String:Any]] else {return}
                let pokeList = results.flatMap{ $0["name"] as? String}.map{$0.capitalized}
                DispatchQueue.main.async {
                    if pokeLen >= 151 {
                        self.pokemonList.append(contentsOf: pokeList[0...151])
                    } else {
                        self.pokemonList.append(contentsOf: pokeList)
                    }
                    
                    self.tableView.reloadData()
                    self.loadingIndicator.stopAnimating()
                }
                
            }
        }
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pokemonList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as? PokeCell else { fatalError("No cell created, bad Identifier") }

        let thisId = indexPath.row + 1
        var idText = String(thisId)
        if idText.characters.count == 2 {idText = "0" + idText}
        if idText.characters.count == 1 {idText = "00" + idText}
        cell.textLabel?.text = idText + " " + self.pokemonList[indexPath.row]
        cell.textLabel?.textColor = .white
        //        cell.detailTextLabel?.text = user.nicknames[thisId]
        cell.detailTextLabel?.textColor = .white
        cell.fillCell(id: idText)
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
