//
//  codingchallengeApp.swift
//  Shared
//
//  Created by Asfiya Tabassum on 14/12/21.
//

import SwiftUI

class Orders: ObservableObject, Hashable, Equatable, Identifiable
{
    
    static func == (lhs: Orders, rhs: Orders) -> Bool
    {
        lhs.orderList == rhs.orderList
    }
    
    func hash(into hasher:inout Hasher)
    {
        hasher.combine(orderList)
    }
    @Published var orderList : [CoffeeCart]=[]
    
    func AddOrder(order: CoffeeCart)
    {
        orderList.append(order)
    }
    
    func Save(){
        Orders.save(oList: orderList) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func Reset(){
        orderList = []
        Orders.save(oList: []) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                       in: .userDomainMask,
                                       appropriateFor: nil,
                                       create: false)
            .appendingPathComponent("scrums.data")
    }
    
    static func load(completion: @escaping (Result<[CoffeeCart], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                let dailyScrums = try JSONDecoder().decode([CoffeeCart].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(dailyScrums))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func save(oList: [CoffeeCart], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(oList)
                let outfile = try fileURL()
                try data.write(to: outfile)
                DispatchQueue.main.async {
                    completion(.success(oList.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

class CoffeeCart: ObservableObject, Hashable, Identifiable, Codable
{
    init(){}
    enum CoffeeCartCodingKeys: CodingKey
    {
        case cartList,dateTime
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CoffeeCartCodingKeys.self)
        
        try container.encode(cartList, forKey: .cartList)
        try container.encode(dateTime, forKey: .dateTime)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CoffeeCartCodingKeys.self)
        
        cartList = try container.decode([CoffeeCartItem].self, forKey: .cartList)
        dateTime = try container.decode(String.self, forKey: .dateTime)
    }
    var id : String { dateTime }
    static func == (lhs: CoffeeCart, rhs: CoffeeCart) -> Bool
    {
        lhs.cartList == rhs.cartList
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(cartList)
    }
    @Published var cartList : [CoffeeCartItem]=[]
    @Published var dateTime : String = ""
    func AddItemToCart(item: CoffeeDataItem,type:ItemType)
    {
        cartList.append(CoffeeCartItem(name:item.name,img:item.img,itemType: type))
    }
    
    func TotalPrice() -> String
    {
        var total:Float = 0.0;
        for item in cartList
        {
            total += item.itemType.price;
        }
        return String(format:"$%.2f",total);
    }
}

enum SizeType : String,Codable
{
    case Small,Medium,Large
}

struct ItemType : Hashable, Identifiable,Codable{
    var id: String
    
    let price : Float
    let size : SizeType
    
    func GetString() -> String
    {
        return  size.rawValue+" - " + String(format: "$%.2f", price)
    }
}

struct CoffeeCartItem: Identifiable, Hashable,Equatable,Codable {
    
    static func == (lhs: CoffeeCartItem, rhs: CoffeeCartItem) -> Bool
    {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(itemType)
    }
    let name: String
    let img: String
    var itemType: ItemType
    var id: String { name}
    
    func PrintFull() -> String{
        return name + " - " + itemType.size.rawValue + " : " + String(format: "$%.2f", itemType.price)
    }
    
    func PrintOnlySize() -> String{
        return name + " - " + itemType.size.rawValue
    }
    
}

struct CoffeeDataItem: Identifiable, Hashable,Equatable,Codable {
    
    static func == (lhs: CoffeeDataItem, rhs: CoffeeDataItem) -> Bool
    {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(itemTypes)
    }
    let name: String
    let img: String
    var itemTypes: [ItemType] = []
    var id: String { name}
    
}



@main
struct CoffeeShopApp: App {
    @State var tag:Int? = nil;
    var orders : Orders = Orders()
    
    var body: some Scene {
        WindowGroup{
            NavigationView{
                ScrollView
                {
                    VStack{
                        
                        Text("Swift Intro")
                            .font(.system(size: 50))
                        
                        Text("Coffee Shop")
                            .font(.system(size: 24,weight: Font.Weight.light))
                        
                        Image("CoffeeImage").resizable().clipShape(Circle()).padding().frame(width: 380, height: 300)
                        
                        
                        NavigationLink(destination: PlaceOrderView(orders: orders),tag:1,selection: $tag) {
                            Text("Place Order").bold()
                                .frame(width: 280, height: 50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        NavigationLink(destination: PreviousOrdersView(orders: orders)) {
                            Text("View Previous Orders")
                        }.padding()
                        
                        
                        Button(action: { orders.Reset() })
                        {
                            Text("Reset Data")
                        }
                        
                    }.frame(maxWidth:.infinity,maxHeight: .infinity)
                    Spacer()
                }
            }
            .onAppear {
                Orders.load { result in
                    switch result {
                    case .failure(let error):
                        fatalError(error.localizedDescription)
                    case .success(let orderList):
                        orders.orderList = orderList
                    }
                }
            }
        }
        
    }
}

