//
//  Product.swift
//  OnlineStoreMV
//
//  Created by Pedro Rojas on 04/03/24.
//

import Foundation

struct Product: Equatable, Identifiable {
    let id: Int
    let title: String
    var price: Double // Update to Currency
    let description: String
    let category: String // Update to enum
    let imageURL: URL
    var percentageDiscount: Double? // Discount percentage (0.0 to 1.0), nil if no discount
    
    var hasDiscount: Bool {
        return percentageDiscount != nil
    }
    
    var discountedPrice: Double {
        guard let discount = percentageDiscount else {
            return price
        }
        return price * (1 - discount)
    }
    
    // Add rating later...
}

extension Product: Decodable {
    enum ProductKeys: String, CodingKey {
        case id
        case title
        case price
        case description
        case category
        case image
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ProductKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.price = try container.decode(Double.self, forKey: .price)
        self.description = try container.decode(String.self, forKey: .description)
        self.category = try container.decode(String.self, forKey: .category)
        let imageString = try container.decode(String.self, forKey: .image)
        
        self.imageURL = URL(string: imageString)!
    }
}

