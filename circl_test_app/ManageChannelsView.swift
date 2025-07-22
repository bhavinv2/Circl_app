import SwiftUI
import Foundation

struct ManageChannelsView: View {
    let circleId: Int
    @Binding var channels: [Channel]
    
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("user_id") private var userId: Int = 0
    
    @State private var localChannels: [Channel] = []
    @State private var newChannelName: String = ""
    @State private var showingAddChannel = false
    @State private var isLoading = false
    @State private var errorMessage: String = ""
    @State private var showingError = false
    @State private var isEditMode = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Content
                VStack(spacing: 20) {
                    // Add Channel Section
                    addChannelSection
                    
                    // Channels List
                    channelsListSection
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(hex: "004aad").opacity(0.02)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
        .onAppear {
            localChannels = channels.sorted(by: { $0.position < $1.position })
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .overlay(
            Group {
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "004aad")))
                }
            }
        )
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
                
                Spacer()
                
                Text("Manage Channels")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Save") {
                    saveChanges()
                }
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .semibold))
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .background(Color(hex: "004aad"))
        .safeAreaInset(edge: .top) {
            Color(hex: "004aad")
                .frame(height: 0)
        }
    }
    
    // MARK: - Add Channel Section
    private var addChannelSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add New Channel")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "number")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "004aad"))
                    
                    TextField("Enter channel name", text: $newChannelName)
                        .font(.system(size: 16))
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "004aad").opacity(0.2), lineWidth: 1)
                )
                
                Button(action: addChannel) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "004aad"), Color(hex: "0066dd")]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 4, x: 0, y: 2)
                        )
                }
                .disabled(newChannelName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(newChannelName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "004aad").opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "004aad").opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Channels List Section
    private var channelsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
                         HStack {
                Text("Current Channels")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditMode.toggle()
                    }
                }) {
                    Text(isEditMode ? "Done" : "Reorder")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "004aad"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color(hex: "004aad").opacity(0.1))
                        )
                }
                
                Text("\(localChannels.count) channels")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "004aad"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(hex: "004aad").opacity(0.1))
                    )
            }
            
            if localChannels.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "number")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "004aad").opacity(0.4))
                    
                    Text("No channels yet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("Add your first channel above")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [8, 4]))
                        .foregroundColor(Color(hex: "004aad").opacity(0.2))
                )
            } else {
                List {
                    ForEach(localChannels) { channel in
                        ChannelManagementRow(
                            channel: channel,
                            onDelete: { deleteChannel(channel) },
                            onMove: { from, to in moveChannel(from: from, to: to) },
                            showDeleteButton: !isEditMode
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    }
                    .onMove(perform: isEditMode ? moveChannel : nil)
                    .onDelete(perform: isEditMode ? { indexSet in
                        for index in indexSet {
                            deleteChannel(localChannels[index])
                        }
                    } : nil)
                }
                .listStyle(PlainListStyle())
                .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
            }
        }
    }
    
    // MARK: - Channel Management Functions
    private func addChannel() {
        let trimmedName = newChannelName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        // Add # prefix if not present
        let channelName = trimmedName.hasPrefix("#") ? trimmedName : "#\(trimmedName)"
        
        // Check for duplicates
        if localChannels.contains(where: { $0.name.lowercased() == channelName.lowercased() }) {
            errorMessage = "A channel with this name already exists"
            showingError = true
            return
        }
        
        isLoading = true
        
        createChannelOnServer(channelName: channelName) { success, newChannel in
            DispatchQueue.main.async {
                isLoading = false
                if success, let newChannel = newChannel {
                    localChannels.append(newChannel)
                    localChannels.sort(by: { $0.position < $1.position })
                    newChannelName = ""
                } else {
                    errorMessage = "Failed to create channel. Please try again."
                    showingError = true
                }
            }
        }
    }
    
    private func deleteChannel(_ channel: Channel) {
        isLoading = true
        
        deleteChannelOnServer(channelId: channel.id) { success in
            DispatchQueue.main.async {
                isLoading = false
                if success {
                    localChannels.removeAll { $0.id == channel.id }
                } else {
                    errorMessage = "Failed to delete channel. Please try again."
                    showingError = true
                }
            }
        }
    }
    
    private func moveChannel(from source: IndexSet, to destination: Int) {
        localChannels.move(fromOffsets: source, toOffset: destination)
        updateChannelPositions()
        updateChannelOrderOnServer()
    }
    
    private func moveChannel(from source: Int, to destination: Int) {
        let movedChannel = localChannels.remove(at: source)
        localChannels.insert(movedChannel, at: destination)
        updateChannelPositions()
        updateChannelOrderOnServer()
    }
    
    private func updateChannelPositions() {
        for (index, _) in localChannels.enumerated() {
            localChannels[index].position = index + 1
        }
    }
    
    private func saveChanges() {
        // Update the binding with local changes
        channels = localChannels
        presentationMode.wrappedValue.dismiss()
    }
    
    // MARK: - Backend API Functions
    private func createChannelOnServer(channelName: String, completion: @escaping (Bool, Channel?) -> Void) {
        guard let url = URL(string: "\(baseURL)circles/create_channel/") else {
            completion(false, nil)
            return
        }
        
        let payload: [String: Any] = [
            "circle_id": circleId,
            "name": channelName,
            "position": localChannels.count + 1
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Create channel error:", error?.localizedDescription ?? "unknown")
                completion(false, nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, 
               httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                // Try to decode the response to get the new channel ID
                // Try to decode the full channel response first
                if let newChannel = try? JSONDecoder().decode(Channel.self, from: data) {
                    completion(true, newChannel)
                } else if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let channelId = json["channel_id"] as? Int ?? json["id"] as? Int {
                    let position = json["position"] as? Int ?? localChannels.count + 1
                    let newChannel = Channel(id: channelId, name: channelName, circleId: circleId, position: position)
                    completion(true, newChannel)
                } else {
                    // Fallback: create channel with temporary ID
                    let newChannel = Channel(id: Int.random(in: 10000...99999), name: channelName, circleId: circleId, position: localChannels.count + 1)
                    completion(true, newChannel)
                }
            } else {
                completion(false, nil)
            }
        }.resume()
    }
    
    private func deleteChannelOnServer(channelId: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)circles/delete_channel/") else {
            completion(false)
            return
        }
        
        let payload: [String: Any] = [
            "channel_id": channelId,
            "user_id": userId
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("❌ Delete channel error:", error?.localizedDescription ?? "unknown")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }
    
    private func updateChannelOrderOnServer() {
        guard let url = URL(string: "\(baseURL)circles/channels/update_positions/") else { return }
        
        let positions = localChannels.enumerated().map { (index, channel) in
            ["id": channel.id, "position": index + 1] // Start from 1, not 0
        }
        
        let payload: [String: Any] = [
            "circle_id": circleId,
            "user_id": userId,
            "positions": positions
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Update channel order error:", error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 {
                print("✅ Channel order updated successfully")
            }
        }.resume()
    }
}

// MARK: - Channel Management Row
struct ChannelManagementRow: View {
    let channel: Channel
    let onDelete: () -> Void
    let onMove: (Int, Int) -> Void
    let showDeleteButton: Bool
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Channel icon
            Image(systemName: "number")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "004aad"))
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(Color(hex: "004aad").opacity(0.1))
                )
            
            // Channel name
            Text(channel.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Delete button (only shown when not in edit mode)
            if showDeleteButton {
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.red.opacity(0.1))
                        )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "004aad").opacity(0.08), lineWidth: 1)
        )
        .alert("Delete Channel", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete the '\(channel.name)' channel? This action cannot be undone.")
        }
    }
}

// MARK: - Preview
struct ManageChannelsView_Previews: PreviewProvider {
    static var previews: some View {
        ManageChannelsView(
            circleId: 1,
            channels: .constant([
                Channel(id: 1, name: "#general", circleId: 1, position: 1),
                Channel(id: 2, name: "#announcements", circleId: 1, position: 2),
                Channel(id: 3, name: "#random", circleId: 1, position: 3)
            ])
        )
    }
} 