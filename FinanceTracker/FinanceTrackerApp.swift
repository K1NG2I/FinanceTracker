//
//  FinanceTrackerApp.swift
//  FinanceTracker
//
//  Created by Yash Kulkarni on 04/02/26.
//

//import SwiftUI
//import SwiftData
//
//@main
//struct FinanceTrackerApp: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//        .modelContainer(sharedModelContainer)
//    }
//}
import SwiftUI
import SwiftData

@main
struct FinanceTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                TransactionsView()
                    .tabItem {
                        Label("Transactions", systemImage: "list.bullet.rectangle")
                    }

                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                FutureView()
                    .tabItem {
                        Label("Future", systemImage: "clock")
                    }

            }
            .preferredColorScheme(.dark)
        }
        .modelContainer(for: [TransactionItem.self, MonthlyDailyLimit.self, UpcomingPayment.self, ExpensePreset.self])


    }
}
