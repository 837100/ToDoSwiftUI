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
    @State var importance: Int
    let options = ["!", "!!", "!!!"]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let item: Item
    let isEditing : Bool
    
    init (item: Item) {
        self.item = item
        self.isEditing = !item.todo.isEmpty
        
        _todo = State(initialValue: item.todo)
        _todoDetails = State(initialValue: item.todoDetails)
        _endDate = State(initialValue: item.endDate)
        _importance = State(initialValue: item.importance)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
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
                    
                    VStack(spacing: 12) {
                        DateSelectionView(selectedDate: $endDate)
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
                    if isEditing {
                        updateItem()
                    } else {
                        addItem()
                    }
                    dismiss()
                }) {
                    Label(isEditing ? "수정" : "추가", systemImage: "plus")
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
        }
    }
    
    private func updateItem() {
        withAnimation {
            item.todo = todo
            item.todoDetails = todoDetails
            item.endDate = endDate
            item.importance = importance
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(todo: todo,
                               endDate: endDate,
                               todoId: UUID(),
                               todoDetails: todoDetails,
                               importance: importance)
            modelContext.insert(newItem)
        }
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
    TodoAddView(item: Item(todo: "할일",
                           endDate: Date(),
                           todoId: UUID(),
                           todoDetails: "상세",
                           importance: 1,
                           createdAt: Date()))
        .modelContainer(PreviewContainer.shared.container)
}
