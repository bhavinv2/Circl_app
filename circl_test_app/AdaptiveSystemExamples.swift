import SwiftUI

// MARK: - Complete Example: How to Use the Adaptive Layout System

/*
 This file demonstrates how to convert ANY existing page to use the adaptive layout system.
 
 Simply wrap your existing content with AdaptivePage or AdaptivePageWrapper!
*/

// MARK: - Example 1: Simple Page Conversion

struct ExampleSimplePage: View {
    var body: some View {
        // Before: Your existing page content
        // After: Just wrap it with AdaptivePage!
        AdaptivePage(title: "Simple Page") {
            VStack(spacing: 20) {
                Text("Your existing page content goes here!")
                    .font(.title2)
                    .padding()
                
                Text("This will automatically:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Label("Show sidebar on iPad/Mac", systemImage: "sidebar.left")
                    Label("Show bottom navigation on iPhone", systemImage: "iphone")
                    Label("Adapt layouts automatically", systemImage: "rectangle.grid.2x2")
                    Label("Maintain consistent navigation", systemImage: "arrow.left.arrow.right")
                }
                .padding()
                
                Button("Test Action") {
                    print("Button tapped!")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
    }
}

// MARK: - Example 2: Page with Custom Navigation

struct ExampleCustomNavPage: View {
    var body: some View {
        AdaptivePageWrapper<AnyView>.withNavigation(
            title: "Custom Navigation",
            navigationItems: [
                NavigationItem(icon: "house", title: "Home", destination: Text("Home")),
                NavigationItem(icon: "star", title: "Favorites", destination: Text("Favorites")),
                NavigationItem(icon: "gear", title: "Settings", destination: Text("Settings"))
            ]
        ) {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(1..<10) { index in
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Custom item \\(index)")
                                .font(.headline)
                            Spacer()
                            Button("Action") { }
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Example 3: Grid Layout with Adaptive Columns

struct ExampleGridPage: View {
    @State private var items = Array(1...20).map { index in "Item \(index)" }
    
    var body: some View {
        AdaptivePage(title: "Grid Example") {
            ScrollView {
                Text("Adaptive Grid Demo")
                    .font(.title)
                    .padding()
                
                Text("iPhone: Single column | iPad/Mac: Two columns")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                AdaptiveGrid {
                    ForEach(items, id: \.self) { item in
                        VStack {
                            Image(systemName: "star.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                            Text(item)
                                .font(.headline)
                            Text("Automatically adapts to screen size")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Example 4: Converting Existing PageSettings

struct ExampleAdaptiveSettings: View {
    @State private var notifications = true
    @State private var darkMode = false
    @State private var username = "JohnDoe"
    
    var body: some View {
        AdaptivePage(title: "Settings") {
            Form {
                Section("Preferences") {
                    Toggle("Push Notifications", isOn: $notifications)
                    Toggle("Dark Mode", isOn: $darkMode)
                }
                
                Section("Account") {
                    HStack {
                        Text("Username")
                        Spacer()
                        TextField("Username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                    }
                    
                    Button("Change Password") {
                        // Handle password change
                    }
                    
                    Button("Sign Out") {
                        // Handle sign out
                    }
                    .foregroundColor(.red)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Privacy Policy") {
                        // Show privacy policy
                    }
                    
                    Button("Terms of Service") {
                        // Show terms
                    }
                }
            }
        }
    }
}

// MARK: - How to Migrate Your Existing Pages

/*
 
 STEP 1: SIMPLE MIGRATION
 ========================
 
 // OLD CODE:
 struct MyPage: View {
     var body: some View {
         NavigationView {
             VStack {
                 Text("My Content")
                 // ... your existing content
             }
         }
     }
 }
 
 // NEW CODE:
 struct MyPage: View {
     var body: some View {
         AdaptivePage(title: "My Page") {
             VStack {
                 Text("My Content")
                 // ... your existing content (UNCHANGED!)
             }
         }
     }
 }
 
 That's it! Your page now works on iPhone AND iPad/Mac with adaptive layouts.
 
 
 STEP 2: ADVANCED CUSTOMIZATION
 ===============================
 
 If you need custom header actions or navigation:
 
 AdaptivePageWrapper.withHeaderActions(
     title: "My Advanced Page",
     headerActions: [
         HeaderAction(icon: "bell", badge: "3") { 
             // Handle notifications 
         },
         HeaderAction(icon: "plus") { 
             // Add new item 
         }
     ]
 ) {
     // Your content here
 }
 
 
 STEP 3: GRID LAYOUTS
 =====================
 
 For content that should be in columns on larger screens:
 
 AdaptivePage(title: "Grid Page") {
     ScrollView {
         AdaptiveGrid {
             ForEach(items) { item in
                 ItemView(item: item)
             }
         }
     }
 }
 
 
 DEVICE BEHAVIOR:
 ================
 
 📱 iPhone (Compact):
    - Bottom navigation (5 tabs)
    - Single column layouts
    - Compact headers
    - Full-width content
 
 📱 iPad/Mac (Regular):
    - Left sidebar navigation
    - Two-column grids
    - Larger headers
    - Collapsible sidebar
    - Better use of screen space
 
 */

// MARK: - Preview

struct AdaptiveSystemExamples_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExampleSimplePage()
                .previewDisplayName("Simple Page")
            
            ExampleGridPage()
                .previewDisplayName("Grid Layout")
            
            ExampleAdaptiveSettings()
                .previewDisplayName("Settings Example")
        }
    }
}