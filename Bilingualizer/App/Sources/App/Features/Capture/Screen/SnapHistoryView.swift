//
//  Snap.swift
//  App
//
//  Created by Ondra on 02.08.2025.
//


import SwiftUI

struct TestSnap: Identifiable {
    let id = UUID()
    let text: String
    let type: SnapType
    let date: Date
}

enum SnapType {
    case photo, text
}

struct SnapHistoryView: View {
    let groupedSnaps: [Date: [TestSnap]] // grouped by day
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(groupedSnaps.keys.sorted(by: >), id: \.self) { date in
                    Section(header: Text(formattedDate(date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)) {
                        
                        ForEach(groupedSnaps[date] ?? []) { snap in
                            SnapRowView(snap: snap)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct SnapRowView: View {
    let snap: TestSnap
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(snap.text)
                .font(.body)
                .foregroundColor(.primary)
            
            HStack {
                Image(systemName: snap.type == .photo ? "camera" : "text.cursor")
                    .font(.caption)
                Text(timeOnly(snap.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }
    
    func timeOnly(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    let sampleSnaps: [TestSnap] = [
        TestSnap(text: "The quick brown fox jumps over the lazy dog", type: .photo, date: Date()),
        TestSnap(text: "This is a sample typed entry", type: .text, date: Date().addingTimeInterval(-3600)),
        TestSnap(text: "Another snap earlier today", type: .photo, date: Date().addingTimeInterval(-7200))
    ]
    
    let grouped = Dictionary(grouping: sampleSnaps) { snap in
        Calendar.current.startOfDay(for: snap.date)
    }
    
    SnapHistoryView(groupedSnaps: grouped)
}
