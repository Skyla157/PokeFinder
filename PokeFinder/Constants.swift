//
//  Constants.swift
//  110-Pokedex-By-Devslopes
//
//  Created by Meagan McDonald on 5/26/16.
//  Copyright © 2016 Skyla157. All rights reserved.
//

import Foundation
import MapKit

let URL_BASE = "http://pokeapi.co"
let URL_POKEMON = "/api/v1/pokemon/"

//custom closure
typealias DownloadComplete = () -> ()

//Shared
var savedPokemon: Pokemon!
var savedLocation = CLLocation()
