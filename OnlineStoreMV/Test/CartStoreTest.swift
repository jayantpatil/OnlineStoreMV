//
//  CartStoreTest.swift
//  OnlineStoreMVTests
//
//  Created by Pedro Rojas on 07/03/24.
//

import XCTest
import Testing

@testable import OnlineStoreMV

extension Tag {
    @Tag static let adding: Self
    @Tag static let substracting: Self
    @Tag static let removing: Self
    @Tag static let quantity: Self
    @Tag static let product: Self
    @Tag static let price: Self
}

let products = [
    Product(
        id: 1,
        title: "test1",
        price: 123.12,
        description: "",
        category: "",
        imageURL: URL(string: "www.apple.com")!
    ),
    Product(
        id: 2,
        title: "test2",
        price: 77.56,
        description: "",
        category: "",
        imageURL: URL(string: "www.apple.com")!
    ),
    Product(
        id: 3,
        title: "test2",
        price: 91.0,
        description: "",
        category: "",
        imageURL: URL(string: "www.apple.com")!
    )
]
let cartItems = [
    CartItem(
        product: products[0],
        quantity: 3
    ),
    CartItem(
        product: products[1],
        quantity: 1
    ),
    CartItem(
        product: products[2],
        quantity: 2
    ),
]

struct CartStoreTest {
    
    @Test("Get total amount to pay as string", .tags(.price))
    func totalAmountString() throws {
        let cartStore = CartStore(
            cartItems: cartItems,
            apiClient: .testSuccess,
            logger: .inMemory
        )
        
        #expect(cartStore.totalPriceString == "$628.92")
    }
    
    @Suite("Substracting Quantity on Cart Items",.tags(.substracting, .quantity))
    struct SubstractingTest {

        @Test
        func quantityFromItemInCart() {
            let cartStore = CartStore(
                cartItems: cartItems,
                apiClient: .testSuccess,
                logger: .inMemory
            )
            
            cartStore.removeFromCart(product: products[0])
            cartStore.removeFromCart(product: products[2])
            let quantity = cartStore.cartItems.reduce(0) {
                $0 + $1.quantity
            }

            #expect(quantity == 4)
        }
        
        @Test
        func quantityFromItemInCartUntilMakeItZero() {
            let cartStore = CartStore(
                cartItems: cartItems,
                apiClient: .testSuccess,
                logger: .inMemory
            )
            
            cartStore.removeFromCart(product: products[0])
            cartStore.removeFromCart(product: products[1])
            cartStore.removeFromCart(product: products[2])
            cartStore.removeFromCart(product: products[2])
            
            let quantity = cartStore.cartItems.reduce(0) {
                $0 + $1.quantity
            }
            
            #expect(quantity == 2)
        }
    }
    
    @Suite("Removing Items from Cart", .tags(.removing))
    struct RemovingTest {
        
        @Test(.tags(.product, .quantity), arguments: [
            (products[0],3),
            (products[1],5),
            (products[2],4),
        ])
        func oneProductFromCart(product: Product, expectedQuantity: Int) {
            let cartStore = CartStore(
                cartItems: cartItems,
                apiClient: .testSuccess,
                logger: .inMemory
            )
            
            cartStore.removeAllFromCart(product: product)
            let quantity = cartStore.cartItems.reduce(0) {
                $0 + $1.quantity
            }
            
            #expect(cartStore.cartItems.count == 2)
            #expect(quantity == expectedQuantity)
        }
        
        @Test(.tags(.product))
        func allItemsFromCart() {
            let cartStore = CartStore(
                cartItems: cartItems,
                apiClient: .testSuccess,
                logger: .inMemory
            )
            
            cartStore.removeAllItems()
            
            #expect(cartStore.cartItems.isEmpty)
        }
    }
    
    @Suite(
        "Test quantity after some operations",
        .tags(.quantity)
    )
    struct QuantityTest {
        @Test(.tags(.product, .quantity))
        func productInCart() {
            let cartItems = [
                CartItem(
                    product: products[0],
                    quantity: 4
                )
            ]
            let cartStore = CartStore(
                cartItems: cartItems,
                apiClient: .testSuccess,
                logger: .inMemory
            )
            
            let quantity = cartStore.quantity(for: products[0])
            #expect(quantity == 4)
        }
        
        @Test(.tags(.product, .quantity))
        func nonExistingProductInCart() {
            let unknownProduct = Product(
                id: 1000,
                title: "test1",
                price: 123.12,
                description: "",
                category: "",
                imageURL: URL(string: "www.apple.com")!
            )
            let cartItems = [
                CartItem(
                    product: products[0],
                    quantity: 4
                )
            ]
            let cartStore = CartStore(
                cartItems: cartItems,
                apiClient: .testSuccess,
                logger: .inMemory
            )

            let quantity = cartStore.quantity(for: unknownProduct)
            
            #expect(quantity == 0)
        }
    }
    
    @Suite("Adding Items To Cart", .tags(.adding))
    struct AddingToCartTest {
        @Test(.tags(.quantity))
        func addQuantityFromExistingItem() {
            let cartStore = CartStore(
                cartItems: cartItems,
                apiClient: .testSuccess,
                logger: .inMemory
            )
            
            cartStore.addToCart(product: products[0])
            cartStore.addToCart(product: products[1])
            cartStore.addToCart(product: products[2])
            let quantity = cartStore.cartItems.reduce(0) {
                $0 + $1.quantity
            }
            
            #expect(quantity == 9)
        }
        
        @Test
        func addQuantityFromNewItem() {
            let cartItems = [
                CartItem(
                    product: products[0],
                    quantity: 3
                )
            ]
            let cartStore = CartStore(
                cartItems: cartItems,
                apiClient: .testSuccess,
                logger: .inMemory
            )
                        
            cartStore.addToCart(product: products[0])
            cartStore.addToCart(product: products[1])
            
            #expect(cartStore.cartItems.count == 2)
        }
    }
}
