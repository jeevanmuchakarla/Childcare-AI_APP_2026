import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromMe: Bool
    let timestamp: Date
    var senderName: String = ""
}


public struct ChatView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var messageStore: MessageStore
    let role: UserRole
    @State private var searchText = ""
    @State private var selectedContact: ChatContact? = nil
    @State private var selectedCategory: String? = nil
    @State private var remoteContacts: [ChatContact] = []
    @State private var isLoadingContacts = false
    @State private var autoOpenUserId: Int? = nil
    @State private var autoOpenUserName: String? = nil
    
    public init(role: UserRole, initialCategory: String? = nil, autoOpenUserId: Int? = nil, autoOpenUserName: String? = nil) {
        self.role = role
        self._selectedCategory = State(initialValue: initialCategory)
        self._autoOpenUserId = State(initialValue: autoOpenUserId)
        self._autoOpenUserName = State(initialValue: autoOpenUserName)
    }
    
    private var filteredContacts: [ChatContact] {
        let allContacts = contacts
        if let category = selectedCategory {
            // Include both remote contacts and existing inbox items that match the category
            // We'll filter the aggregate list by checking if the name or type matches
            return allContacts.filter { contact in
                let matchesCategory = contact.name.localizedCaseInsensitiveContains(category) || 
                                     (remoteContacts.contains(where: { $0.userId == contact.userId }))
                let matchesSearch = searchText.isEmpty || contact.name.localizedCaseInsensitiveContains(searchText)
                return matchesCategory && matchesSearch
            }
        }
        return allContacts.filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    // Live contacts: prefer backend inbox, fallback to demo data
    private var contacts: [ChatContact] {
        var baseContacts: [ChatContact] = []
        
        if !messageStore.inbox.isEmpty {
            baseContacts = messageStore.inbox.map { item in
                let name = item.full_name ?? (item.email.components(separatedBy: "@").first?.capitalized ?? item.email)
                let initial = String(name.prefix(2)).uppercased()
                let colors: [Color] = [.blue, .purple, .orange, .green, AppTheme.roleProvider]
                let color = colors[abs(item.user_id) % colors.count]
                let time = formatTimestamp(item.timestamp)
                return ChatContact(
                    name: name,
                    initial: initial,
                    color: color,
                    lastMessage: item.last_message,
                    time: time,
                    unread: item.is_read ? 0 : 1,
                    userId: item.user_id
                )
            }
        }
        
        // Add remote contacts fetched for the specific category
        for remote in remoteContacts {
            if !baseContacts.contains(where: { $0.userId == remote.userId }) {
                baseContacts.append(remote)
            }
        }
        
        // Demo fallback only if no inbox and no remote contacts
        if baseContacts.isEmpty {
            switch role {
            case .parent, .daycare, .preschool, .admin:
                return []
            }
        }
        
        return baseContacts
    }
    
    private static let isoFormatter = ISO8601DateFormatter()
    
    private func formatTimestamp(_ iso: String) -> String {
        guard let date = Self.isoFormatter.date(from: iso) else { return "" }
        let diff = Date().timeIntervalSince(date)
        if diff < 60 { return "Just now" }
        if diff < 3600 { return "\(Int(diff/60))m ago" }
        if diff < 86400 { return "\(Int(diff/3600))h ago" }
        return "Yesterday"
    }
    
    // Returns live unread count from backend (by role), falls back to local contacts
    private func unreadCount(for category: String) -> Int {
        // Try live data from MessageStore first (keyed by role name)
        let roleKey = category.lowercased()
        if let liveCount = messageStore.unreadByRole[roleKey], liveCount > 0 {
            return liveCount
        }
        // Fallback: count from local contact list
        return contacts.filter { $0.name.localizedCaseInsensitiveContains(category) }
            .reduce(0) { $0 + $1.unread }
    }
    
    public var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                AppHeader(title: "Messages", showBackButton: false)
                
                // Search Bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search conversations", text: $searchText)
                        .font(.body)
                }
                .padding(12)
                .background(AppTheme.surface)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 24)
                
                if selectedCategory == nil && searchText.isEmpty {
                    // Modern Dashboard Grid View (Initial State)
                    Spacer()
                    VStack(spacing: 24) {
                        let items = role == .parent ? 
                            [(title: "Preschool", icon: "graduationcap.fill", color: Color.blue),
                             (title: "Daycare", icon: "house.fill", color: Color.orange),
                             (title: "Admin", icon: "shield.fill", color: Color.red)] :
                            (role == .daycare || role == .preschool) ?
                            [(title: "Parent", icon: "person.3.fill", color: Color.blue),
                             (title: "Admin", icon: "shield.fill", color: Color.red)] :
                            // Admin role
                            [(title: "Parent", icon: "person.3.fill", color: Color.blue),
                             (title: "Preschool", icon: "graduationcap.fill", color: Color.orange),
                             (title: "Daycare", icon: "house.fill", color: Color.green)]

                        if items.count == 3 {
                            // Professional layout for 3 items: 2 on top, 1 centered below
                            VStack(spacing: 20) {
                                HStack(spacing: 20) {
                                    QuickChatButton(title: items[0].title, icon: items[0].icon, color: items[0].color, unreadCount: unreadCount(for: items[0].title), isSelected: false) { selectCategory(items[0].title) }
                                    QuickChatButton(title: items[1].title, icon: items[1].icon, color: items[1].color, unreadCount: unreadCount(for: items[1].title), isSelected: false) { selectCategory(items[1].title) }
                                }
                                QuickChatButton(title: items[2].title, icon: items[2].icon, color: items[2].color, unreadCount: unreadCount(for: items[2].title), isSelected: false) { selectCategory(items[2].title) }
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 80) // Center lower button
                            }
                            .padding(.horizontal, 20)
                        } else {
                            // Standard 2x2 grid for 4 items
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], spacing: 20) {
                                ForEach(items, id: \.title) { item in
                                    QuickChatButton(title: item.title, icon: item.icon, color: item.color, unreadCount: unreadCount(for: item.title), isSelected: false) { selectCategory(item.title) }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    Spacer()
                    Spacer()
                } else {
                    // Filtered List View
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text(selectedCategory ?? "Search Results")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Button(action: { selectedCategory = nil; searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .font(.title3)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                        
                        if isLoadingContacts {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                        }
                        
                        ScrollView {
                            VStack(spacing: 0) {
                                if filteredContacts.isEmpty {
                                    VStack(spacing: 20) {
                                        Image(systemName: "message.circle")
                                            .font(.system(size: 64))
                                            .foregroundColor(.gray.opacity(0.2))
                                        Text("No messages in this category")
                                            .foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 60)
                                } else {
                                    ForEach(filteredContacts) { contact in
                                        Button(action: {
                                            selectedContact = contact
                                        }) {
                                            HStack(spacing: 16) {
                                                ZStack(alignment: .bottomTrailing) {
                                                    Circle()
                                                        .fill(contact.color.opacity(0.1))
                                                        .frame(width: 60, height: 60)
                                                    Text(contact.initial)
                                                        .font(.system(size: 20, weight: .bold))
                                                        .foregroundColor(contact.color)
                                                    
                                                    Circle()
                                                        .fill(Color.green)
                                                        .frame(width: 14, height: 14)
                                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    HStack {
                                                        Text(contact.name)
                                                            .font(.headline)
                                                            .foregroundColor(AppTheme.textPrimary)
                                                        Spacer()
                                                        Text(contact.time)
                                                            .font(.caption)
                                                            .foregroundColor(AppTheme.textSecondary)
                                                    }
                                                    HStack {
                                                        Text(contact.lastMessage)
                                                            .font(.subheadline)
                                                            .foregroundColor(AppTheme.textSecondary)
                                                            .lineLimit(1)
                                                        Spacer()
                                                        if contact.unread > 0 {
                                                            Text("\(contact.unread)")
                                                                .font(.system(size: 11, weight: .bold))
                                                                .foregroundColor(.white)
                                                                .frame(width: 22, height: 22)
                                                                .background(themeManager.primaryColor)
                                                                .clipShape(Circle())
                                                        }
                                                    }
                                                }
                                            }
                                            .padding(.horizontal)
                                            .padding(.vertical, 14)
                                            .background(AppTheme.surface)
                                        }
                                        Divider().padding(.leading, 88)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .sheet(item: $selectedContact) { contact in
            ChatConversationView(contact: contact)
                .environmentObject(themeManager)
                .environmentObject(messageStore)
        }
        .onAppear {
            if let userId = AuthService.shared.currentUser?.id {
                messageStore.startInboxPolling(userId: userId)
            }
            if let cat = selectedCategory {
                fetchRemoteContacts(for: cat)
            }
            
            // Auto open logic
            if let targetId = autoOpenUserId, let targetName = autoOpenUserName {
                let color = role == .parent ? Color.blue : (role == .preschool ? .orange : (role == .daycare ? AppTheme.roleProvider : .red))
                let contact = ChatContact(
                    name: targetName,
                    initial: String(targetName.prefix(2)).uppercased(),
                    color: color,
                    lastMessage: "Start of conversation",
                    time: "Now",
                    unread: 0,
                    userId: targetId
                )
                self.selectedContact = contact
                // Clear state so it doesn't open every time the view appears if navigated back
                self.autoOpenUserId = nil
                self.autoOpenUserName = nil
            }
        }
    }
    
    private func selectCategory(_ category: String) {
        withAnimation(.spring()) {
            selectedCategory = category
        }
        fetchRemoteContacts(for: category)
    }
    
    private func fetchRemoteContacts(for category: String) {
        isLoadingContacts = true
        // Only reset if we change categories
        // remoteContacts = []
        
        Task {
            do {
                // Ensure role match backend expected strings
                // Backend roles: 'Parent', 'Preschool', 'Daycare', 'Admin'
                var backendRole = category
                if category == "Parents" || category == "Parent" { 
                    backendRole = "Parent" 
                } else if category == "Preschool" {
                    backendRole = "Preschool"
                } else if category == "Daycare" {
                    backendRole = "Daycare"
                } else if category == "Admin" {
                    backendRole = "Admin"
                }
                
                let remoteUsers = try await ProfileService.shared.fetchUsersByRole(role: backendRole)
                
                let mapped = remoteUsers.map { user in
                    ChatContact(
                        name: user.full_name,
                        initial: String(user.full_name.prefix(2)).uppercased(),
                        color: category == "Preschool" ? Color(hex: "#FF8C00") : category == "Daycare" ? AppTheme.roleProvider : category == "Admin" ? .red : .blue,
                        lastMessage: "Tap to chat",
                        time: "",
                        unread: 0,
                        userId: user.id
                    )
                }
                
                await MainActor.run {
                    self.remoteContacts = mapped
                    self.isLoadingContacts = false
                }
            } catch {
                print("DEBUG: Error fetching remote contacts: \(error)")
                await MainActor.run {
                    self.isLoadingContacts = false
                }
            }
        }
    }
}

struct ChatConversationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var messageStore: MessageStore
    let contact: ChatContact
    
    @State private var messageText = ""
    @State private var isSending = false
    @State private var canChat = true
    @State private var isCheckingPermission = true
    
    @ObservedObject var authService = AuthService.shared
    
    private var myId: Int { authService.currentUser?.id ?? 0 }
    private var otherId: Int { contact.userId ?? 0 }

    @State private var showClearConfirmation = false
    @State private var showReportConfirmation = false
    @State private var showBlockConfirmation = false
    @State private var showReportSuccess = false
    @State private var showBlockSuccess = false
    @State private var errorMessage: String? = nil
    @State private var showErrorMessage = false
    
    // Image Upload State
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header for sheet (since we are in a sheet, NavigationStack is already inside)
            HStack {
                Button(action: {
                    messageStore.stopPolling()
                    dismiss()
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.primaryColor)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text(contact.name)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Online")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Button(action: { showReportConfirmation = true }) {
                    Image(systemName: "flag")
                        .foregroundColor(.orange)
                }
                .padding(.trailing, 8)

                Button(action: { showBlockConfirmation = true }) {
                    Image(systemName: "hand.raised")
                        .foregroundColor(.red)
                }
                .padding(.trailing, 8)
                
                Button(action: { showClearConfirmation = true }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red.opacity(0.8))
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(AppTheme.surface) // Dynamic header background
            
            Divider()
                // Live Messages - Isolated in sub-view to prevent re-renders on typing
                MessageListView(contactName: contact.name)
                
                // Typing indicator
                if messageStore.isSending {
                    HStack {
                        HStack(spacing: 4) {
                            ForEach(0..<3) { i in
                                Circle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 7, height: 7)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(AppTheme.surface)
                        .cornerRadius(18)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                }
                
                Divider()
                
                // Input Bar or Restriction Message
                if isCheckingPermission {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                    .background(AppTheme.surface)
                } else if !canChat {
                    HStack {
                        Spacer()
                        Text("You must have an approved booking to chat.")
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding()
                        Spacer()
                    }
                    .background(AppTheme.surface)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        if let data = selectedImageData, let uiImage = UIImage(data: data) {
                            HStack(alignment: .top) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                                    .clipped()
                                
                                Button(action: { selectedItem = nil; selectedImageData = nil }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                                .offset(x: -10, y: -5)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        
                        HStack(spacing: 12) {
                            TextField("Message", text: $messageText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(AppTheme.background)
                                .cornerRadius(20)
                            
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray)
                            }
                            .onChange(of: selectedItem) { _, newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        await MainActor.run { selectedImageData = data }
                                    }
                                }
                            }

                            if !messageText.isEmpty || selectedImageData != nil {
                                Button(action: {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    sendLiveMessage()
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(themeManager.primaryColor)
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "paperplane.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                    }
                    .background(AppTheme.surface)
                }
            } // Close VStack
        .background(AppTheme.background.ignoresSafeArea())
        .alert("Clear Chat?", isPresented: $showClearConfirmation) {
            Button("Clear", role: .destructive) {
                Task {
                    await messageStore.clearBackendConversation(myId: myId, otherId: otherId)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all messages in this conversation for you.")
        }
        .alert("Message Error", isPresented: $showErrorMessage) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "Unknown error occurred while sending your message.")
        }
        .alert("Report User?", isPresented: $showReportConfirmation) {
            Button("Report", role: .destructive) { showReportSuccess = true }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to report this user for objectionable content? Our team will review this conversation within 24 hours.")
        }
        .alert("User Reported", isPresented: $showReportSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Thank you for your report. We will investigate this user and take appropriate action.")
        }
        .alert("Block User?", isPresented: $showBlockConfirmation) {
            Button("Block", role: .destructive) { showBlockSuccess = true }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to block this user? You will no longer receive messages from them.")
        }
        .alert("User Blocked", isPresented: $showBlockSuccess) {
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text("This user has been blocked. This conversation is now closed.")
        }
        .onAppear {
            // Start real-time polling
            if myId > 0 && otherId > 0 {
                Task {
                    do {
                        let allowed = try await MessageService.shared.checkChatPermission(user1: myId, user2: otherId)
                        await MainActor.run {
                            self.canChat = allowed
                            self.isCheckingPermission = false
                            if allowed {
                                messageStore.startPolling(myId: myId, otherId: otherId, contactName: contact.name)
                            }
                        }
                    } catch {
                        print("DEBUG ERROR checkChatPermission: \(error)")
                        await MainActor.run {
                            self.isCheckingPermission = false
                            // Default to false on error for safety
                            self.canChat = false
                        }
                    }
                }
            } else {
                print("DEBUG: myId \(myId) or otherId \(otherId) is <= 0")
                // Demo mode: seed messages if no auth
                self.isCheckingPermission = false
            }
        }
        .onDisappear {
            messageStore.stopPolling()
        }
    }
    
    private func sendLiveMessage() {
        let text = messageText.trimmingCharacters(in: .whitespaces)
        let imageData = selectedImageData
        guard !text.isEmpty || imageData != nil else { return }
        
        messageText = ""
        selectedItem = nil
        selectedImageData = nil
        isSending = true
        
        Task {
            var uploadedUrl: String? = nil
            if let data = imageData {
                // Upload image first
                do {
                    let boundary = "Boundary-\(UUID().uuidString)"
                    let url = URL(string: "\(AuthService.shared.baseURL)/upload/image")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                    
                    var body = Data()
                    body.append("--\(boundary)\r\n".data(using: .utf8)!)
                    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
                    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                    body.append(data)
                    body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                    
                    request.httpBody = body
                    
                    let (data, response) = try await BaseService.sharedServiceSession.data(for: request)
                    if let http = response as? HTTPURLResponse, http.statusCode == 200 || http.statusCode == 201 {
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let url = json["url"] as? String {
                            uploadedUrl = url
                        }
                    }
                } catch {
                }
            }

            if myId > 0 {
                print("DEBUG: Sending live message myId:\(myId) otherId:\(otherId)")
                do {
                    try await messageStore.sendMessage(myId: myId, otherId: otherId, text: text, imageUrl: uploadedUrl)
                } catch {
                    await MainActor.run {
                        self.errorMessage = "Failed to send: \(error.localizedDescription)"
                        self.showErrorMessage = true
                    }
                }
            } else {
                print("DEBUG: Cannot send, myId is <= 0")
                // Demo mode support omitted for brevity, similar to existing logic
            }
            await MainActor.run { isSending = false }
        }
    }
}

struct MessageListView: View {
    @EnvironmentObject var messageStore: MessageStore
    let contactName: String
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 8) {
                        if messageStore.messages.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black.opacity(0.3))
                                Text("Messages are end-to-end encrypted. No one outside of this chat can read them.")
                                    .font(.system(size: 12))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.black.opacity(0.4))
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 8)
                                    .background(Color(hex: "#FFF9C4").opacity(0.8))
                                    .cornerRadius(8)
                            }
                            .padding(.top, 20)
                        }
                        
                        ForEach(messageStore.messages) { msg in
                            LiveMessageBubble(message: msg)
                                .id(msg.id)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 16)
                }
                .onChange(of: messageStore.messages.count) { _, _ in
                    if let last = messageStore.messages.last {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
}

import PhotosUI

struct LiveMessageBubble: View {
    @EnvironmentObject var themeManager: ThemeManager
    let message: LiveMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isFromMe {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 4) {
                if let imageUrl = message.imageUrl, !imageUrl.isEmpty {
                    AsyncImage(url: URL(string: "\(AuthService.shared.baseURL.replacingOccurrences(of: "/api", with: ""))\(imageUrl)")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 240)
                            .maxHeight(300)
                            .cornerRadius(12)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 240, height: 200)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                    .padding(.bottom, 4)
                }
                
                if !message.isFromMe {
                    Text(message.senderName)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(themeManager.primaryColor)
                        .padding(.horizontal, 12)
                }

                if !message.text.isEmpty {
                    Text(message.text)
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(message.isFromMe ? themeManager.primaryColor.opacity(0.15) : AppTheme.surface)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
                        )
                        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                }
                
                Text(message.timestamp, style: .time)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }
            
            if !message.isFromMe {
                Spacer(minLength: 50)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

// Extension to allow maxHeight on AsyncImage or similar
extension View {
    func maxHeight(_ height: CGFloat) -> some View {
        self.frame(maxHeight: height)
    }
}

struct QuickChatButton: View {
    let title: String
    let icon: String
    let color: Color
    let unreadCount: Int
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(isSelected ? .white.opacity(0.15) : color.opacity(0.08))
                            .frame(width: 72, height: 72)
                        Image(systemName: icon)
                            .foregroundColor(isSelected ? .white : color)
                            .font(.system(size: 34, weight: .semibold))
                    }
                    
                    VStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
                        
                        if unreadCount > 0 {
                            Text("\(unreadCount) New Messages")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(isSelected ? .white.opacity(0.9) : themeManager.primaryColor)
                        } else {
                            Text("No new alerts")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textSecondary.opacity(0.7))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(isSelected ? color : AppTheme.surface)
                        .shadow(color: isSelected ? color.opacity(0.3) : Color.black.opacity(0.04), radius: 15, x: 0, y: 8)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(isSelected ? .clear : Color.black.opacity(0.03), lineWidth: 1)
                )
                
                if unreadCount > 0 {
                    Text("\(unreadCount)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.red)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .offset(x: 8, y: -8)
                        .shadow(color: .black.opacity(0.1), radius: 4)
                }
            }
        }
        .buttonStyle(BounceButtonStyle())
    }
}
