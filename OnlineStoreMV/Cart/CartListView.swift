//
//  CartListView.swift
//  OnlineStoreMV
//
//  Created by Pedro Rojas on 06/03/24.
//

import SwiftUI

struct CartListView: View {
    @Environment(CartStore.self) var cartStore
    @Environment(\.dismiss) var dismiss
    
    @State private var showConfirmationAlert = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    
    var isPayButtonDisable: Bool {
        cartStore.totalAmount() == 0
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                Group {
                    if cartStore.cartItems.isEmpty {
                        Text("Oops, your cart is empty! \n")
                            .font(.custom("AmericanTypewriter", size: 25))
                    } else {
                        List(cartStore.cartItems) { item in
                            CartCell()
                        }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    Button {
                        showConfirmationAlert = true
                    } label: {
                        HStack(alignment: .center) {
                            Spacer()
                            Text("Pay \(cartStore.totalAmount())")
                                .font(.custom("AmericanTypewriter", size: 30))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        
                    }
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(
                            isPayButtonDisable
                            ? .gray
                            : .blue
                        )
                        .cornerRadius(10)
                        .padding()
                        .disabled(isPayButtonDisable)
                }
                .navigationTitle("Cart")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Close")
                        }
                    }
                }
                .alert(
                    "Confirm your purchase",
                    isPresented: $showConfirmationAlert,
                    actions: {
                        Button(role: .cancel) {
                            showConfirmationAlert = false
                        } label: {
                            Text("Cancel")
                        }
                        Button("Yes") {
                            //cartStore.sendOrder()
                        }
                    },
                    message: { Text("Hola compa!") }
                )
                .alert(
                    "Thank you!",
                    isPresented: $showSuccessAlert,
                    actions: {
                        Button("Done") {
                            showSuccessAlert = false
                        }
                    },
                    message: { Text("Your order is in process.") }
                )
                .alert(
                    "Oops!",
                    isPresented: $showErrorAlert,
                    actions: {
                        Button("Done") {
                            showErrorAlert = false
                        }
                    },
                    message: { Text("Unable to send order, try again later.") }
                )
            }
        }
    }
}

#Preview {
    CartListView()
}
