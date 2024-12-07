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
    @Tag static var price: Self
    @Tag static var product: Self
    @Tag static var quantity: Self
}

let products = [
    Product(
        id: 1,
        title: "test1",
        price: 123.12,
        description: "",
        category: "",
        imageURL: URL(string: "www.apple.com")!),
    Product(
        id: 2,
        title: "test2",
        price: 77.56,
        description: "",
        category: "",
        imageURL: URL(string: "www.apple.com")!),

    Product(
        id: 3,
        title: "test2",
        price: 91.0,
        description: "",
        category: "",
        imageURL: URL(string: "www.apple.com")!
    )]

let cartItems = [
    CartItem(
        product: Product(
            id: 1,
            title: "test1",
            price: 123.12,
            description: "",
            category: "",
            imageURL: URL(string: "www.apple.com")!),
        quantity: 3
    ),
    CartItem(
        product: Product(
            id: 2,
            title: "test2",
            price: 77.56,
            description: "",
            category: "",
            imageURL: URL(string: "www.apple.com")!),
        quantity: 1
    ),
    CartItem(
        product: Product(
            id: 3,
            title: "test2",
            price: 91.0,
            description: "",
            category: "",
            imageURL: URL(string: "www.apple.com")!
        ),
        quantity: 2
    ),
]

@Suite("Cart Store Suite")
struct CartStoreTest {

    @Test("Get total amount to pay as string", .tags(.price))
    func totalAmountString() {
        let cartStore = CartStore(
            cartItems: cartItems,
            apiClient: .testSuccess
        )

        let expected = "$628.92"
        let actual = cartStore.totalPriceString

        #expect(expected == actual, "Actual result is not the same as expected")
    }

    @Test("Get total amount to pay as string making it fail to understand withKnownIssue", .tags(.price))
    func totalAmountStringFailing() {
        let cartStore = CartStore(
            cartItems: cartItems,
            apiClient: .testSuccess
        )

        let expected = "$628.9"
        let actual = cartStore.totalPriceString
        withKnownIssue("Making it fail") {
            #expect(expected == actual, "Actual result is not the same as expected")
        }
    }

    @Suite("Subtracting quantity on cart items")
    struct SubtractingTest {
        @Test
        func testSubstractQuantityFromItemInCart() {
            let cartStore = CartStore(
                cartItems: cartItems,
                apiClient: .testSuccess
            )

            let expectedQuantity = 4

            cartStore.removeFromCart(product: products[0])
            cartStore.removeFromCart(product: products[2])
            let actualQuantity = cartStore.cartItems.reduce(0) {
                $0 + $1.quantity
            }

            #expect(expectedQuantity == actualQuantity)
        }

        @Test(.tags(.product), .timeLimit(.minutes(1)))
        func testSubstractQuantityFromItemInCartUntilMakeItZero() {
            let cartStore = CartStore(
                cartItems: cartItems,
                apiClient: .testSuccess
            )

            let expectedQuantity = 2

            cartStore.removeFromCart(product: products[0])
            cartStore.removeFromCart(product: products[1])
            cartStore.removeFromCart(product: products[2])
            cartStore.removeFromCart(product: products[2])

            let actualQuantity = cartStore.cartItems.reduce(0) {
                $0 + $1.quantity
            }

            #expect(expectedQuantity == actualQuantity)
        }
    }



    @Suite("Removal test", .tags(.product))
    struct RemovingTest {
        @Test(arguments: [(products[0], 4), (products[1], 5), (products[2], 6)])
        func removeProductFromCart(product: Product, expectedQuantity: Int) {
            let cartItems = [
                CartItem(
                    product: product,
                    quantity: expectedQuantity
                )
            ]
            let cartStore = CartStore(
                cartItems: cartItems,
                apiClient: .testSuccess
            )

            let expected: [CartItem] = []

            cartStore.removeAllFromCart(product: product)

            let actual = cartStore.cartItems

            #expect(expected == actual)
        }

        @Test
        func removeAllItemsFromCart() {
            let cartStore = CartStore(
                cartItems: cartItems,
                apiClient: .testSuccess
            )

            let expected: [CartItem] = []

            cartStore.removeAllItems()

            let actual = cartStore.cartItems

            #expect(expected == actual)
        }
    }

