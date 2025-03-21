import SwiftUI
import SwiftData

struct DetailView: View {
    @Bindable var item: Item
    
    @State var todo: String
    @State var todoDetails: String
    @State var endDate: Date
    @State var importance: Int = 0
    let options = ["!", "!!", "!!!"]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    init(item: Item) {
        self.item = item
        _todo = State(initialValue: item.todo)
        _todoDetails = State(initialValue: item.todoDetails)
        _endDate = State(initialValue: item.endDate)
        _importance = State(initialValue: item.importance)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                TextField("할 일",
                          text: $todo
                )
                .border(.secondary)
                .padding(.leading, 10)
                
                TextField("상세설명",
                          text: $todoDetails,
                          axis: .vertical
                )
                .lineLimit(1...20)
                .border(.secondary)
                .padding(.leading, 10)
                
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
                
                Button(action: {
                    updateItem()
                }, label: {
                    Text("저장하기")
                })
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.vertical, 4)
                .frame(width: 100, height: 40)
                .background(Color.blue)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.5), radius : 5, x : 0, y : 5)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // 화면 상단 정렬
            .padding() // 패딩 추가
            
        }
        .navigationTitle("상세 보기")
    }
    
    func importToStrig(_ importance: Int) -> String {
        switch importance {
        case 1: "중간"
        case 2: "높음"
        default: "낮음"
        }
    }
    
    private func updateItem() {
        withAnimation {
            item.todo = todo
            item.todoDetails = todoDetails
            item.endDate = endDate
            item.importance = importance
            do {
                try modelContext.save()
                dismiss()
            } catch {
                print("Error saving updated item: \(error)")
            }
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
    DetailView(item: Item(todo: "할일", endDate: Date(), todoId: UUID(), todoDetails: "디테일", importance: 1, createdAt: Date()))
}
