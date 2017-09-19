//
//  PokemonTypeVC.swift
//  pokedex
//
//  Created by Mac on 9/18/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import UIKit

class PokemonTypeVC:UITableViewController {
    let loadingSpinner = UIActivityIndicatorView()
    let sections = ["Double Damage To", "Half Damage To", "No Damage To","Double Damage From", "Half Damage From", "No Damage From", "Pokemon"]
    
    var sectionsData:[[String]]?
    var selectedTypeId:Int?
    var type:PokemonType?
    
    @IBOutlet weak var HomeButton: UIBarButtonItem!
    
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
        
        guard let typeId = selectedTypeId else {return print("didnt get id")}
        let type = PokemonType(id: typeId)
        type.fetchDataForView {
            self.type = type
            self.sectionsData = [type.doubleDamageTo, type.halfDamageTo, type.noDamageTo, type.doubleDamageFrom, type.halfDamageFrom, type.noDamageFrom, type.pokemon.map{$0.1}]
            DispatchQueue.main.async{
                self.loadingSpinner.stopAnimating()
                self.tableView.reloadData()
            }
        }
   
    
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        print(self.sections.count)
        return self.sections.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionsData?[section].count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "typeCell")  else { fatalError("No cell created, bad Identifier") }
        guard let sectionData = sectionsData else {fatalError("u dun goofed")}
        let dataSet = sectionData[indexPath.section]
        let text = dataSet[indexPath.row]
        cell.textLabel?.text = text
        cell.textLabel?.textColor = .white
        return cell
    }
    
    @IBAction func pokedexNavButtonTouched() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
