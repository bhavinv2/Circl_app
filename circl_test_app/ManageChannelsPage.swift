import SwiftUI

struct ChannelItem: Identifiable, Decodable, Hashable {
    let id: Int
    let name: String
    let category: String?
    let circle_id: Int

    enum CodingKeys: String, CodingKey {
        case id, name, category
        case circle_id = "circleId"
    }
}


struct ManageChannelsPage: View {
    let circleId: Int
    @AppStorage("user_id") private var userId: Int = 0

    @State private var channels: [ChannelItem] = []
    @State private var showAddPopup = false
    @State private var newChannelName = ""
    @State private var deleteMode = false
    @State private var selectedForDeletion: Set<Int> = []

    var body: some View {
        VStack(spacing: 16) {
            // Buttons
            HStack {
                Button("Add Channel") {
                    newChannelName = "#"
                    showAddPopup = true
                }

                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button(deleteMode ? "Confirm delete" : "Delete Channel") {
                    if deleteMode {
                        deleteSelectedChannels()
                        selectedForDeletion.removeAll()
                    }
                    deleteMode.toggle()
                }
                .padding()
                .background(deleteMode ? Color.red : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            // List of Channels
            List {
                ForEach(channels) { channel in
                    HStack {
                        Text(channel.name)
                        Spacer()
                        if deleteMode {
                            Button(action: {
                                toggleSelection(channel.id)
                            }) {
                                Image(systemName: selectedForDeletion.contains(channel.id) ? "minus.circle.fill" : "minus.circle")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear(perform: fetchChannels)
        .sheet(isPresented: $showAddPopup) {
            VStack(spacing: 20) {
                Text("Add New Channel")
                    .font(.headline)
                TextField("Channel name", text: $newChannelName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: newChannelName) { newValue in
                        if !newValue.hasPrefix("#") {
                            newChannelName = "#" + newValue.replacingOccurrences(of: "#", with: "")
                        }
                    }

                Button("Create") {
                    createChannel()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                Spacer()
            }
            .padding()
        }
    }

    private func toggleSelection(_ id: Int) {
        if selectedForDeletion.contains(id) {
            selectedForDeletion.remove(id)
        } else {
            selectedForDeletion.insert(id)
        }
    }

    private func fetchChannels() {
        print("🔍 Fetching channels for circleId: \(circleId)")
        guard let url = URL(string: "https://circlapp.online/api/circles/get_channels/\(circleId)/") else {
            print("❌ Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode([ChannelItem].self, from: data) {
                    DispatchQueue.main.async {
                        print("✅ Channels loaded: \(decoded.count)")
                        channels = decoded
                    }
                } else {
                    print("❌ Truly failed to decode (invalid structure)")
                

                }
            } else {
                print("❌ No data received")
            }
        }.resume()
    }


    private func createChannel() {
        guard let url = URL(string: "https://circlapp.online/api/circles/add_channel/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "user_id": userId,
            "circle_id": circleId,
            "name": newChannelName
        ]


        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        print("📤 Channel payload:", body)
        if let jsonData = try? JSONSerialization.data(withJSONObject: body),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📦 JSON Body:", jsonString)
        }


        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status code:", httpResponse.statusCode)
            }

            if let data = data, let responseText = String(data: data, encoding: .utf8) {
                print("🛑 Server error response:", responseText)
            }

            DispatchQueue.main.async {
                fetchChannels()
                showAddPopup = false
                newChannelName = ""
            }
        }.resume()

    }

    private func deleteSelectedChannels() {
        guard let url = URL(string: "https://circlapp.online/api/circles/delete_channels/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "user_id": userId,
            "circle_id": circleId,
            "channel_ids": Array(selectedForDeletion)
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, _, _ in
            fetchChannels()
        }.resume()
    }
}
