import SwiftUI

struct PollCard: View {
    let poll: Poll
    var onVote: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Poll Title
            Text(poll.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            // Poll Options
            VStack(spacing: 8) {
                ForEach(poll.options, id: \.self) { option in
                    Button(action: {
                        onVote(option)
                    }) {
                        HStack {
                            Text(option)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "004aad"))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "004aad").opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "004aad").opacity(0.1), lineWidth: 1)
                        )
                    }
                }
            }
            
            // Poll Metadata
            HStack {
                Text(formatDate(poll.createdAt))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func formatDate(_ dateString: String) -> String {
        // TODO: Implement proper date formatting
        return dateString
    }
}

struct CreatePollView: View {
    @Binding var isPresented: Bool
    @State private var title: String = ""
    @State private var newOption: String = ""
    @State private var options: [String] = []
    let onCreate: (String, [String]) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Poll Title")) {
                    TextField("Enter poll title", text: $title)
                }
                
                Section(header: Text("Options")) {
                    ForEach(options, id: \.self) { option in
                        Text(option)
                    }
                    .onDelete { indexSet in
                        options.remove(atOffsets: indexSet)
                    }
                    
                    HStack {
                        TextField("Add option", text: $newOption)
                        Button("Add") {
                            if !newOption.isEmpty {
                                options.append(newOption)
                                newOption = ""
                            }
                        }
                    }
                }
            }
            .navigationTitle("Create Poll")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Create") {
                    if !title.isEmpty && !options.isEmpty {
                        onCreate(title, options)
                        isPresented = false
                    }
                }
                .disabled(title.isEmpty || options.isEmpty)
            )
        }
    }
}
