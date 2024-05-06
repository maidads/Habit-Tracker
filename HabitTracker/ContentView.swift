import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink(destination: HabitDetailView(item: item)) {
                        HabitRow(item: item)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: addItem) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add a new habit")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.name = "New Habit"
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct HabitRow: View {
    @ObservedObject var item: Item
    @State private var daysSelected: [Bool] = [false, false, false, false, false, false, false]
    let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let rainbowColors: [Color] = [
        Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple, Color.pink
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.name ?? "New Habit")
            HStack {
                ForEach(0..<7) { index in
                    VStack {
                        Circle()
                            .fill(daysSelected[index] ? rainbowColors[index] : Color.clear)
                            .overlay(
                                Circle().stroke(rainbowColors[index], lineWidth: 2)
                            )
                            .frame(width: 20, height: 20)
                            .onTapGesture {
                                daysSelected[index].toggle()
                            }
                        Text(weekdays[index])
                            .font(.caption)
                    }
                }
            }
        }
    }
}


struct HabitDetailView: View {
    @ObservedObject var item: Item

    var body: some View {
        Text("Detail view for \(item.name ?? "New Habit")")
    }
}
