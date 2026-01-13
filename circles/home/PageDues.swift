import SwiftUI
import SafariServices

struct PageDues: View {
    let circle: CircleData
    @AppStorage("user_id") private var userId: Int = 0
    @Environment(\.presentationMode) var presentationMode

    // State
    @State private var duesAmount: Int?
    @State private var isModerator: Bool = false
    @State private var hasStripeAccount: Bool = false

    @State private var stripeOnboardingURL: WebViewURL?
    @State private var newDuesAmount: String = ""
    @State private var isLoading = true
    @State private var checkoutURL: WebViewURL?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Stunning gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "004aad").opacity(0.1),
                        Color(hex: "004aad").opacity(0.05),
                        Color.white
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Elegant Header
                        HStack {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color(hex: "004aad"))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle()
                                            .fill(Color.white)
                                            .shadow(color: Color(hex: "004aad").opacity(0.1), radius: 8, x: 0, y: 4)
                                    )
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 4) {
                                Text("Circle Dues")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "004aad"))
                                
                                Text(circle.name)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Color.clear.frame(width: 44)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 32)

                        if isLoading {
                            VStack(spacing: 24) {
                                // Stunning loading animation
                                ZStack {
                                    Circle()
                                        .stroke(Color(hex: "004aad").opacity(0.2), lineWidth: 4)
                                        .frame(width: 60, height: 60)
                                    
                                    Circle()
                                        .trim(from: 0, to: 0.7)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color(hex: "004aad"), Color(hex: "004aad").opacity(0.3)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                        )
                                        .frame(width: 60, height: 60)
                                        .rotationEffect(.degrees(-90))
                                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isLoading)
                                }
                                
                                Text("Loading dues information...")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(hex: "004aad"))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 80)
                        } else {
                            VStack(spacing: 24) {
                                if let dues = duesAmount {
                                    // Stunning dues display card
                                    VStack(spacing: 20) {
                                        VStack(spacing: 8) {
                                            Text("Current Dues")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.secondary)
                                            
                                            Text("$\(Double(dues) / 100, specifier: "%.2f")")
                                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                                .foregroundColor(Color(hex: "004aad"))
                                        }
                                        
                                        Rectangle()
                                            .fill(Color(hex: "004aad").opacity(0.1))
                                            .frame(height: 1)
                                            .padding(.horizontal, 20)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 32)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.white)
                                            .shadow(color: Color(hex: "004aad").opacity(0.1), radius: 20, x: 0, y: 8)
                                    )
                                    .padding(.horizontal, 24)

                                    if isModerator {
                                        // Moderator actions card
                                        VStack(spacing: 20) {
                                            HStack {
                                                Image(systemName: "crown.fill")
                                                    .foregroundColor(.orange)
                                                    .font(.title3)
                                                Text("Moderator Actions")
                                                    .font(.headline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color(hex: "004aad"))
                                                Spacer()
                                            }
                                            
                                            VStack(spacing: 16) {
                                                HStack {
                                                    Image(systemName: "dollarsign.circle.fill")
                                                        .foregroundColor(Color(hex: "004aad"))
                                                        .font(.title3)
                                                    
                                                    TextField("Update dues amount", text: $newDuesAmount)
                                                        .keyboardType(.decimalPad)
                                                        .font(.body)
                                                        .fontWeight(.medium)
                                                }
                                                .padding(16)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(Color(hex: "004aad").opacity(0.05))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 12)
                                                                .stroke(Color(hex: "004aad").opacity(0.2), lineWidth: 1)
                                                        )
                                                )

                                                Button(action: {
                                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                        updateDues()
                                                    }
                                                }) {
                                                    HStack(spacing: 12) {
                                                        Image(systemName: "arrow.up.circle.fill")
                                                            .font(.title3)
                                                        Text("Update Dues")
                                                            .font(.headline)
                                                            .fontWeight(.semibold)
                                                    }
                                                    .foregroundColor(.white)
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 16)
                                                    .background(
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [Color(hex: "004aad"), Color(hex: "004aad").opacity(0.8)]),
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )
                                                    )
                                                    .cornerRadius(12)
                                                    .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 8, x: 0, y: 4)
                                                }

                                                // Always show Stripe button for moderators
                                                Button(action: {
                                                    createStripeAccount()
                                                }) {
                                                    HStack(spacing: 8) {
                                                        Image(systemName: hasStripeAccount ? "creditcard.circle" : "plus.circle")
                                                            .font(.body)
                                                        Text(hasStripeAccount ? "Edit Stripe Info" : "Set Up Stripe")
                                                            .font(.body)
                                                            .fontWeight(.medium)
                                                    }
                                                    .foregroundColor(Color(hex: "004aad"))
                                                }
                                                .padding(.top, 8)
                                            }
                                        }
                                        .padding(24)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.white)
                                                .shadow(color: Color(hex: "004aad").opacity(0.08), radius: 16, x: 0, y: 6)
                                        )
                                        .padding(.horizontal, 24)

                                    } else {
                                        // Member payment card
                                        VStack(spacing: 20) {
                                            HStack {
                                                Image(systemName: "creditcard.fill")
                                                    .foregroundColor(.green)
                                                    .font(.title2)
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("Payment Required")
                                                        .font(.headline)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.primary)
                                                    Text("Complete your circle dues payment")
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
                                                Spacer()
                                            }
                                            
                                            Button(action: {
                                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                    startCheckout()
                                                }
                                            }) {
                                                HStack(spacing: 12) {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.title3)
                                                    Text("Pay Now")
                                                        .font(.headline)
                                                        .fontWeight(.semibold)
                                                }
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 16)
                                                .background(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .cornerRadius(12)
                                                .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                                            }
                                        }
                                        .padding(24)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.white)
                                                .shadow(color: Color.green.opacity(0.08), radius: 16, x: 0, y: 6)
                                        )
                                        .padding(.horizontal, 24)
                                    }
                                } else {
                                    // No dues set card
                                    VStack(spacing: 24) {
                                        VStack(spacing: 16) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .font(.system(size: 48))
                                                .foregroundColor(.orange)
                                            
                                            VStack(spacing: 8) {
                                                Text("Dues Not Set")
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.primary)
                                                
                                                Text("Circle dues haven't been configured yet")
                                                    .font(.body)
                                                    .foregroundColor(.secondary)
                                                    .multilineTextAlignment(.center)
                                            }
                                        }
                                        .padding(.bottom, 8)

                                        if isModerator {
                                            if hasStripeAccount {
                                                VStack(spacing: 16) {
                                                    HStack {
                                                        Image(systemName: "dollarsign.circle.fill")
                                                            .foregroundColor(Color(hex: "004aad"))
                                                            .font(.title3)
                                                        
                                                        TextField("Enter dues amount", text: $newDuesAmount)
                                                            .keyboardType(.decimalPad)
                                                            .font(.body)
                                                            .fontWeight(.medium)
                                                    }
                                                    .padding(16)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .fill(Color(hex: "004aad").opacity(0.05))
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 12)
                                                                    .stroke(Color(hex: "004aad").opacity(0.2), lineWidth: 1)
                                                            )
                                                    )

                                                    Button(action: {
                                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                            updateDues()
                                                        }
                                                    }) {
                                                        HStack(spacing: 12) {
                                                            Image(systemName: "plus.circle.fill")
                                                                .font(.title3)
                                                            Text("Set Dues Amount")
                                                                .font(.headline)
                                                                .fontWeight(.semibold)
                                                        }
                                                        .foregroundColor(.white)
                                                        .frame(maxWidth: .infinity)
                                                        .padding(.vertical, 16)
                                                        .background(
                                                            LinearGradient(
                                                                gradient: Gradient(colors: [Color(hex: "004aad"), Color(hex: "004aad").opacity(0.8)]),
                                                                startPoint: .leading,
                                                                endPoint: .trailing
                                                            )
                                                        )
                                                        .cornerRadius(12)
                                                        .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 8, x: 0, y: 4)
                                                    }

                                                    // Always show Stripe button for moderators
                                                    Button(action: {
                                                        createStripeAccount()
                                                    }) {
                                                        HStack(spacing: 8) {
                                                            Image(systemName: hasStripeAccount ? "creditcard.circle" : "plus.circle")
                                                                .font(.body)
                                                            Text(hasStripeAccount ? "Edit Stripe Info" : "Set Up Stripe")
                                                                .font(.body)
                                                                .fontWeight(.medium)
                                                        }
                                                        .foregroundColor(Color(hex: "004aad"))
                                                    }
                                                    .padding(.top, 8)
                                                }

                                            } else {
                                                VStack(spacing: 16) {
                                                    Image(systemName: "creditcard.and.123")
                                                        .font(.system(size: 32))
                                                        .foregroundColor(Color(hex: "004aad"))
                                                    
                                                    VStack(spacing: 8) {
                                                        Text("Setup Required")
                                                            .font(.headline)
                                                            .fontWeight(.semibold)
                                                            .foregroundColor(.primary)
                                                        
                                                        Text("Connect Stripe to start collecting dues")
                                                            .font(.body)
                                                            .foregroundColor(.secondary)
                                                            .multilineTextAlignment(.center)
                                                    }
                                                    
                                                    Button(action: {
                                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                            createStripeAccount()
                                                        }
                                                    }) {
                                                        HStack(spacing: 12) {
                                                            Image(systemName: "link.circle.fill")
                                                                .font(.title3)
                                                            Text("Set Up Stripe")
                                                                .font(.headline)
                                                                .fontWeight(.semibold)
                                                        }
                                                        .foregroundColor(.white)
                                                        .frame(maxWidth: .infinity)
                                                        .padding(.vertical, 16)
                                                        .background(
                                                            LinearGradient(
                                                                gradient: Gradient(colors: [Color(hex: "004aad"), Color(hex: "004aad").opacity(0.8)]),
                                                                startPoint: .leading,
                                                                endPoint: .trailing
                                                            )
                                                        )
                                                        .cornerRadius(12)
                                                        .shadow(color: Color(hex: "004aad").opacity(0.3), radius: 8, x: 0, y: 4)
                                                    }
                                                }
                                            }
                                        } else {
                                            VStack(spacing: 16) {
                                                Image(systemName: "clock.fill")
                                                    .font(.system(size: 32))
                                                    .foregroundColor(.orange)
                                                
                                                VStack(spacing: 8) {
                                                    Text("Waiting for Setup")
                                                        .font(.headline)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.primary)
                                                    
                                                    Text("Moderators will configure dues soon")
                                                        .font(.body)
                                                        .foregroundColor(.secondary)
                                                        .multilineTextAlignment(.center)
                                                }
                                            }
                                        }
                                    }
                                    .padding(24)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.white)
                                            .shadow(color: Color.orange.opacity(0.08), radius: 16, x: 0, y: 6)
                                    )
                                    .padding(.horizontal, 24)
                                }
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 24)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: isLoading)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: duesAmount)
        }
        .onAppear {
            fetchDues()
        }
        .sheet(item: $stripeOnboardingURL) { wrapper in
            SafariView(url: wrapper.url)
        }
        .sheet(item: $checkoutURL) { wrapper in
            SafariView(url: wrapper.url)
        }
    }

    // MARK: - Backend Calls

    func fetchDues() {
        guard let url = URL(string: "\(baseURL)circles/get_circle_details/?circle_id=\(circle.id)&user_id=\(userId)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                isLoading = false
            }
            guard let data = data else { return }

            if let decoded = try? JSONDecoder().decode(CircleData.self, from: data) {
                print("🧩 FETCHED duesAmount =", decoded.duesAmount ?? -1)
                print("🧩 FETCHED isModerator =", decoded.isModerator)
                print("🧩 FETCHED hasStripeAccount =", decoded.hasStripeAccount ?? false)
                print("🧩 DEBUG: Edit Stripe Info should show = \(decoded.isModerator && (decoded.hasStripeAccount ?? false))")

                DispatchQueue.main.async {
                    self.duesAmount = decoded.duesAmount
                    self.isModerator = decoded.isModerator
                    self.hasStripeAccount = decoded.hasStripeAccount ?? false

                }
            }

        }.resume()
    }
    private func createStripeAccount(completion: @escaping (Bool) -> Void = { _ in }) {
        guard let url = URL(string: "\(baseURL)circles/create_stripe_account/") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "user_id": userId,
            "circle_id": circle.id
        ]


        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(false)
                return
            }

            DispatchQueue.main.async {
                if let urlString = json["url"] as? String,
                   let url = URL(string: urlString) {
                    self.stripeOnboardingURL = WebViewURL(url: url)
                    completion(true)
                } else if json["status"] as? String == "already_connected" {
                    // You could show an alert here if you want
                    print("✅ Already connected to Stripe.")
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }.resume()
    }


    private func updateDues(completion: @escaping (Bool) -> Void = { _ in }) {
        let cents = Int((Double(newDuesAmount) ?? 0) * 100)

        guard let url = URL(string: "\(baseURL)circles/set_circle_dues/") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "user_id": userId,
            "circle_id": circle.id,
            "price_cents": cents
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { _, _, _ in
            fetchDues()
            completion(true)
        }.resume()
    }

    private func startCheckout(completion: @escaping (Bool) -> Void = { _ in }) {
        guard let url = URL(string: "\(baseURL)circles/create_checkout_session/") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "circle_id": circle.id,
            "user_id": userId
        ])

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let urlString = json["checkout_url"] as? String,
                  let url = URL(string: urlString) else {
                completion(false)
                return
            }

            DispatchQueue.main.async {
                self.checkoutURL = WebViewURL(url: url)
                completion(true)
            }
        }.resume()
    }
}

// MARK: - Safari WebView Wrapper

struct WebViewURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
