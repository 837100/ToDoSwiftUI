import SwiftUI
import SwiftData


struct ContentView: View {
    
    @State var todo: String = ""
    @State var endDate: Date = Date()
    @State var todoDetails: String = ""
    @State var importance: Int = 0

    
    let options = ["!", "!!", "!!!"]
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
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
                                .foregroundStyle(.white)
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
                            .foregroundStyle(.white)
                            .padding()
                            .frame(width: 80, height: 40)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.5), radius : 5, x : 0, y : 5)
                    })
                    
                    Menu {
                        /// 기본
                        Button("생성일 순") {
                            // 필터 1 적용
                        }
                        
                        /// 마감 시간이 촉박할 수록 위에 배치
                        Button("마감일 순") {
                            // 필터 2 적용
                        }
                        
                        /// 중요도 먼저
                        Button("중요도 순") {
                            // 필터 초기화
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(width: 80, height: 40)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.5), radius : 5, x : 0, y : 5)
                            .contextMenu {
                                   Button("옵션 1") {
                                       // 동작
                                   }
                                   Button("옵션 2") {
                                       // 동작
                                   }
                               }
                    }
                } // end of HStack
                List {
                    ForEach(items) { item in
                        NavigationLink {
                            DetailView(item: item)
                        } label: {
                            HStack {
                                Toggle("", isOn: Binding(
                                    get: {item.isToggled},
                                    set: { newValue in
                                        withAnimation {
                                            item.isToggled = newValue
                                        }
                                    }
                                ))
                                .labelsHidden()
                                Text(item.todo)
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
                modelContext.delete(items[index])
            }
        }
    } // end of deleteItems
    
    private func dateFormatString(date: Date?) -> String {
        guard let date = date else { return "날짜 없음"}
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm 까지"
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
