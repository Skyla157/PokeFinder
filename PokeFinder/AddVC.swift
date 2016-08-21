//
//  AddVC.swift
//  PokeFinder
//
//  Created by Meagan McDonald on 8/19/16.
//  Copyright © 2016 Skyla Apps. All rights reserved.
//

import UIKit
import MapKit

class AddVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    var loc: CLLocation!
    var pokemon = [Pokemon]()
    var inSearchMode = false
    var filteredPokemon = [Pokemon]()
    var selectedPokemon: Pokemon!
    var isSelected: Bool = false
    
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var detailsBtn: AddBtns!
    @IBOutlet weak var saveBtn: AddBtns!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.delegate = self
        collection.dataSource = self
        searchBar.delegate = self
        
        searchBar.returnKeyType = UIReturnKeyType.done
        
        parsePokemonCSV()
        
        saveBtn.isEnabled = false
        detailsBtn.isEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print(loc)
    }
    
    func parsePokemonCSV() {
        let path = Bundle.main.path(forResource: "pokemon", ofType: "csv")!
        
        do {
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
            
            for row in rows {
                let pokeID = Int(row["id"]!)!
                let name = row["identifier"]!
                
                let poke = Pokemon(name: name, iD: pokeID)
                pokemon.append(poke)
            }
        } catch let err as NSError {
            print(err.description)
        }
        
        pokemon.sort(by: { $0.name < $1.name })
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if inSearchMode {
            return filteredPokemon.count
        }
        return pokemon.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokeCell", for: indexPath) as? PokeCell {
            
            let poke: Pokemon!
            if inSearchMode {
                poke = filteredPokemon[indexPath.row]
            } else {
                poke = pokemon[indexPath.row]
            }
            
            if isSelected && poke.name == selectedPokemon.name {
                cell.layer.borderWidth = 2.0
                cell.layer.borderColor = UIColor.gray.cgColor
            } else {
                cell.layer.borderWidth = 0.0
                cell.layer.borderColor = UIColor.clear.cgColor
            }
            
            cell.configureCell(pokemonCell: poke)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collection.cellForItem(at: indexPath) {
            cell.layer.borderWidth = 0.0
            cell.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isSelected = true
        if let cell = collection.cellForItem(at: indexPath) {
            cell.layer.borderWidth = 2.0
            cell.layer.borderColor = UIColor.gray.cgColor
        }
        
        if inSearchMode {
            selectedPokemon = filteredPokemon[indexPath.row]
        } else {
            selectedPokemon = pokemon[indexPath.row]
        }
        print("didSelectItemAt: ", selectedPokemon.name)
        
        saveBtn.isEnabled = true
        detailsBtn.isEnabled = true
        
        //will only work if segue is from VC, not from cell. Will not be called if from cell
        //performSegue(withIdentifier: "PokemonDetailVC", sender: poke)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)   //hides keyboard
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            inSearchMode = false
            //filteredPokemon = [Pokemon]()
            view.endEditing(true)   //hides keyboard
            collection.reloadData()
        } else {
            inSearchMode = true
            let lower = searchBar.text!.lowercased()
            //$0 grabs element out of array
            filteredPokemon = pokemon.filter({$0.name.range(of: lower) != nil})
            collection.reloadData()
        }
    }
    
    @IBAction func onBackBtnPress(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSaveBtnPress(_ sender: AnyObject) {
        savedPokemon = selectedPokemon
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "savePokemon"), object: nil)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onDetailsBtnPress(_ sender: AnyObject) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PokemonDetailVC" {
            if let detailsVC = segue.destination as? PokemonDetailVC {
                print("detailsVC = segue.destination")
                detailsVC.pokemon = selectedPokemon
            }
        }
    }
    
}
