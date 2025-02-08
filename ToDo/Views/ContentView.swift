import SwiftUI
import SwiftData

struct ContentView: View {
    
    @State var todo: String = ""
    @State var endDate: Date = Date()
    @State var todoDetails: String = ""
    @State var importance: Int = 0
    @State private var alertShowing = false
    let options = ["!", "!!", "!!!"]
    @State private var deleteIndex : IndexSet?
    @State private var searchText = ""
    @Environment(\.modelContext) private var modelContext
    @State private var sortOrder: [SortDescriptor<Item>] = [SortDescriptor(\Item.createdAt)]
    @Query(sort: [SortDescriptor(\Item.createdAt)]) private var items: [Item]
    
    var sortedItems: [Item] {
        if !searchText.isEmpty {
            return items.filter{$0.todo.contains(searchText)}
        } else {
            return items.sorted(using: sortOrder)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.blue)
                        
                        TextField("검색어", text: $searchText)
                            .textFieldStyle(.plain)
                        
                        
                        /// 정렬 메뉴
                        Menu {
                            Button("생성일 순") {
                                sortOrder = [SortDescriptor(\Item.createdAt)]
                            }
                            Button("마감일 순") {
                                sortOrder = [
                                    SortDescriptor(\Item.endDate),
                                    SortDescriptor(\Item.importance, order: .reverse)
                                ]
                            }
                            Button("중요도 순") {
                                sortOrder = [
                                    SortDescriptor(\Item.importance, order: .reverse),
                                    SortDescriptor(\Item.endDate)
                                ]
                            }
                        } label: {
                            Label("정렬", systemImage: "line.3.horizontal.decrease")
                                .labelStyle(.iconOnly)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .foregroundStyle(.blue)
                                .clipShape(Circle())
                        }
                    }
                    ForEach(sortedItems) { item in
                        NavigationLink(destination:
                            TodoAddView(item: item)
                        ) {
                            HStack {
                                Image(systemName: item.isToggled ?
                                      "checkmark.square.fill" : "square")
                                .onTapGesture {
                                    withAnimation {
                                        item.isToggled.toggle()
                                    }
                                }
                                Text(item.todo)
                                Spacer()
                                Text(dateFormatString(date: item.endDate))
                                    .foregroundStyle(.gray)
                                    .frame(width: 146, alignment: .trailing)
                                Text(options[item.importance])
                                    .foregroundStyle(importanceColor(for: item.importance))
                                    .frame(width: 15, alignment: .leading)
                            }
                            .foregroundStyle(item.isToggled ? .gray : .black)
                            .strikethrough(item.isToggled, color: .gray)
                        }
                    }
                    
                    .onDelete { indexSet in
                        deleteIndex = indexSet
                        alertShowing = true
                    }
                    
                } // end of List
                .alert("삭제하시겠습니까?", isPresented: $alertShowing) {
                    Button("취소", role: .cancel) {}
                    Button("삭제", role: .destructive) {
                        if let index = deleteIndex {
                            deleteItems(offsets: index)
                        }
                    }
                }
            } // end of VStack
        } // end of NavigationStack
        .toolbar {
                   ToolbarItem(placement: .navigationBarTrailing) {
                       NavigationLink(destination: TodoAddView(item: Item(todo: "", endDate: Date(), todoId: UUID(), todoDetails: "", importance: 0, createdAt: Date()))) {
                           Image(systemName: "square.and.pencil")
                       }
                   }
               }
        .navigationTitle("할 일 목록")
    } // end of body view
    
    private func addItem() {
        withAnimation {
            let newItem = Item(todo: todo, endDate: endDate, todoId: UUID(), todoDetails: todoDetails, importance: importance)
            modelContext.insert(newItem)
        }
    } // end of addItem
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(sortedItems[index])
            }
        }
    } // end of deleteItems
    
    private func dateFormatString(date: Date?) -> String {
        guard let date = date else { return "날짜 없음"}
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. M. d. HH:mm"
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
    
} // end of ContentView

#Preview {
    NavigationStack {
        ContentView()
    }
    .modelContainer(PreviewContainer.shared.container)
}
