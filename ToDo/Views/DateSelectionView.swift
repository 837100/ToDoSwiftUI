//
//  DateSelectionView.swift
//  ToDo
//
//  Created by SG on 2/8/25.
//

import SwiftUI

struct DateSelectionView: View {
    @Binding var selectedDate: Date
    @State private var showDatePicker = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 HH:mm 까지"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    var body: some View {
        HStack {
            Image(systemName: "calendar")
                .foregroundStyle(.blue)
            
            Text(dateFormatter.string(from: selectedDate))
                .foregroundStyle(.primary)
            
            Spacer()
            
            Button(action: { showDatePicker.toggle() }) {
                Image(systemName: "chvron.right")
                    .foregroundStyle(.gray)
                    .rotationEffect(.degrees(showDatePicker ? 90 : 0))
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .onTapGesture {
            showDatePicker.toggle()
        }
        
        if showDatePicker {
            VStack {
                DatePicker("마감일", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.graphical)
                    .padding()
                    .background()
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5)
                    .padding(.horizontal)
                
                Button("선택 완료") {
                    showDatePicker = false
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(.blue)
                .cornerRadius(25)
                .padding(.bottom)
            }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

#Preview {
    @State var previewDate = Date()
    return DateSelectionView(selectedDate: $previewDate)
}