    @Suite("Quantity tests")
    struct QuantityTest {
        @Test(.tags(.quantity))
        func getQuantityFromAProductInCart() {
            let cartItems = [
                CartItem(
                    product: products[0],
                    quantity: 4
                )
            ]
            let cartStore = CartStore(
                cartItems: cartItems,
                apiClient: .testSuccess
            )

            let expected = 4
            let actual = cartStore.quantity(for: products[0])

            #expect(expected == actual)
        }

        @Test(.tags(.quantity))
        func getQuantityFromAProductThatDoesNotExistInCart() {
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
                apiClient: .testSuccess
            )

            let expected = 0
            let actual = cartStore.quantity(for: unknownProduct)

            #expect(expected == actual)
        }
    }

    @Suite("Add Quantity tests", .tags(.quantity))
    struct AddQuantityTest {
        @Test
        func addQuantityFromExistingItemInCart() {
            let cartStore = CartStore(
                cartItems: cartItems,
                apiClient: .testSuccess
            )

            let expectedQuantity = 9

            cartStore.addToCart(product: products[0])
            cartStore.addToCart(product: products[2])
            cartStore.addToCart(product: products[2])
            let actualQuantity = cartStore.cartItems.reduce(0) {
                $0 + $1.quantity
            }

            #expect(expectedQuantity == actualQuantity)
        }

        @Test(.tags(.quantity))
        func addQuantityFromNewItemInCart() {
            let cartItems = [
                CartItem(
                    product: products[0],
                    quantity: 3
                )
            ]
            let cartStore = CartStore(
                cartItems: cartItems,
                apiClient: .testSuccess
            )

            let expectedCartItemsCount = 2

            cartStore.addToCart(product: products[0])
            cartStore.addToCart(product: products[1])

            let actualCartItemsCount = cartStore.cartItems.count

            #expect(expectedCartItemsCount == actualCartItemsCount)
        }
    }

}

final class CartStoreTest_deprecated: XCTestCase {

