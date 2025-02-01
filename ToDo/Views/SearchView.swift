import SwiftUI
import SwiftData

struct SearchView: View {
    let endDate: Date
    let todo: String
    let importance: Int
    let todoDetails: String
    
    @Query private var foundItems: [Item]
    @Environment(\.modelContext) private var modelContext
    
    init(todo: String, endDate: Date, importance: Int,  todoDetails: String ) {
        
        self.todo = todo
        self.endDate = endDate
        self.importance = importance
        self.todoDetails = todoDetails
        
        _foundItems = Query(filter: #Predicate<Item> { item in
            if todo != "" {
                return item.endDate <= endDate && item.importance == importance && item.todo.localizedStandardContains(todo)
            } else if todoDetails != "" {
                return item.endDate <= endDate && item.importance == importance && item.todoDetails.localizedStandardContains(todoDetails)
            } else {
                item.endDate <= endDate && item.importance == importance
            }
        })
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if foundItems.isEmpty {
                    Text("조건에 해당하는 할 일을 찾을 수 없습니다")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    
                    List{
                        ForEach(foundItems) { item in
                            
                            NavigationLink {
                                DetailView(item: item)
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("할 일: \(item.todo)")
                                        .font(.headline)
                                    Text("할 일 상세: \(item.todoDetails)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("마감일: \(formatDate(item.endDate))")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                    Text("중요도: \(importToStrig(item.importance))")
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("할일 찾기")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    func importToStrig(_ importance: Int) -> String {
        switch importance {
        case 1: "중간"
        case 2: "높음"
        default: "낮음"
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
