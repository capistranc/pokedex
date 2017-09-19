
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
    var calledSet = Set<Int>()
    let loadingSpinner = UIActivityIndicatorView()
    
    func assignBackground(background:UIImage) {
        DispatchQueue.main.async {
            self.tableView.backgroundView = UIImageView(image: background)
            self.tableView.backgroundView?.addSubview(self.loadingSpinner)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingSpinner.activityIndicatorViewStyle = .gray
        loadingSpinner.hidesWhenStopped = true
        loadingSpinner.startAnimating()
        loadingSpinner.frame = self.view.bounds
        loadingSpinner.transform = CGAffineTransform.init(scaleX: 2.0, y: 2.0)
        loadingSpinner.center = self.view.center
        loadingSpinner.color = .white
        
        
        Networking.getPokemonImage(callType: .Background1, forId: nil) { (image, err) in
            guard err == nil else {return print(err!)}
            guard let image = image else {return}
            self.assignBackground(background: image)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.height
        let atBottom:Bool = scrollView.contentOffset.y >= bottomEdge
        let pokeLen = pokemonList.count
        //        print("at bottom?", atBottom)
        if atBottom && pokeLen < 151 && !calledSet.contains(pokeLen) {
            calledSet.insert(pokeLen)
            loadingSpinner.startAnimating()
            Networking.getPokemonPage(callType: .PokemonList, forId: pokemonList.count){
                [unowned self] (json, err) in
                guard err == nil else {return print(err!)}
                guard let json = json else {return}
                guard let results = json["results"] as? [[String:Any]] else {return}
                let pokeList = results.flatMap{ $0["name"] as? String}.map{$0.capitalized}
                DispatchQueue.main.async {
                    self.loadingSpinner.stopAnimating()
                    if pokeLen == 140 {
                        self.loadingSpinner.isHidden = true
                        self.pokemonList.append(contentsOf: pokeList[0...10])
                    } else {
                        self.pokemonList.append(contentsOf: pokeList)
                    }
                    self.loadingSpinner.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let len = self.pokemonList.count
        //        return len == 151 ? len : len+1
        return len
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == pokemonList.count ? 100 : 75
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.navigationController?.navigationBar.barTintColor = .lightGray
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as? PokeCell else { fatalError("No cell created, bad Identifier") }
        let thisId = indexPath.row + 1
        let name = self.pokemonList[indexPath.row]
        cell.fillCell(id: thisId, name: name)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {return}
        guard identifier == "ToPokemonView" else {return}
        guard let nextView = segue.destination as? PokemonViewController else {return}
        guard let indexPath = self.tableView.indexPathForSelectedRow else {return}
        
        let pokeId = indexPath.row+1
        print("pokeid", pokeId)
        
        nextView.selectedPokemonId = pokeId
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
