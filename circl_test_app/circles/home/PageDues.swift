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
        VStack(spacing: 24) {
            // Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(hex: "004aad"))
                }
                Spacer()
                Text("Circle Dues")
                    .font(.headline)
                Spacer()
                Color.clear.frame(width: 24)
            }
            .padding()

            if isLoading {
                ProgressView("Loading dues info...")
            } else {
                if let dues = duesAmount {
                    Text("Current dues: $\(Double(dues) / 100, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.semibold)

                    if isModerator {
                        TextField("Update dues ($)", text: $newDuesAmount)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)

                        Button("Update Dues") {
                            updateDues()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "004aad"))
                        .foregroundColor(.white)
                        .cornerRadius(10)

                        if hasStripeAccount {
                            Button("Edit Stripe Info") {
                                createStripeAccount()
                            }
                            .padding(.top, 4)
                            .foregroundColor(.blue)
                        }

                    } else {
                        Button("Pay Now") {
                            startCheckout()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                } else {
                    VStack(spacing: 16) {
                        Text("Dues not set yet.")
                            .foregroundColor(.secondary)

                        if isModerator {
                            if hasStripeAccount {

                                TextField("Enter dues ($)", text: $newDuesAmount)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(10)

                                Button("Update Dues") {
                                    updateDues()
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "004aad"))
                                .foregroundColor(.white)
                                .cornerRadius(10)

                                if hasStripeAccount {
                                    Button("Edit Stripe Info") {
                                        createStripeAccount()
                                    }
                                    .padding(.top, 4)
                                    .foregroundColor(.blue)
                                }

                            } else {
                                Button("Set Up Stripe") {
                                    createStripeAccount()
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "004aad"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        } else {
                            Text("Waiting for dues setup by moderators.")
                                .foregroundColor(.secondary)
                        }

                    }
                }

            }

            Spacer()
        }
        .padding()
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
