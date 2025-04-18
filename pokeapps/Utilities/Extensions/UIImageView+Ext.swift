//
//  UIImageView+Ext.swift
//  pokeapps
//
//  Created by Faza Azizi on 18/04/25.
//

import Foundation
import Kingfisher

extension UIImageView {
    func loadImageUrl(_ url: String, placeholder: String = "ic_pokeball") {
        let placeholderImage = UIImage(named: placeholder)
        if let imageUrl = URL(string: url) {
            self.kf.setImage(
                with: imageUrl,
                placeholder: placeholderImage,
                options: [
                    .transition(.fade(0.2)),
                    .backgroundDecode,
                    .cacheOriginalImage
                ]
            )
        } else {
            self.image = placeholderImage
        }
    }
}
