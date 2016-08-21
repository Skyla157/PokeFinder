//
//  Pokemon.swift
//  110-Pokedex-By-Devslopes
//
//  Created by Meagan McDonald on 5/25/16.
//  Copyright © 2016 Skyla157. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    private var _name: String!
    private var _pokedexID: Int!
    private var _description: String!
    private var _type: String!
    private var _defense: String!
    private var _height: String!
    private var _weight: String!
    private var _attack: String!
    private var _nextEvolutionTxt: String!
    private var _nextEvolutionID: String!
    private var _nextEvolutionLvl: String!
    private var _pokemonURL: String!
    
    var name: String {
        return _name
    }
    
    var pokedexID: Int {
        return _pokedexID
    }
    
    var description: String {
        if _description == nil {
            _description = ""
        }
        return _description
    }
    
    var type: String {
        if _type == nil {
            _type = ""
        }
        return _type
    }
    
    var defense: String {
        if _defense == nil {
            _defense = ""
        }
        return _defense
    }
    
    var height: String {
        if _height == nil {
            _height = ""
        }
        return _height
    }
    
    var weight: String {
        if _weight == nil {
            _weight = ""
        }
        return _weight
    }
    
    var attack: String {
        if _attack == nil {
            _attack = ""
        }
        return _attack
    }
    
    var nextEvolutionTxt: String {
        if _nextEvolutionTxt == nil {
            _nextEvolutionTxt = ""
        }
        return _nextEvolutionTxt
    }
    
    var nextEvolutionID: String {
        if _nextEvolutionID == nil {
            _nextEvolutionID = ""
        }
        return _nextEvolutionID
    }
    
    var nextEvolutionLvl: String {
        if _nextEvolutionLvl == nil {
            _nextEvolutionLvl = ""
        }
        return _nextEvolutionLvl
    }
    
    init() {}
    
    init(name: String, iD: Int) {
        self._name = name
        self._pokedexID = iD
        
        _pokemonURL = "\(URL_BASE)\(URL_POKEMON)\(self._pokedexID!)/"
    }
    
    func downloadPokemonDetails(completed: DownloadComplete) {
        
        Alamofire.request(_pokemonURL as URLStringConvertible, withMethod: .get, parameters: nil, encoding: .url, headers: nil).responseJSON { response in
            let result = response.result
            //print(result.value.debugDescription)
            
            if let dict = result.value as? Dictionary<String, AnyObject> {
                if let weight = dict["weight"] as? String {
                    self._weight = weight
                }
                
                if let height = dict["height"] as? String {
                    self._height = height
                }
                
                if let attack = dict["attack"] as? Int {
                    self._attack = "\(attack)"
                }
                
                if let defense = dict["defense"] as? Int {
                    self._defense = "\(defense)"
                }
                
                //array of type dictionary of string, string
                if let types = dict["types"] as? [Dictionary<String, String>], types.count > 0 {
                    if let name = types[0]["name"] {
                        self._type = name.capitalized
                    }
                    if types.count > 1 {
                        for x in 1...types.count - 1 {
                            if let name = types[x]["name"] {
                                self._type! += "/\(name.capitalized)"
                            }
                        }
                    }
                } else {
                    self._type = ""
                }
                    
                if let evolutions = dict["evolutions"] as? [Dictionary<String, AnyObject>], evolutions.count > 0 {
                    if let to = evolutions[0]["to"] as? String {
                        //"Mega" is not found
                        if to.range(of: "mega") == nil {
                            if let uri = evolutions[0]["resource_uri"] as? String {
                                let newStr = uri.replacingOccurrences(of: "/api/v1/pokemon/", with: "")
                                let num = newStr.replacingOccurrences(of: "/", with: "")
                                self._nextEvolutionID = num
                                self._nextEvolutionTxt = to
                                
                                if let level = evolutions[0]["level"] as? Int {
                                    self._nextEvolutionLvl = "\(level)"
                                }
                            }
                        }
                    }
                }
                
                if let descArr = dict["descriptions"] as? [Dictionary<String, String>], descArr.count > 0 {
                    if let urlStr = descArr[0]["resource_uri"] {
                        Alamofire.request("\(URL_BASE)\(urlStr)" as URLStringConvertible, withMethod: .get, parameters: nil, encoding: .url, headers: nil).responseJSON { response in
                            let desResult = response.result
                            if let descDict = desResult.value as? Dictionary<String, AnyObject> {
                                if let description = descDict["description"] as? String {
                                    self._description = description
                                    
                                }
                            }
                            completed()
                        }
                    }
                } else {
                    self._description = ""
                }
            }
        }
    }
}
