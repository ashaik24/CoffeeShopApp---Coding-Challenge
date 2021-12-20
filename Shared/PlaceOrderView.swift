//
//  PlaceOrders.swift
//  codingchallenge
//
//  Created by Asfiya Tabassum on 14/12/21.
//

import SwiftUI

func CurrentTime() -> String{
    let currentDateTime = Date()
    
    let formatter = DateFormatter()
    formatter.timeStyle = .medium
    formatter.dateStyle = .long
    
    return formatter.string(from: currentDateTime)
}



var cart : CoffeeCart = CoffeeCart()




struct PlaceOrderView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var orders : Orders
    
    var body: some View
    {
            VStack(alignment: .center
                   , spacing: 10)
            {
                Text("Order For").padding()
                Text(CurrentTime())
                Spacer()
                
                if(cart.cartList.isEmpty)
                {
                    Text("No Items added to cart.")
                    List()
                    {
                        
                    }
                }
                else
                {
                    List
                    {
                        Section(header: Text("Cart"))
                        {
                            ForEach(cart.cartList, id: \.self)
                            {
                              item in
                              Text(item.PrintFull())
                            }
                            .onDelete(perform: delete)
                            .onMove(perform: move)
                        }
                    }
                    .navigationBarItems(trailing: EditButton())
                }
                
                Spacer()
                NavigationLink(destination: MenuView(cart: cart))
                {
                    Text("Add Items")
                }
                Spacer()
                if(!cart.cartList.isEmpty)
                {
                    Text("Total - " + cart.TotalPrice())
                }
                
                Spacer()
                
                Button(action:
                {
                    if(!cart.cartList.isEmpty)
                    {
                        cart.dateTime = CurrentTime()
                        self.orders.orderList.append(cart)
                        self.orders.Save()
                        cart = CoffeeCart()
                    }
                    dismiss()
                    
                })
                {
                    Text("Submit Order")
                        .bold()
                        .frame(width: 280, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }.frame(maxWidth:.infinity,maxHeight: .infinity)
    }
}

func delete(indexSet: IndexSet)
{
    cart.cartList.remove(atOffsets: indexSet)
}

func move(indices: IndexSet, newOffset: Int)
{
    cart.cartList.move(fromOffsets: indices, toOffset: newOffset)
}


struct PlaceOrderView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceOrderView(orders: Orders()).navigationBarBackButtonHidden(false)
    }
}
