//
//  PokeCell.swift
//  pokedex
//
//  Created by Mac on 9/15/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import UIKit

class PokeCell:UITableViewCell {
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var myLabel: UILabel!
    
    func fillCell(id:Int, name:String) {
        var idText = String(id)
        myLabel.text = idText + " " + name
        myLabel.textColor = .white
        if idText.characters.count == 2 {idText = "0" + idText}
        if idText.characters.count == 1 {idText = "00" + idText}
        
        
        myLabel.text = name
        if let image = Cache.shared.imageCache.object(forKey: String(id) as NSString) {
            DispatchQueue.main.async{
            self.myImage.image = image
            }
        } else {
            Networking.getPokemonImage(callType: .PokeSprite, forId: id){ [weak self] (image, err) in
                guard err == nil else {return print(err!)}
                guard let image = image else {return}
                Cache.shared.imageHash[id] = image
                Cache.shared.imageCache.setObject(image, forKey: String(id) as NSString)
                DispatchQueue.main.async {
                    self?.myImage.image = image
                }
            }
        }
    }
}

