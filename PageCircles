import SwiftUI

struct PageCircles: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Circl.")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Button(action: {
                                // Action for Filter
                            }) {
                                HStack {
                                    Image(systemName: "slider.horizontal.3")
                                        .foregroundColor(.white)
                                    Text("Filter")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 5) {
                            // Add the Bubble and Person icons above "Hello, Fragne"
                            VStack {
                                HStack(spacing: 10) {
                                    // Navigation Link for Bubble Symbol
                                    NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                                        Image(systemName: "bubble.left.and.bubble.right.fill")
                                            .resizable()
                                            .frame(width: 50, height: 40)  // Adjust size
                                            .foregroundColor(.white)
                                    }

                                    // Person Icon
                                    NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.white)
                                    }
                                }

                                // "Hello, Fragne" text below the icons
                                Text("Hello, Fragne")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 15)
                    .padding(.bottom, 10)
                    .background(Color.fromHex("004aad")) // Updated blue color
                }

                // Tab Navigation (Added here)
                tabNavigation
                
                // Scrollable Section
                ScrollView {
                    VStack(spacing: 20) {
                            // Hammer Symbol above the text
                            Image(systemName: "hammer.circle")
                                .resizable()
                                .frame(width: 100, height: 100)  // Frame size 100x100
                                .foregroundColor(Color.fromHex("004aad"))  // Custom blue color
                            
                            // Text below the hammer symbol
                            Text("Thank you for your patience with Circl! We are currently working on creating the \"circles\" feature - an opportunity for you to create a community with your industry or your network. Keep your notifications on and stay tuned in the discord server to know when we release it!")
                                .font(.body)
                                .foregroundColor(Color.fromHex("004aad")) // Custom blue color
                                .padding()
                                .background(Color.gray.opacity(0.4)) // System gray 4 background
                                .cornerRadius(10)
                                .padding(.top)
                            
                            Spacer()
                        }
                        .padding()
                    }
                
                
                // Footer Section (Imported)
                HStack(spacing: 15) {
                    NavigationLink(destination: PageEntrepreneurMatching().navigationBarBackButtonHidden(true)) {
                        CustomCircleButton(iconName: "figure.stand.line.dotted.figure.stand")
                    }
                    NavigationLink(destination: PageBusinessProfile().navigationBarBackButtonHidden(true)) {
                        CustomCircleButton(iconName: "briefcase.fill")
                    }
                    NavigationLink(destination: PageForum().navigationBarBackButtonHidden(true)) {
                        CustomCircleButton(iconName: "captions.bubble.fill")
                    }
                    NavigationLink(destination: PageEntrepreneurResources().navigationBarBackButtonHidden(true)) {
                        CustomCircleButton(iconName: "building.columns.fill")
                    }
                    NavigationLink(destination: PageEntrepreneurKnowledge().navigationBarBackButtonHidden(true)) {
                        CustomCircleButton(iconName: "newspaper")
                    }
                }
                .padding(.vertical, 10)
                .background(Color.white)
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    // Tab Navigation Definition (Imported)
    var tabNavigation: some View {
        HStack(spacing: 10) {
            NavigationLink(destination: PageMessages().navigationBarBackButtonHidden(true)) {
                Text("Messages")
                    .font(.system(size: 12))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)  // Changed from yellow to gray
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
            
            NavigationLink(destination: PageCircles().navigationBarBackButtonHidden(true)) {
                Text("Circles")
                    .font(.system(size: 12))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)  // Set Circles to yellow
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
            
            NavigationLink(destination: PageInvites().navigationBarBackButtonHidden(true)) {
                Text("Friends")
                    .font(.system(size: 12))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

// MARK: - CustomCircleButton
struct CustomCircleButton9: View {
    let iconName: String

    var body: some View {
        Button(action: {
            // Action for button
        }) {
            ZStack {
                Circle()
                    .fill(Color.fromHex("004aad"))
                    .frame(width: 60, height: 60)
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Color Extension
extension Color {
    static func fromHex9(_ hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        return Color(red: red, green: green, blue: blue)
    }
}

// MARK: - Preview
#Preview {
    PageCircles()
}
