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

    func fillCell(id:String) {
//        self.textLabel?.text = "\(id)"
        
        if let image = Cache.shared.imageCache.object(forKey: id as NSString) {
            self.imageView?.image = image
        } else {
            Networking.getPokemonImage(callType: .PokeSprite, forId: Int(id)){ [weak self] image in
//                guard error == nil else {return}
//                guard let image = image as? UIImage else {return}
                Cache.shared.imageCache.setObject(image, forKey: id as NSString)
                DispatchQueue.main.async {
                    self?.imageView?.image = image
                }
            }
        }
        
    }
}

