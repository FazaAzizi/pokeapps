//
//  PokemonListTableViewCell.swift
//  pokeapps
//
//  Created by Faza Azizi on 18/04/25.
//

import UIKit

class PokemonListTVC: UITableViewCell {

    @IBOutlet weak var containerVw: UIView!
    @IBOutlet weak var containerImageVw: UIView!
    @IBOutlet weak var pokemonImgVw: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var containerTypeVw: UIView!
    @IBOutlet weak var typeLbl: UILabel!
    
    static let identifier = String(describing: PokemonListTVC.self)
    
    static let nib = {
       UINib(nibName: identifier, bundle: nil)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerVw.makeCornerRadius(8)
        containerTypeVw.makeCornerRadius(8)
        containerImageVw.makeCornerRadius(8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension PokemonListTVC {
    func configureCell(data: PokemonDetail) {
        nameLbl.text = data.name
        typeLbl.text = data.types?.compactMap { $0.type?.name }.joined(separator: ", ")
        containerVw.setBackground(type: data.types?.first?.type?.name ?? "")
        
        if let img = data.sprites?.frontDefault {
            pokemonImgVw.loadImageUrl(img)
        }
        
    }
}
