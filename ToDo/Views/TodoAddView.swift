//
//  TodoAddView.swift
//  ToDo
//
//  Created by SG on 2/8/25.
//

import SwiftUI
import SwiftData

struct TodoAddView: View {
    @State var todo: String = ""
    @State var endDate: Date = Date()
    @State var todoDetails: String = ""
    @State var importance: Int = 0
    let options = ["!", "!!", "!!!"]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var sortOrder: [SortDescriptor<Item>] = [SortDescriptor(\Item.createdAt)]
    @Query(sort: [SortDescriptor(\Item.createdAt)]) private var items: [Item]
    
    var sortedItems: [Item] {
        items.sorted(using: sortOrder)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Input Card
                VStack(spacing: 16) {
                    // Todo Input
                    HStack {
                        Image(systemName: "pencil")
                            .foregroundStyle(.blue)
                        TextField("할 일", text: $todo)
                            .textFieldStyle(.plain)
                        Button(action: { todo = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.gray.opacity(0.5))
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Details Input
                    HStack {
                        Image(systemName: "text.alignleft")
                            .foregroundStyle(.blue)
                        TextField("상세 설명", text: $todoDetails)
                            .textFieldStyle(.plain)
                        Button(action: { todoDetails = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.gray.opacity(0.5))
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Date and Importance
                    VStack(spacing: 12) {
                        // Custom Date Picker
                        DateSelectionView(selectedDate: $endDate)
                        
                        // Importance Buttons
                        HStack {
                            Image(systemName: "flag")
                                .foregroundStyle(.blue)
                            Spacer()
                            ForEach(0..<options.count, id: \.self) { index in
                                Button(action: { importance = index }) {
                                    Text(options[index])
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(importance == index ? importanceColor(for: index) : Color.gray.opacity(0.1))
                                        .foregroundStyle(importance == index ? .white : importanceColor(for: index))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.1), radius: 10)
                .padding(.horizontal)
                
                
                Button(action: {
                    addItem()
//                    todo = ""
//                    todoDetails = ""
                    dismiss()
                }) {
                    Label("추가", systemImage: "plus")
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(25)
                }
                
                
                
                
                Spacer()
            }
            .navigationTitle("할 일 추가")
            .animation(.spring(response: 0.3), value: items)
        }
    }
    
    // Helper functions remain the same
    private func addItem() {
        withAnimation {
            let newItem = Item(todo: todo, endDate: endDate, todoId: UUID(), todoDetails: todoDetails, importance: importance)
            modelContext.insert(newItem)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(sortedItems[index])
            }
        }
    }
    
    private func dateFormatString(date: Date?) -> String {
        guard let date = date else { return "날짜 없음" }
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private func importanceColor(for index: Int) -> Color {
        switch index {
        case 0: return .green
        case 1: return .orange
        case 2: return .red
        default: return .black
        }
    }
}

#Preview {
    TodoAddView()
        .modelContainer(for: Item.self, inMemory: true)
}
