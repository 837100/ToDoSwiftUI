import SwiftUI
import SwiftData


struct ContentView: View {
    
    @State var todo: String = ""
    @State var endDate: Date = Date()
    @State var todoDetails: String = ""
    @State var importance: Int = 0
    let options = ["!", "!!", "!!!"]
    @Environment(\.modelContext) private var modelContext
    @State private var sortOrder: [SortDescriptor<Item>] = [SortDescriptor(\Item.createdAt)]
    @Query(sort: [SortDescriptor(\Item.createdAt)]) private var items: [Item]
    
    
    
    var sortedItems: [Item] {
        items.sorted(using: sortOrder)
    }
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Spacer()
                HStack {
                    TextField("할 일", text: $todo)
                        .border(.secondary)
                        .padding(.leading, 10)
                    Button(action: {
                        todo = ""
                    }, label: {
                        Image(systemName: "eraser")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(width: 30, height: 30)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.5), radius : 5, x : 0, y : 5)
                    })
                }
                
                HStack {
                    TextField("상세 설명", text: $todoDetails)
                        .border(.secondary)
                        .padding(.leading, 10)
                    Button(action: {
                        todoDetails = ""
                    }, label: {
                        Image(systemName: "eraser")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(width: 30, height: 30)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.5), radius : 5, x : 0, y : 5)
                    })
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .padding(.leading)
                    DatePicker("기한", selection: $endDate)
                        .labelsHidden() // 텍스트 레이블 숨김
                    
                    Image(systemName: "flag")
                    ForEach(0..<options.count, id: \.self) { index in
                        Button(action: {
                            importance = index
                        }) {
                            Text(options[index])
                                .font(.headline)
                                .frame(width: 40, height: 30)
                                .background(importance == index ? importanceColor(for: index) : Color.white)
                                .foregroundStyle(importance == index ? .white : .black) // 선택된 항목만 텍스트 색상 변경
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 5)
                        }
                    }
                }
                
                HStack {
                    NavigationLink  {
                        SearchView(
                            todo: todo,
                            endDate: endDate,
                            importance: importance,
                            todoDetails: todoDetails
                        )} label: {
                            Image(systemName: "magnifyingglass")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .font(.headline)
                                .padding()
                                .frame(width: 80, height: 40)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.5), radius : 5, x : 0, y : 5)
                        }
                    Button(action: {
                        addItem()
                        todo = ""
                        todoDetails = ""
                    }, label: {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .font(.headline)
                            .padding()
                            .frame(width: 80, height: 40)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.5), radius : 5, x : 0, y : 5)
                    })
                    Menu {
                        /// 기본
                        Button("생성일 순") {
                            sortOrder = [SortDescriptor(\Item.createdAt)]
                        }
                        
                        /// 마감 시간이 촉박할 수록 위에 배치
                        Button("마감일 순") {
                            sortOrder = [
                                SortDescriptor(\Item.importance, order: .reverse),
                                SortDescriptor(\Item.endDate)
                            ]
                        }
                        
                        /// 중요도 먼저
                        Button("중요도 순") {
                            sortOrder = [
                                SortDescriptor(\Item.endDate),
                                SortDescriptor(\Item.importance, order: .reverse)
                            ]
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .font(.headline)
                            .padding()
                            .frame(width: 80, height: 40)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.5), radius : 5, x : 0, y : 5)
                    }
                } // end of HStack
                
                
                /// 할일이 나타나는 List
                List {
                    ForEach(sortedItems) { item in
                        NavigationLink {
                            DetailView(item: item)
                        } label: {
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
                                Text(options[item.importance])
                                    .foregroundStyle(importanceColor(for: item.importance))
                                Spacer()
                                Text(dateFormatString(date: item.endDate))
                                //                                Text("\(item.todoId)")
                            }
                            .foregroundStyle(item.isToggled ? .gray : .black)
                            .strikethrough(item.isToggled, color: .gray)
                        }
                    }
                    .onDelete(perform: deleteItems)
                } // end of List
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.gray), alignment: .top
                )
            } // end of VStack
        } // end of NavigationStack
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
        formatter.dateFormat = "~ MM/dd HH:mm"
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
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
