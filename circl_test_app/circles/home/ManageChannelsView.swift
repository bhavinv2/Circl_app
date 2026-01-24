/*
 BACKEND TODO: Implement the following API endpoint for category reordering:
 
 POST /api/circles/update_category_positions/
 
 Request Body:
 {
   "circle_id": <int>,
   "user_id": <int>,
   "positions": [
     {"id": <category_id>, "position": <new_position>},
     {"id": <category_id>, "position": <new_position>},
     ...
   ]
 }
 
 Expected Response:
 - 200 OK with JSON: {"success": true}
 - 404 if circle not found
 - 403 if user doesn't have permission
 - 400 if invalid data
 
 The endpoint should:
 1. Validate user has permission to modify the circle
 2. Update the position field for each category in the database
 3. Return success/error status
 */

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
    @State private var categories: [ChannelCategory] = []
    private var uncategorizedChannels: [Channel] {
        let categorizedChannelIDs = Set(categories.flatMap { $0.channels.map { $0.id } })
        return localChannels.filter { !categorizedChannelIDs.contains($0.id) }
    }
    @State private var newCategoryName: String = ""
    @State private var isCreatingCategory = false
    @State private var channelNameForCategory: [Int: String] = [:]
    @State private var showAddPopup = false
    @State private var selectedCategoryId: Int? = nil
    
    // MARK: - Drag and Drop State
    @State private var draggedCategory: ChannelCategory?
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var dropTargetIndex: Int? = nil




    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Content
                VStack(spacing: 20) {
                    // Add Channel Section
                
                    
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
            fetchCategories()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }

        // Custom channel name popup
        

        // Loading overlay
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
    private func createCategoryOnServer(name: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)circles/create_category/") else {

            completion(false)
            return
        }

        let payload: [String: Any] = [
            "circle_id": circleId,
            "name": name,
            "user_id": userId  // ✅ Required for authorization
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Category creation error:", error.localizedDescription)
                    completion(false)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    fetchCategories()
                    newCategoryName = ""
                    completion(true)
                } else {
                    print("❌ Server rejected category creation")
                    completion(false)
                }
            }
        }.resume()
    }
    // MARK: - Add Channel Section
    private func fetchCategories() {
        guard let url = URL(string: "\(baseURL)circles/get_categories/\(circleId)/?user_id=\(userId)") else { return }


        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Error fetching categories:", error?.localizedDescription ?? "unknown")
                return
            }
            do {
                let decoded = try JSONDecoder().decode([ChannelCategory].self, from: data)
                DispatchQueue.main.async {
                    self.categories = decoded
                }
            } catch {
                print("❌ JSON Decode Error:", error)
            }
        }.resume()
    }

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
    private func deleteCategoryFromServer(categoryId: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)circles/delete_category/") else {
            completion(false)
            return
        }

        let payload: [String: Any] = [
            "category_id": categoryId,
            "user_id": userId
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Delete category error:", error.localizedDescription)
                    completion(false)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("✅ Category deleted")
                    completion(true)
                } else {
                    print("❌ Failed with status: \(response.debugDescription)")
                    completion(false)
                }
            }
        }.resume()
    }

    private var channelsListSection: some View {
        VStack(alignment: .leading, spacing: 20) {

            // MARK: - Add Category Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Add New Category")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "004aad"))
                        
                        TextField("Enter category name", text: $newCategoryName)
                            .font(.system(size: 16))
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
                    )
                    .padding(.horizontal, 4) // prevents cutoff on sides
                    .frame(maxWidth: .infinity)

                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "004aad").opacity(0.2), lineWidth: 1)
                    )
                    
                    Button(action: {
                        isCreatingCategory = true
                        createCategoryOnServer(name: newCategoryName) { success in
                            isCreatingCategory = false
                            if !success {
                                errorMessage = "Failed to create category"
                                showingError = true
                            }
                        }
                    }) {
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
                    .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
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


            if categories.isEmpty && uncategorizedChannels.isEmpty {

                VStack(spacing: 12) {
                    Image(systemName: "square.stack.3d.down.right")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "004aad").opacity(0.4))
                    
                    Text("No categories yet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("Add a category to organize your channels")
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
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Reorganization Instructions
                        HStack(spacing: 8) {
                            Image(systemName: "line.horizontal.3")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "004aad"))
                            
                            Text("Hold and drag the ≡ handle to reorder categories")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "004aad").opacity(0.05))
                        )
                        
                        // Categories with drag and drop
                        ForEach(categories.sorted(by: { $0.position < $1.position })) { category in
                            categoryView(for: category)
                        }

                        // Uncategorized channels
                        let categorizedChannelIDs = Set(categories.flatMap { $0.channels.map { $0.id } })
                        let uncategorizedChannels = localChannels.filter { !categorizedChannelIDs.contains($0.id) }

                        if !uncategorizedChannels.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Uncategorized")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)

                                let sortedUncategorized = uncategorizedChannels.sorted(by: { $0.position < $1.position })

                                ForEach(sortedUncategorized) { channel in
                                    let toggleHandler: (Channel) -> Void = { ch in
                                        toggleModeratorOnly(ch)
                                    }

                                    ChannelManagementRow(
                                        channel: channel,
                                        onDelete: { deleteChannel(channel) },
                                        onMove: { _, _ in },
                                        showDeleteButton: !isEditMode,
                                        onToggleModeratorOnly: toggleHandler
                                    )
                                }


                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                }



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
    
    // MARK: - Category View with Drag and Drop
    @ViewBuilder
    private func categoryView(for category: ChannelCategory) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                // Drag handle
                VStack(spacing: 2) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 20, height: 2)
                        .cornerRadius(1)
                    Rectangle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 20, height: 2)
                        .cornerRadius(1)
                    Rectangle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 20, height: 2)
                        .cornerRadius(1)
                }
                .opacity(isDragging && draggedCategory?.id == category.id ? 0.3 : 0.8)
                .animation(.easeInOut(duration: 0.2), value: isDragging)
                
                Text(category.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                Menu {
                    Button(role: .destructive) {
                        deleteCategoryFromServer(categoryId: category.id ?? -1) { success in
                            if success {
                                fetchCategories()
                            } else {
                                errorMessage = "Failed to delete category"
                                showingError = true
                            }
                        }
                    } label: {
                        Label("Delete Category", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                }

                Spacer()

                if selectedCategoryId != category.id {
                    Text("Add Channel")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.trailing, 6)
                }

                Button(action: {
                    selectedCategoryId = (selectedCategoryId == category.id) ? nil : category.id
                }) {
                    Image(systemName: selectedCategoryId == category.id ? "xmark.circle.fill" : "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(selectedCategoryId == category.id ? .red : Color(hex: "004aad"))
                }
            }

            // ✅ INLINE CHANNEL CREATION BOX
            if selectedCategoryId == category.id {
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "number")
                            .foregroundColor(Color(hex: "004aad"))

                        TextField("Enter channel name", text: Binding(
                            get: { channelNameForCategory[category.id ?? -1] ?? "" },
                            set: { channelNameForCategory[category.id ?? -1] = $0 }
                        ))
                        .font(.system(size: 16))
                        .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "004aad").opacity(0.2), lineWidth: 1)
                    )

                    Button(action: {
                        let raw = channelNameForCategory[category.id ?? -1]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        guard !raw.isEmpty else { return }
                        let channelName = raw.hasPrefix("#") ? raw : "#\(raw)"

                        if localChannels.contains(where: { $0.name.lowercased() == channelName.lowercased() }) {
                            errorMessage = "A channel with this name already exists"
                            showingError = true
                            return
                        }

                        isLoading = true
                        createChannelOnServer(channelName: channelName, categoryId: category.id) { success, _ in
                            DispatchQueue.main.async {
                                isLoading = false
                                if success {
                                    channelNameForCategory[category.id ?? -1] = ""
                                    selectedCategoryId = nil
                                    fetchCategories()
                                } else {
                                    errorMessage = "Failed to add channel"
                                    showingError = true
                                }
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color(hex: "004aad")))
                    }
                }
                .padding(.vertical, 4)
            }

            ForEach(category.channels) { channel in
                ChannelManagementRow(
                    channel: channel,
                    onDelete: { deleteChannel(channel) },
                    onMove: { _, _ in },
                    showDeleteButton: !isEditMode,
                    onToggleModeratorOnly: { toggleModeratorOnly($0) }
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(isDragging && draggedCategory?.id == category.id ? 0.2 : 0.08),
                       radius: isDragging && draggedCategory?.id == category.id ? 12 : 6,
                       x: 0,
                       y: isDragging && draggedCategory?.id == category.id ? 8 : 2)
        )
        .scaleEffect(isDragging && draggedCategory?.id == category.id ? 1.05 : 1.0)
        .opacity(isDragging && draggedCategory?.id == category.id ? 0.9 : 1.0)
        .padding(.horizontal, 4)
        .offset(y: isDragging && draggedCategory?.id == category.id ? dragOffset : 0)
        .animation(.easeInOut(duration: 0.2), value: isDragging)
        .animation(.easeInOut(duration: 0.1), value: dragOffset)
        .zIndex(isDragging && draggedCategory?.id == category.id ? 1 : 0)
        .gesture(
            LongPressGesture(minimumDuration: 0.3)
                .onEnded { _ in
                    // Start dragging state
                    draggedCategory = category
                    isDragging = true
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
                .simultaneously(with:
                    DragGesture()
                        .onChanged { value in
                            // Only update offset if this category is being dragged
                            if isDragging && draggedCategory?.id == category.id {
                                dragOffset = value.translation.height
                                
                                // Calculate potential drop target for visual feedback
                                let sortedCategories = categories.sorted(by: { $0.position < $1.position })
                                if let draggedIndex = sortedCategories.firstIndex(where: { $0.id == category.id }) {
                                    let categoryHeight: CGFloat = 80
                                    let sensitivity: CGFloat = 0.5
                                    let dropOffset = Int(round(value.translation.height / (categoryHeight * sensitivity)))
                                    let newIndex = max(0, min(sortedCategories.count - 1, draggedIndex + dropOffset))
                                    dropTargetIndex = newIndex != draggedIndex ? newIndex : nil
                                }
                            }
                        }
                        .onEnded { value in
                            // Handle drop only if this was the dragged category
                            if isDragging && draggedCategory?.id == category.id {
                                handleCategoryDrop(draggedCategory: category, translation: value.translation.height)
                            }
                            
                            // Reset drag state
                            isDragging = false
                            draggedCategory = nil
                            dragOffset = 0
                            dropTargetIndex = nil
                        }
                )
        )
    }
    
    // MARK: - Drag and Drop Handling
    private func handleCategoryDrop(draggedCategory: ChannelCategory, translation: CGFloat) {
        print("🎯 handleCategoryDrop called with translation: \(translation)")
        
        let sortedCategories = categories.sorted(by: { $0.position < $1.position })
        print("📋 Current categories: \(sortedCategories.map { "\($0.name)(\($0.position))" })")
        
        guard let draggedIndex = sortedCategories.firstIndex(where: { $0.id == draggedCategory.id }) else {
            print("❌ Could not find dragged category in sorted list")
            return
        }
        
        // Calculate the approximate drop position based on translation
        let categoryHeight: CGFloat = 80 // More accurate height for category cards
        let sensitivity: CGFloat = 0.5 // Adjust sensitivity for reordering
        let dropOffset = Int(round(translation / (categoryHeight * sensitivity)))
        let newIndex = max(0, min(sortedCategories.count - 1, draggedIndex + dropOffset))
        
        print("📍 Drag details: draggedIndex=\(draggedIndex), dropOffset=\(dropOffset), newIndex=\(newIndex)")
        
        // Only proceed if the position actually changed
        guard newIndex != draggedIndex else {
            print("📍 No position change needed")
            return
        }
        
        print("📍 Moving category '\(draggedCategory.name)' from index \(draggedIndex) to \(newIndex)")
        
        // Calculate new positions for all categories
        var updatedCategories = sortedCategories
        let movedCategory = updatedCategories.remove(at: draggedIndex)
        updatedCategories.insert(movedCategory, at: newIndex)
        
        // Update positions
        for (index, _) in updatedCategories.enumerated() {
            updatedCategories[index] = ChannelCategory(
                id: updatedCategories[index].id,
                name: updatedCategories[index].name,
                position: index + 1,
                channels: updatedCategories[index].channels
            )
        }
        
        print("📋 Updated categories: \(updatedCategories.map { "\($0.name)(\($0.position))" })")
        
        // Update local state immediately for UI responsiveness
        categories = updatedCategories
        
        // Send to server
        updateCategoryPositionsOnServer(categories: updatedCategories)
        
        // Haptic feedback for successful drop
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - Backend API Functions
    private func createChannelOnServer(channelName: String, categoryId: Int? = nil, completion: @escaping (Bool, Channel?) -> Void)
    {
        guard let url = URL(string: "\(baseURL)circles/create_channel/") else {

            completion(false, nil as Channel?)
            return
        }
        
    var payload: [String: Any] = [
        "circle_id": circleId,
        "name": channelName,
        "position": localChannels.count + 1
    ]

    if let categoryId = categoryId {
        payload["category_id"] = categoryId
    }

        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Create channel error:", error?.localizedDescription ?? "unknown")
                completion(false, nil as Channel?)
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
                completion(false, nil as Channel?)
            }
        }.resume()
    }
    
    private func toggleModeratorOnly(_ channel: Channel) {
        guard let index = localChannels.firstIndex(where: { $0.id == channel.id }) else { return }

        let newValue = !(channel.isModeratorOnly ?? false)
        let payload: [String: Any] = [
            "channel_id": channel.id,
            "is_moderator_only": newValue,
            "user_id": userId
        ]

        guard let url = URL(string: "\(baseURL)circles/update_channel_visibility/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Visibility toggle error:", error.localizedDescription)
                    errorMessage = "Failed to update visibility"
                    showingError = true
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    localChannels[index].isModeratorOnly = newValue
                } else {
                    errorMessage = "Failed to update visibility"
                    showingError = true
                }
            }
        }.resume()
    }

    private func deleteChannelOnServer(channelId: Int, completion: @escaping (Bool) -> Void) {
        let urlString = "\(baseURL)circles/delete_channels/"
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        let payload: [String: Any] = [
            "circle_id": circleId,
            "channel_ids": [channelId],
            "user_id": userId
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

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
                print("❌ Failed with status: \(response.debugDescription)")
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
        
        // ADD DEBUG LOGGING
        print("🌐 Updating channel positions")
        print("📤 URL: \(url.absoluteString)")
        print("📤 Payload: \(payload)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid response")
                    return
                }
                
                print("📊 Status code: \(httpResponse.statusCode)")
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("📥 Response: \(responseString)")
                }
                
                if httpResponse.statusCode == 200 {
                    print("✅ Channel order updated successfully")
                } else {
                    print("❌ Server error: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
    
    // MARK: - Category Position Update
    private func updateCategoryPositionsOnServer(categories: [ChannelCategory]) {
        guard let url = URL(string: "\(baseURL)circles/update_category_positions/") else {
            print("❌ Invalid URL for updating category positions")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to update category order - Invalid URL"
                self.showingError = true
            }
            return
        }
        
        // Validate categories have valid IDs
        let validCategories = categories.filter { $0.id != nil && $0.id != -1 }
        if validCategories.count != categories.count {
            print("❌ Some categories have invalid IDs")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to update category order - Invalid category data"
                self.showingError = true
            }
            return
        }
        
        let positions = validCategories.map { category in
            ["id": category.id!, "position": category.position]
        }
        
        let payload: [String: Any] = [
            "circle_id": circleId,
            "user_id": userId,
            "positions": positions
        ]
        
        print("🌐 Updating category positions")
        print("📤 URL: \(url.absoluteString)")
        print("📤 Payload: \(payload)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("❌ Failed to serialize payload: \(error)")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to update category order - Data error"
                self.showingError = true
            }
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Category position update error: \(error.localizedDescription)")
                    self.errorMessage = "Network error - Categories reordered locally only"
                    self.showingError = true
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid response")
                    self.errorMessage = "Server communication error - Categories reordered locally only"
                    self.showingError = true
                    return
                }
                
                print("📊 Category position update status: \(httpResponse.statusCode)")
                
                // Check if we got HTML response (404 error page)
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("📥 Response: \(responseString)")
                    
                    if responseString.contains("<!DOCTYPE html>") || responseString.contains("<html") {
                        print("❌ Server returned HTML (likely 404 - endpoint not implemented)")
                        self.errorMessage = "Server endpoint not implemented yet - Categories reordered locally only. Changes will be lost when you refresh."
                        self.showingError = true
                        return
                    }
                }
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    print("✅ Category positions updated successfully")
                } else if httpResponse.statusCode == 404 {
                    print("❌ Endpoint not found (404)")
                    self.errorMessage = "Server endpoint not implemented yet - Categories reordered locally only. Changes will be lost when you refresh."
                    self.showingError = true
                } else {
                    print("❌ Server error: \(httpResponse.statusCode)")
                    let errorDetails = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
                    self.errorMessage = "Server error (\(httpResponse.statusCode)) - Categories reordered locally only"
                    self.showingError = true
                }
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
    let onToggleModeratorOnly: (Channel) -> Void
    
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
                Menu {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete Channel", systemImage: "trash")
                    }

                    Button {
                        onToggleModeratorOnly(channel)
                    } label: {
                        Label(
                            channel.isModeratorOnly == true ? "Make Public" : "Restrict to Moderators",
                            systemImage: channel.isModeratorOnly == true ? "lock.open" : "lock"
                        )
                    }

                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.gray.opacity(0.1)))
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
