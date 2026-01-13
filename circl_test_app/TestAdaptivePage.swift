import SwiftUI

// MARK: - Test Page to Demonstrate Adaptive System

struct TestAdaptivePage: View {
    @State private var items = Array(1...20).map { index in "Item \(index)" }
    
    var body: some View {
        AdaptivePage(title: "Test Page") {
            ScrollView {
                AdaptiveGrid {
                    ForEach(items, id: \.self) { item in
                        TestItemView(title: item)
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct TestItemView: View {
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("Sample")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
            }
            
            Text("This is a sample item description that demonstrates how content adapts between iPhone and iPad layouts automatically.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Button("Action 1") {
                    // Test action
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.blue)
                
                Spacer()
                
                Button("Action 2") {
                    // Test action
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.blue)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}