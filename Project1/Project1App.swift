//
//  Project1App.swift
//  Project1
//
//  Created by MacbookShop on 10/19/26.
//

import SwiftUI
import CoreData

@main
struct Project1App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
