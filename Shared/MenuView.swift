//
//  AddItems.swift
//  codingchallenge
//
//  Created by Asfiya Tabassum on 14/12/21.
//

import SwiftUI


private let coffees :[CoffeeDataItem] = [
    CoffeeDataItem(name:"Coffee",img: "Coffee",itemTypes: [
        ItemType(id: "CoffeeLarge",price: 12.00, size: SizeType.Large),
        ItemType(id: "CoffeeMedium",price: 10.00, size: SizeType.Medium),
        ItemType(id: "CoffeeSmall",price: 8.00, size: SizeType.Small)
    ]),
    CoffeeDataItem(name:"Water",img: "Water",itemTypes: [
        ItemType(id: "WaterLarge",price: 6.00, size: SizeType.Large),
        ItemType(id: "WaterMedium",price: 5.00, size: SizeType.Medium),
        ItemType(id: "WaterSmall",price: 4.00, size: SizeType.Small)
    ]),
    CoffeeDataItem(name:"Latte",img: "Latte",itemTypes: [
        ItemType(id: "LatteLarge",price: 14.00, size: SizeType.Large),
        ItemType(id: "LatteMedium",price: 12.00, size: SizeType.Medium),
        ItemType(id: "LatteSmall",price: 9.00, size: SizeType.Small)
    ]),
    CoffeeDataItem(name:"Smoothie",img: "Smoothie",itemTypes: [
        ItemType(id: "SmoothieLarge",price: 18.00, size: SizeType.Large),
        ItemType(id: "SmoothieMedium",price: 16.00, size: SizeType.Medium),
        ItemType(id: "SmoothieSmall",price: 12.00, size: SizeType.Small)
    ]),
    CoffeeDataItem(name:"Tea",img: "Tea",itemTypes: [
        ItemType(id: "TeaLarge",price: 13.00, size: SizeType.Large),
        ItemType(id: "TeaMedium",price: 11.00, size: SizeType.Medium),
        ItemType(id: "TeaSmall",price: 9.99, size: SizeType.Small)
    ])
]

struct MenuView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var cart : CoffeeCart
    @State private var isShowingSheet = false;
    @State var selectedCoffee: CoffeeDataItem = coffees[0]
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(minimum: 200, maximum: 200)),
                GridItem(.flexible(minimum: 200, maximum: 200))
            ],spacing: 12, content :{
                ForEach(coffees, id: \.self){ coffee in
                    
                    Button(action: {
                        selectedCoffee = coffee
                        isShowingSheet.toggle()
                    })
                    {
                        VStack(alignment: .center, spacing: 4)
                        {
                            Image(coffee.img).resizable().scaledToFit().clipShape(Circle()).padding(1).frame(maxHeight:120)
                            Spacer()
                            Text(coffee.name).font(.system(size: 14,weight: Font.Weight.semibold))
                                .foregroundColor(.black)
                        }
                    }
                    .sheet(isPresented : $isShowingSheet)
                    {
                        VStack(alignment: .center, spacing: 12){
                            ForEach(selectedCoffee.itemTypes)
                            {
                                type in
                                Button(action:{
                                    dismiss()
                                    self.cart.AddItemToCart(item: selectedCoffee,type:type)
                                    isShowingSheet.toggle()
                                })
                                {
                                    Text(type.GetString())
                                        .bold()
                                        .frame(width: 280, height: 50)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                Spacer()
                            }
                        }
                        .frame(maxHeight:200)
                        .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.35))
                }
            }
            )}.padding()
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(cart: CoffeeCart())
    }
}
