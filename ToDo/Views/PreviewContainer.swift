//
//  PreviewContainer.swift
//  ToDo
//
//  Created by SG on 2/8/25.
//

import Foundation
import SwiftData

@MainActor
class PreviewContainer {
    static let shared: PreviewContainer = PreviewContainer()
    
    let container: ModelContainer
    
    init() {
        let schema = Schema([
            Item.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            insertPreviewData()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    /// 더미 데이터 삽입
    func insertPreviewData() {
        let context = container.mainContext
        
        let todoList: [(String, String, Int)] = [
            ("Swift 공부", "SwiftUI와 Combine 학습", 0),
            ("운동하기", "헬스장에서 상체 운동", 1),
            ("책 읽기", "Clean Code 챕터 3 읽기", 2),
            ("프로젝트 작업", "iOS Todo 앱 기능 추가", 2),
            ("산책", "집 근처 공원 산책", 1)
        ]
        
        for (todo, todoDetails, importance) in todoList {
            let item = Item(
                todo: todo,
                endDate: Date().addingTimeInterval(Double.random(in: 3600...86400)), // 1시간~1일 후
                todoId: UUID(),
                todoDetails: todoDetails,
                importance: importance,
                createdAt: Date()
            )
            context.insert(item)
        }
        
        // 저장
        do {
            try context.save()
            print("더미 데이터 저장 완료 (Item 개수: \(try context.fetch(FetchDescriptor<Item>()).count))")
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
