//
//  ContentView.swift
//  DemoApp
//
//  Created by Zohaib Ahmed on 8/7/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var loanStore = LoanStore()
    
    @State private var filterEnabled = false
    @State private var maximuimLoanAmount = 10000.0
    
    var body: some View {
        NavigationStack {
            VStack{
                
                if filterEnabled {
                    LoanFilterView(amount: self.$maximuimLoanAmount)
                        .transition(.opacity)
                }
                
                List(loanStore.loans) { loan in
                    LoanCellView(loan: loan)
                        .padding(.vertical, 5)
                }.listStyle(.plain)
            }
            
            .navigationTitle("Kiva Loan")
            .toolbar{
                ToolbarItem(placement:.topBarTrailing){
                    Button {
                        withAnimation(.linear){
                            self.filterEnabled.toggle()
                            self.loanStore.filterLoans(maxAmount: Int(self.maximuimLoanAmount))
                        }
                    } label: {
                        Text("Filter")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
        .task {
            self.loanStore.fetchLatestLoans()
        }
    }
}

#Preview {
    ContentView()
}

#Preview {
    LoanFilterView(amount: .constant(10.0))
}

struct LoanFilterView: View{
    
    @Binding var amount: Double
    
    var minAmount = 0.0
    var maxAmount = 10000.0
    
    var body: some View{
        VStack(alignment: .leading){
            Text("Show loan amount below $\(Int(amount))")
                .font(.system(.headline, design: .rounded))
            
            HStack{
                Slider(value: $amount, in: minAmount...maxAmount, step: 100)
                    .tint(.purple)
            }
            HStack{
                Text("\(Int(minAmount))")
                    .font(.system(.footnote, design: .rounded))
                Spacer()
                Text("\(Int(maxAmount))")
                    .font(.system(.footnote, design: .rounded))
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}

struct LoanCellView: View {
    var loan: Loan
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(loan.name)
                    .font(.system(.headline, design: .rounded))
                    .bold()
                Text(loan.country)
                    .font(.system(.subheadline, design: .rounded))
                Text(loan.use)
                    .font(.system(.body, design: .rounded))
            }
            Spacer()
            VStack {
                Text("$\(loan.amount)")
                    .font(.system(.title, design: .rounded))
                    .bold()
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }
}

