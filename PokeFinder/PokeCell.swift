//
//  PokeCell.swift
//  110-Pokedex-By-Devslopes
//
//  Created by Meagan McDonald on 5/25/16.
//  Copyright © 2016 Skyla157. All rights reserved.
//

import UIKit

class PokeCell: UICollectionViewCell {
    @IBOutlet weak var thumbImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    //var pokemon: Pokemon!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.cornerRadius = 5.0
    }
    
    func configureCell(pokemonCell: Pokemon) {
        //self.pokemon = pokemon
        
        nameLbl.text = pokemonCell.name.capitalized
        thumbImg.image = UIImage(named: "\(pokemonCell.pokedexID)")
    }
}
