import SwiftUI

struct EditBusinessProfileView: View {
    @ObservedObject var viewModel: BusinessProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @AppStorage("user_id") private var userId: Int = 0

    // Core
    @State private var businessName: String = ""
    @State private var about: String = ""
    @State private var industry: String = ""
    @State private var type: String = ""
    @State private var stage: String = ""
    @State private var revenue: String = ""
    @State private var location: String = ""
    @State private var lookingFor: String = ""

    // Values
    @State private var vision: String = ""
    @State private var mission: String = ""
    @State private var companyCulture: String = ""

    // Solution
    @State private var productService: String = ""
    @State private var usp: String = ""
    @State private var traction: String = ""

    // Business model
    @State private var revenueStreams: String = ""
    @State private var pricingStrategy: String = ""

    // Team
    @State private var cofounders: String = ""
    @State private var keyHires: String = ""
    @State private var advisorsMentors: String = ""

    // Financials
    @State private var fundingStage: String = ""
    @State private var amountRaised: String = ""
    @State private var useOfFunds: String = ""
    @State private var financialProjections: String = ""

    // Looking for
    @State private var rolesNeeded: String = ""
    @State private var mentorship: String = ""
    @State private var investment: String = ""
    @State private var other: String = ""

    @State private var isSaving: Bool = false
    @State private var saveFailedMessage: String? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    SectionHeader(title: "Business Basics")
                    Group {
                        TextFieldRow(title: "Business Name", text: $businessName)
                        TextEditorRow(title: "About", text: $about)
                        TextFieldRow(title: "Industry", text: $industry)
                        TextFieldRow(title: "Type", text: $type)
                        TextFieldRow(title: "Stage", text: $stage)
                        TextFieldRow(title: "Revenue", text: $revenue)
                        TextFieldRow(title: "Location", text: $location)
                        TextFieldRow(title: "Looking For", text: $lookingFor)
                    }

                    SectionHeader(title: "Values")
                    Group {
                        TextEditorRow(title: "Vision", text: $vision)
                        TextEditorRow(title: "Mission", text: $mission)
                        TextEditorRow(title: "Company Culture", text: $companyCulture)
                    }

                    SectionHeader(title: "Solution")
                    Group {
                        TextEditorRow(title: "Product / Service", text: $productService)
                        TextEditorRow(title: "Unique Selling Proposition", text: $usp)
                        TextEditorRow(title: "Traction / Progress", text: $traction)
                    }

                    SectionHeader(title: "Business Model")
                    Group {
                        TextEditorRow(title: "Revenue Streams", text: $revenueStreams)
                        TextEditorRow(title: "Pricing Strategy", text: $pricingStrategy)
                    }

                    SectionHeader(title: "Team")
                    Group {
                        TextEditorRow(title: "Co-Founders", text: $cofounders)
                        TextEditorRow(title: "Key Hires", text: $keyHires)
                        TextEditorRow(title: "Advisors / Mentors", text: $advisorsMentors)
                    }

                    SectionHeader(title: "Financials")
                    Group {
                        TextFieldRow(title: "Funding Stage", text: $fundingStage)
                        TextFieldRow(title: "Amount Raised", text: $amountRaised)
                        TextEditorRow(title: "Use of Funds", text: $useOfFunds)
                        TextEditorRow(title: "Financial Projections", text: $financialProjections)
                    }

                    SectionHeader(title: "Opportunities")
                    Group {
                        TextEditorRow(title: "Roles Needed", text: $rolesNeeded)
                        TextEditorRow(title: "Mentorship", text: $mentorship)
                        TextEditorRow(title: "Investment", text: $investment)
                        TextEditorRow(title: "Other", text: $other)
                    }

                    Button(action: save) {
                        HStack {
                            if isSaving { ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)) }
                            Text(isSaving ? "Saving..." : "Save Changes")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "004aad"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isSaving)

                    if let message = saveFailedMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
                .padding(16)
            }
            .navigationTitle("Edit Business Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { loadFromViewModel() }
        }
    }

    private func loadFromViewModel() {
        guard let p = viewModel.profile else { return }
        businessName = p.business_name ?? ""
        about = p.about ?? ""
        vision = p.vision ?? ""
        mission = p.mission ?? ""
        companyCulture = p.company_culture ?? ""
        productService = p.product_service ?? ""
        traction = p.traction ?? ""
        usp = p.unique_selling_proposition ?? ""
        revenueStreams = p.revenue_streams ?? ""
        advisorsMentors = p.advisors_mentors ?? ""
        cofounders = p.cofounders ?? ""
        keyHires = p.key_hires ?? ""
        amountRaised = p.amount_raised ?? ""
        financialProjections = p.financial_projections ?? ""
        fundingStage = p.funding_stage ?? ""
        useOfFunds = p.use_of_funds ?? ""
        investment = p.investment ?? ""
        mentorship = p.mentorship ?? ""
        other = p.other ?? ""
        rolesNeeded = p.roles_needed ?? ""
        pricingStrategy = p.pricing_strategy ?? ""
        industry = p.industry ?? ""
        type = p.type ?? ""
        stage = p.stage ?? ""
        revenue = p.revenue ?? ""
        location = p.location ?? ""
        lookingFor = p.looking_for ?? ""
    }

    private func save() {
        var effectiveUserId = userId
        if effectiveUserId == 0 {
            // Fallbacks in case AppStorage hasn't populated yet
            effectiveUserId = UserDefaults.standard.integer(forKey: "user_id")
            if effectiveUserId == 0 { effectiveUserId = viewModel.profile?.user ?? 0 }
        }
        guard effectiveUserId != 0 else { saveFailedMessage = "Missing user id"; return }
        isSaving = true
        saveFailedMessage = nil

        var payload: [String: Any] = [:]
        func set(_ key: String, _ value: String) { if !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { payload[key] = value } }
        set("business_name", businessName)
        set("about", about)
        set("vision", vision)
        set("mission", mission)
        set("company_culture", companyCulture)
        set("product_service", productService)
        set("traction", traction)
        set("unique_selling_proposition", usp)
        set("revenue_streams", revenueStreams)
        set("advisors_mentors", advisorsMentors)
        set("cofounders", cofounders)
        set("key_hires", keyHires)
        set("amount_raised", amountRaised)
        set("financial_projections", financialProjections)
        set("funding_stage", fundingStage)
        set("use_of_funds", useOfFunds)
        set("investment", investment)
        set("mentorship", mentorship)
        set("other", other)
        set("roles_needed", rolesNeeded)
        set("pricing_strategy", pricingStrategy)
        set("industry", industry)
        set("type", type)
        set("stage", stage)
        set("revenue", revenue)
        set("location", location)
        set("looking_for", lookingFor)

        viewModel.updateProfile(for: effectiveUserId, with: payload) { success, log in
            isSaving = false
            if success {
                dismiss()
            } else {
                saveFailedMessage = "Failed to save changes. Please try again.\n\n\(log)"
            }
        }
    }
}

private struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.top, 8)
    }
}

private struct TextFieldRow: View {
    let title: String
    @Binding var text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.footnote).foregroundColor(.secondary)
            TextField(title, text: $text)
                .textFieldStyle(.roundedBorder)
        }
    }
}

private struct TextEditorRow: View {
    let title: String
    @Binding var text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.footnote).foregroundColor(.secondary)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(UIColor.separator))
                TextEditor(text: $text)
                    .frame(minHeight: 80)
                    .padding(8)
            }
        }
    }
}
