//
//  ContentView.swift
//  iExpense
//
//  Created by Daniel Yankiver on 12/21/23.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
  var id = UUID()
  let name: String
  let type: String
  let amount: Double
}

@Observable
class Expenses {
  var items = [ExpenseItem]() {
    didSet {
      if let encoded = try? JSONEncoder().encode(items) {
        UserDefaults.standard.set(encoded, forKey: "Items")
      }
    }
  }

  init() {
    if let savedItems = UserDefaults.standard.data(forKey: "Items") {
      if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
        items = decodedItems
        return
      }
    }

    items = []
  }
}

struct ContentView: View {
  @State private var expenses = Expenses()

  @State private var showingAddExpense = false

  var body: some View {
    NavigationStack {
      List {
        ForEach(expenses.items) { item in
          HStack {
            VStack(alignment: .leading) {
              Text(item.name)
                .font(.headline)

              Text(item.type)
            }

            Spacer()

            let itemAmount = Text(item.amount, format: .currency(code: Locale.current.currency!.identifier))

            if (item.amount < 50) {
              itemAmount
                .foregroundColor(.green)
            } else if (item.amount < 100) {
              itemAmount
                .foregroundColor(.yellow)
            } else {
              itemAmount
                .foregroundColor(.red)
            }
          }
        }
        .onDelete(perform: removeItems)
      }
      .navigationTitle("iExpense")
      .toolbar {
        Button("Add Expense", systemImage: "plus") {
          showingAddExpense = true
        }
      }
      .sheet(isPresented: $showingAddExpense) {
        AddView(expenses: expenses)
      }
    }
  }

  func removeItems(at offsets: IndexSet) {
    expenses.items.remove(atOffsets: offsets)
  }
}

#Preview {
  ContentView()
}
