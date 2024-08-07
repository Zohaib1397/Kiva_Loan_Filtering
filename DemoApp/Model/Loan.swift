//
//  Load.swift
//  DemoApp
//
//  Created by Zohaib Ahmed on 8/7/24.
//

import Foundation

struct Loan: Identifiable{
    var id = UUID()
    var name: String
    var country: String
    var use: String
    var amount: Int
    
    init(name: String, country: String, use: String, amount: Int) {
        self.name = name
        self.country = country
        self.use = use
        self.amount = amount
    }
}

extension Loan: Codable{
    enum CodingKeys: String, CodingKey{
        case name
        case country = "location"
        case use
        case amount = "loan_amount"
    }
    
    enum LocationKeys: String, CodingKey{
        case country
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        let location = try container.nestedContainer(keyedBy: LocationKeys.self, forKey: .country)
        country = try location.decode(String.self, forKey: .country)
        use = try container.decode(String.self, forKey: .use)
        amount = try container.decode(Int.self, forKey: .amount)
    }
}

class LoanStore: Decodable, ObservableObject{
    @Published var loans: [Loan] = []
    private var cachedLoans: [Loan] = []
    
    enum CodingKeys: CodingKey{
        case loans
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        loans = try values.decode([Loan].self, forKey: .loans)
    }
    
    init(){
        
    }
    
    private static var kivaLoanURL = "https://api.kivaws.org/v1/loans/newest.json"
    
    
    func fetchLatestLoans(){
        guard let loanUrl = URL(string: Self.kivaLoanURL) else {
            return
        }
        
        let request = URLRequest(url: loanUrl)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            
            if let error {
                print(error)
                return
            }
            
            if let data{
                DispatchQueue.main.async{
                    self.loans = self.parseJsonData(data: data)
                    self.cachedLoans = self.loans
                }
            }
        })
        
        task.resume()
    }
    func filterLoans(maxAmount: Int) {
        self.loans = self.cachedLoans.filter{ $0.amount < maxAmount}
    }
    
    func parseJsonData(data: Data) -> [Loan]{
        let decoder = JSONDecoder()
        
        do{
            let loanStore = try decoder.decode(LoanStore.self, from: data)
            self.loans = loanStore.loans
        } catch {
            print(error)
        }
        
        return loans
    }
}
