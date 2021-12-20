//
//  PreviousOrders.swift
//  codingchallenge
//
//  Created by Asfiya Tabassum on 14/12/21.
//

import SwiftUI

struct PreviousOrdersView: View {
    @ObservedObject var orders : Orders
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(minimum: 100))
            ],spacing: 12, content :{
                if(orders.orderList.isEmpty)
                {
                    Text("No orders")
                }
                else
                {
                    ForEach(orders.orderList,id : \.self){ order in
                        
                        VStack(alignment: .center, spacing: 4)
                        {
                            Spacer()
                            Text(order.dateTime).font(.system(size: 14,weight: Font.Weight.semibold))
                                .foregroundColor(.black)
                            ForEach(order.cartList,id : \.self)
                            {
                                item in
                                VStack{
                                    Text(item.PrintFull())
                                }
                            }
                            
                            Text(order.TotalPrice()).font(.system(size: 20,weight: Font.Weight.bold))
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.35))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        
                    }
                }
            }
                      
            )}.padding()
    }
}

struct PreviousOrdersView_Previews: PreviewProvider {
    static var previews: some View {
        PreviousOrdersView(orders: Orders())
    }
}