    //    func testTotalAmountString() throws {
    //
    //        let cartItems = [
    //            CartItem(
    //                product: Product(
    //                    id: 1,
    //                    title: "test1",
    //                    price: 123.12,
    //                    description: "",
    //                    category: "",
    //                    imageURL: URL(string: "www.apple.com")!
    //                ),
    //                quantity: 3
    //            ),
    //            CartItem(
    //                product: Product(
    //                    id: 2,
    //                    title: "test2",
    //                    price: 77.56,
    //                    description: "",
    //                    category: "",
    //                    imageURL: URL(string: "www.apple.com")!
    //                ),
    //                quantity: 1
    //            ),
    //            CartItem(
    //                product: Product(
    //                    id: 3,
    //                    title: "test2",
    //                    price: 91.0,
    //                    description: "",
    //                    category: "",
    //                    imageURL: URL(string: "www.apple.com")!
    //                ),
    //                quantity: 2
    //            ),
    //        ]
    //        let cartStore = CartStore(
    //            cartItems: cartItems,
    //            apiClient: .testSuccess
    //        )
    //
    //        let expected = "$628.92"
    //        let actual = cartStore.totalPriceString
    //
    //        XCTAssertEqual(actual, expected, "Actual result is not the same as expected")
    //    }
    //
    //    func testSubstractQuantityFromItemInCart() {
    //        let product1 = Product(
    //            id: 1,
    //            title: "test1",
    //            price: 123.12,
    //            description: "",
    //            category: "",
    //            imageURL: URL(string: "www.apple.com")!
    //        )
    //        let product2 = Product(
    //            id: 2,
    //            title: "test2",
    //            price: 77.56,
    //            description: "",
    //            category: "",
    //            imageURL: URL(string: "www.apple.com")!
    //        )
    //        let product3 = Product(
    //            id: 3,
    //            title: "test2",
    //            price: 91.0,
    //            description: "",
    //            category: "",
    //            imageURL: URL(string: "www.apple.com")!
    //        )
    //        let cartItems = [
    //            CartItem(
    //                product: product1,
    //                quantity: 3
    //            ),
    //            CartItem(
    //                product: product2,
    //                quantity: 1
    //            ),
    //            CartItem(
    //                product: product3,
    //                quantity: 2
    //            ),
    //        ]
    //        let cartStore = CartStore(
    //            cartItems: cartItems,
    //            apiClient: .testSuccess
    //        )
    //
    //        let expectedQuantity = 4
    //
    //        cartStore.removeFromCart(product: product1)
    //        cartStore.removeFromCart(product: product3)
    //        let actualQuantity = cartStore.cartItems.reduce(0) {
    //            $0 + $1.quantity
    //        }
    //
    //        XCTAssertEqual(expectedQuantity, actualQuantity)
    //    }
    //
    //    func testSubstractQuantityFromItemInCartUntilMakeItZero() {
    //        let product1 = Product(
    //            id: 1,
    //            title: "test1",
    //            price: 123.12,
    //            description: "",
    //            category: "",
    //            imageURL: URL(string: "www.apple.com")!
    //        )
    //        let product2 = Product(
    //            id: 2,
    //            title: "test2",
    //            price: 77.56,
    //            description: "",
    //            category: "",
    //            imageURL: URL(string: "www.apple.com")!
    //        )
    //        let product3 = Product(
    //            id: 3,
    //            title: "test2",
    //            price: 91.0,
    //            description: "",
    //            category: "",
    //            imageURL: URL(string: "www.apple.com")!
    //        )
    //        let cartItems = [
    //            CartItem(
    //                product: product1,
    //                quantity: 3
    //            ),
    //            CartItem(
    //                product: product2,
    //                quantity: 1
    //            ),
    //            CartItem(
    //                product: product3,
    //                quantity: 2
    //            ),
    //        ]
    //        let cartStore = CartStore(
    //            cartItems: cartItems,
    //            apiClient: .testSuccess
    //        )
    //
    //        let expectedQuantity = 2
    //
    //        cartStore.removeFromCart(product: product1)
    //        cartStore.removeFromCart(product: product2)
    //        cartStore.removeFromCart(product: product3)
    //        cartStore.removeFromCart(product: product3)
    //
    //        let actualQuantity = cartStore.cartItems.reduce(0) {
    //            $0 + $1.quantity
    //        }
    //
    //        XCTAssertEqual(expectedQuantity, actualQuantity)
    //    }
    //
    //    func testRemoveProductFromCart() {
    //        let product1 = Product(
    //            id: 1,
    //            title: "test1",
    //            price: 123.12,
    //            description: "",
    //            category: "",
    //            imageURL: URL(string: "www.apple.com")!
    //        )
    //        let cartItems = [
    //            CartItem(
    //                product: product1,
    //                quantity: 4
    //            )
    //        ]
    //        let cartStore = CartStore(
    //            cartItems: cartItems,
    //            apiClient: .testSuccess
    //        )
    //
    //        let expected: [CartItem] = []
    //
    //        cartStore.removeAllFromCart(product: product1)
    //
    //        let actual = cartStore.cartItems
    //
    //        XCTAssertEqual(expected, actual)
    //    }
    //
    //    func testRemoveAllItemsFromCart() {
    //        let product1 = Product(
    //            id: 1,
    //            title: "test1",
    //            price: 123.12,
    //            description: "",
    //            category: "",
    //            imageURL: URL(string: "www.apple.com")!
    //        )
    //        let product2 = Product(
    //            id: 2,
    //            title: "test2",
    //            price: 77.56,
    //            description: "",
    //            category: "",
    //            imageURL: URL(string: "www.apple.com")!
    //        )
    //        let product3 = Product(
    //            id: 3,
    //            title: "test2",
    //            price: 91.0,
    //            description: "",
    //            category: "",
    //            imageURL: URL(string: "www.apple.com")!
    //        )
    //        let cartItems = [
    //            CartItem(
    //                product: product1,
    //                quantity: 3
    //            ),
    //            CartItem(
    //                product: product2,
    //                quantity: 1
    //            ),
    //            CartItem(
    //                product: product3,
    //                quantity: 2
    //            ),
    //        ]
    //        let cartStore = CartStore(
    //            cartItems: cartItems,
    //            apiClient: .testSuccess
    //        )
    //
    //        let expected: [CartItem] = []
    //
    //        cartStore.removeAllItems()
    //
    //        let actual = cartStore.cartItems
    //
    //        XCTAssertEqual(expected, actual)
    //    }
    //
    //    func testGetQuantityFromAProductInCart() {
    //        let product1 = Product(
    //            id: 1,
    //            title: "test1",
    //            price: 123.12,
    //            description: "",
    //            category: "",
    //            imageURL: URL(string: "www.apple.com")!
    //        )
    //        let cartItems = [
    //            CartItem(
    //                product: product1,
    //                quantity: 4
    //            )
    //        ]
    //        let cartStore = CartStore(
    //            cartItems: cartItems,
    //            apiClient: .testSuccess
    //        )
    //
    //        let expected = 4
    //        let actual = cartStore.quantity(for: product1)
    //
    //        XCTAssertEqual(expected, actual)
    //    }
    //
    //    func testGetQuantityFromAProductThatDoesNotExistInCart() {
    //        let product1 = Product(
    //            id: 1,
    //            title: "test1",
    //            price: 123.12,
    //            description: "",
    //            category: "",
    //            imageURL: URL(string: "www.apple.com")!
    //        )
    //        let unknownProduct = Product(
    //            id: 1000,
    //            title: "test1",
    //            price: 123.12,
    //            description: "",
    //            category: "",
    //            imageURL: URL(string: "www.apple.com")!
    //        )
    //        let cartItems = [
    //            CartItem(
    //                product: product1,
    //                quantity: 4
    //            )
    //        ]
    //        let cartStore = CartStore(
    //            cartItems: cartItems,
    //            apiClient: .testSuccess
    //        )
    //
    //        let expected = 0
    //        let actual = cartStore.quantity(for: unknownProduct)
    //
    //        XCTAssertEqual(expected, actual)
    //    }
    //
    //    func testAddQuantityFromExistingItemInCart() {
    //        let product1 = Product(
    //            id: 1,
    //            title: "test1",
    //            price: 123.12,
    //            description: "",
    //            category: "",
    //            imageURL: URL(string: "www.apple.com")!
    //        )
    //        let product2 = Product(
    //            id: 2,
    //            title: "test2",
    //            price: 77.56,
    //            description: "",
    //            category: "",
    //            imageURL: URL(string: "www.apple.com")!
    //        )
    //        let product3 = Product(
    //            id: 3,
    //            title: "test2",
    //            price: 91.0,
    //            description: "",
    //            category: "",
    //            imageURL: URL(string: "www.apple.com")!
    //        )
    //        let cartItems = [
    //            CartItem(
    //                product: product1,
    //                quantity: 3
    //            ),
    //            CartItem(
    //                product: product2,
    //                quantity: 1
    //            ),
    //            CartItem(
    //                product: product3,
    //                quantity: 2
    //            ),
    //        ]
    //        let cartStore = CartStore(
    //            cartItems: cartItems,
    //            apiClient: .testSuccess
    //        )
    //
    //        let expectedQuantity = 9
    //
    //        cartStore.addToCart(product: product1)
    //        cartStore.addToCart(product: product3)
    //        cartStore.addToCart(product: product3)
    //        let actualQuantity = cartStore.cartItems.reduce(0) {
    //            $0 + $1.quantity
    //        }
    //
    //        XCTAssertEqual(expectedQuantity, actualQuantity)
    //    }
    //
    //    func testAddQuantityFromNewItemInCart() {
    //        let product1 = Product(
    //            id: 1,
    //            title: "test1",
    //            price: 123.12,
    //            description: "",
    //            category: "",
    //            imageURL: URL(string: "www.apple.com")!
    //        )
    //        let product2 = Product(
    //            id: 2,
    //            title: "test2",
    //            price: 77.56,
    //            description: "",
    //            category: "",
    //            imageURL: URL(string: "www.apple.com")!
    //        )
    //        let cartItems = [
    //            CartItem(
    //                product: product1,
    //                quantity: 3
    //            )
    //        ]
    //        let cartStore = CartStore(
    //            cartItems: cartItems,
    //            apiClient: .testSuccess
    //        )
    //
    //        let expectedCartItemsCount = 2
    //
    //        cartStore.addToCart(product: product1)
    //        cartStore.addToCart(product: product2)
    //
    //        let actualCartItemsCount = cartStore.cartItems.count
    //
    //        XCTAssertEqual(expectedCartItemsCount, actualCartItemsCount)
    //    }
}
