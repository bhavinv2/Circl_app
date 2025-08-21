import SwiftUI
import MapKit
import Foundation
struct Page5: View {
    @State private var birthday: String = ""
    @State private var isUnderage: Bool = false
    @State private var location: String = ""
    @State private var gender: String? = nil
    @State private var availability: String? = nil
    @State private var personalityType: String = ""
    @State private var showInvalidPersonalityAlert: Bool = false
    @State private var showInvalidLocationAlert: Bool = false
    @State private var locationValidationMessage: String = ""
    @State private var isValidLocation: Bool = false
    @State private var locationSuggestions: [String] = []
    @State private var showSuggestions: Bool = false
    @State private var showIncompleteFormAlert: Bool = false
    @State private var navigateToPage13 = false
    @State private var isSubmitting: Bool = false

    let genderOptions = ["Male", "Female", "Prefer not to say"]
    let availabilityOptions = [
        "Full-time (40+ hrs/week)",
        "Part-time (20-40 hrs/week)",
        "Side project (<20 hrs/week)",
        "Weekends only",
        "Flexible hours",
        "Currently employed - exploring options"
    ]
    
    let usStates = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
                    "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
                    "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
                    "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
                    "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "004aad")
                    .edgesIgnoringSafeArea(.all)
                
                // Cloud background code remains the same...
                ZStack {
                    // Top Right Cloud Group
                    Group {
                        Circle().fill(Color.white).frame(width: 120, height: 120)
                            .offset(x: UIScreen.main.bounds.width / 2 - 80, y: -UIScreen.main.bounds.height / 2 + 0)
                        Circle().fill(Color.white).frame(width: 120, height: 120)
                            .offset(x: UIScreen.main.bounds.width / 2 - 130, y: -UIScreen.main.bounds.height / 2 + 0)
                        Circle().fill(Color.white).frame(width: 100, height: 100)
                            .offset(x: UIScreen.main.bounds.width / 2 - 30, y: -UIScreen.main.bounds.height / 2 + 40)
                        Circle().fill(Color.white).frame(width: 100, height: 100)
                            .offset(x: UIScreen.main.bounds.width / 2 - 110, y: -UIScreen.main.bounds.height / 2 + 50)
                        Circle().fill(Color.white).frame(width: 100, height: 100)
                            .offset(x: UIScreen.main.bounds.width / 2 + 170, y: -UIScreen.main.bounds.height / 2 + 30)
                        Circle().fill(Color.white).frame(width: 100, height: 100)
                            .offset(x: UIScreen.main.bounds.width / 2 + 210, y: -UIScreen.main.bounds.height / 2 + 60)
                        Circle().fill(Color.white).frame(width: 80, height: 80)
                            .offset(x: UIScreen.main.bounds.width / 2 + 90, y: -UIScreen.main.bounds.height / 2 + 50)
                        Circle().fill(Color.white).frame(width: 90, height: 90)
                            .offset(x: UIScreen.main.bounds.width / 2 + 50, y: -UIScreen.main.bounds.height / 2 + 30)
                        Circle().fill(Color.white).frame(width: 110, height: 110)
                            .offset(x: UIScreen.main.bounds.width / 2 + 150, y: -UIScreen.main.bounds.height / 2 + 80)
                    }
                    
                    // Bottom Right Cloud Group
                    Group {
                        Circle().fill(Color.white).frame(width: 120, height: 120)
                            .offset(x: UIScreen.main.bounds.width / 2 - 60, y: UIScreen.main.bounds.height / 2 - 60)
                        Circle().fill(Color.white).frame(width: 100, height: 100)
                            .offset(x: UIScreen.main.bounds.width / 2 - 30, y: UIScreen.main.bounds.height / 2 - 40)
                        Circle().fill(Color.white).frame(width: 100, height: 100)
                            .offset(x: UIScreen.main.bounds.width / 2 - 90, y: UIScreen.main.bounds.height / 2 - 50)
                        Circle().fill(Color.white).frame(width: 90, height: 90)
                            .offset(x: UIScreen.main.bounds.width / 2 - 50, y: UIScreen.main.bounds.height / 2 - 30)
                        Circle().fill(Color.white).frame(width: 90, height: 90)
                            .offset(x: UIScreen.main.bounds.width / 2 - 30, y: UIScreen.main.bounds.height / 2 - 110)
                        Circle().fill(Color.white).frame(width: 80, height: 80)
                            .offset(x: UIScreen.main.bounds.width / 2 - 135, y: UIScreen.main.bounds.height / 2 - 30)
                    }
                    
                    // Middle Left Cloud Group
                    Group {
                        Circle().fill(Color.white).frame(width: 80, height: 80)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 60, y: 2 + 50)
                        Circle().fill(Color.white).frame(width: 90, height: 90)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 40, y: -20)
                        Circle().fill(Color.white).frame(width: 80, height: 80)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 10, y: 40)
                        Circle().fill(Color.white).frame(width: 90, height: 90)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 90, y: -30)
                        Circle().fill(Color.white).frame(width: 120, height: 120)
                            .offset(x: -UIScreen.main.bounds.width / 2 + 125, y: 20)
                    }
                }
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text("Create Your Account")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "ffde59"))
                    
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                    
                    HStack {
                        Text("Personal Information")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    
                    VStack(spacing: 15) {
                        // Birthday Field
                        TextField("Birthday (MM/DD/YYYY)", text: $birthday)
                            .onChange(of: birthday) { newValue in
                                formatBirthday(newValue)
                                validateAge()
                            }
                            .textFieldStyle(RoundedTextFieldStyle())
                            .frame(maxWidth: 300)
                            .keyboardType(.numberPad)
                            .alert("You must be 18 years or older to sign up.", isPresented: $isUnderage) {
                                Button("OK", role: .cancel) { }
                            }
                        
                        // Location Field - Updated to handle spaces in city names
                        VStack(alignment: .leading) {
                            TextField("Location (City, ST)", text: $location)
                                .onChange(of: location) { newValue in
                                    validateCityState()
                                }
                                .textFieldStyle(RoundedTextFieldStyle())
                                .frame(maxWidth: 300)
                                .autocapitalization(.words)
                            
                            if !locationValidationMessage.isEmpty {
                                Text(locationValidationMessage)
                                    .font(.caption)
                                    .foregroundColor(isValidLocation ? .green : .red)
                                    .padding(.horizontal, 5)
                            }
                            
                            if showSuggestions && !locationSuggestions.isEmpty {
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 5) {
                                        ForEach(locationSuggestions, id: \.self) { suggestion in
                                            Text(suggestion)
                                                .padding(8)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color.white.opacity(0.2))
                                                .cornerRadius(5)
                                                .onTapGesture {
                                                    location = suggestion
                                                    showSuggestions = false
                                                    validateCityState()
                                                }
                                        }
                                    }
                                }
                                .frame(maxHeight: 150)
                                .background(Color(hex: "d9d9d9"))
                                .cornerRadius(10)
                            }
                        }
                        .frame(maxWidth: 300)
                        
                        DropdownField5(
                            placeholder: "Gender",
                            options: genderOptions,
                            selectedOption: $gender
                        )
                        .frame(maxWidth: 300, maxHeight: 50)
                        
                        DropdownField5(
                            placeholder: "Availability",
                            options: availabilityOptions,
                            selectedOption: $availability
                        )
                        .frame(maxWidth: 300, maxHeight: 50)
                        
                        TextField("Personality Type (XXXX-Y)", text: $personalityType)
                            .autocapitalization(.allCharacters)
                            .onChange(of: personalityType) { newValue in
                                personalityType = newValue.filter { !$0.isNumber }
                                validatePersonalityType()
                            }
                            .textFieldStyle(RoundedTextFieldStyle())
                            .frame(maxWidth: 300)
                            .alert("Invalid Personality Type format. Use XXXX-Y.", isPresented: $showInvalidPersonalityAlert) {
                                Button("OK", role: .cancel) { }
                            }
                        
                        Link("Take the 16 personalities test", destination: URL(string: "https://www.16personalities.com/")!)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "ffde59"))
                            .underline(true, color: Color(hex: "ffde59"))
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    Button(action: {
                        if isFormComplete() && isValidLocation {
                            isSubmitting = true
                            submitPersonalDetails { success in
                                if success {
                                    submitLocationToSkillsEndpoint { locationSuccess in
                                        isSubmitting = false
                                        if locationSuccess {
                                            print("✅ Birthday, personality, and location all submitted.")
                                            navigateToPage13 = true
                                        } else {
                                            showIncompleteFormAlert = true
                                        }
                                    }
                                } else {
                                    isSubmitting = false
                                    showIncompleteFormAlert = true
                                }
                            }
                        } else {
                            showIncompleteFormAlert = true
                        }
                    }) {
                        Text(isSubmitting ? "Submitting..." : "Next")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "004aad"))
                            .frame(maxWidth: 300)
                            .padding(.vertical, 15)
                            .background(isSubmitting ? Color.gray : Color(hex: "ffde59"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .padding(.horizontal, 50)
                    }
                    .disabled(!isFormComplete() || !isValidLocation || isSubmitting)
                    .opacity((isFormComplete() && isValidLocation && !isSubmitting) ? 1.0 : 0.6)
                    .alert("Please fill out all the fields.", isPresented: $showIncompleteFormAlert) {
                        Button("OK", role: .cancel) { }
                    }
                    
                    Spacer()
                }
                .navigationBarHidden(true)
            }
            .background(
                NavigationLink(
                    destination: Page13(),
                    isActive: $navigateToPage13,
                    label: { EmptyView() }
                )
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func isFormComplete() -> Bool {
        return !birthday.isEmpty &&
               isValidLocation &&
               gender != nil &&
               availability != nil
               //!personalityType.isEmpty
    }
    
    private func formatBirthday(_ newValue: String) {
        let filtered = newValue.filter { $0.isNumber }
        let limitedInput = String(filtered.prefix(8))
        
        var formatted = ""
        for (index, char) in limitedInput.enumerated() {
            if index == 2 || index == 4 {
                formatted.append("/")
            }
            formatted.append(char)
        }
        
        birthday = formatted
    }
    
    private func validateAge() {
        let numbersOnly = birthday.filter { $0.isNumber }
        
        guard numbersOnly.count == 8 else {
            isUnderage = false
            return
        }
        
        let monthString = String(numbersOnly.prefix(2))
        let dayString = String(numbersOnly.dropFirst(2).prefix(2))
        let yearString = String(numbersOnly.dropFirst(4).prefix(4))
        
        if let month = Int(monthString), month > 12 {
            birthday = String(birthday.dropLast())
            return
        }
        
        if let day = Int(dayString), day > 31 {
            birthday = String(birthday.dropLast())
            return
        }
        
        if let month = Int(monthString),
           let day = Int(dayString),
           let year = Int(yearString) {
            
            let calendar = Calendar.current
            let currentDate = Date()
            
            var dateComponents = DateComponents()
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
            
            if let birthdayDate = calendar.date(from: dateComponents) {
                let ageComponents = calendar.dateComponents([.year], from: birthdayDate, to: currentDate)
                
                if let age = ageComponents.year {
                    isUnderage = age < 18
                }
            }
        }
    }
    
    private func validateCityState() {
        guard !location.isEmpty else {
            locationValidationMessage = ""
            isValidLocation = false
            showSuggestions = false
            return
        }
        
        let parts = location.components(separatedBy: ",")
        guard parts.count == 2 else {
            locationValidationMessage = "Please enter as 'City, ST'"
            isValidLocation = false
            showSuggestions = false
            return
        }
        
        let city = parts[0].trimmingCharacters(in: .whitespaces)
        let state = parts[1].trimmingCharacters(in: .whitespaces)
        
        guard usStates.contains(state.uppercased()) else {
            locationValidationMessage = "Invalid state abbreviation"
            isValidLocation = false
            showSuggestions = false
            return
        }
        
        validateCityInState(city: city, state: state)
    }
    
    private func validateCityInState(city: String, state: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "\(city), \(state), USA"
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Location validation error: \(error.localizedDescription)")
                    self.handleInvalidCity(city: city, state: state)
                    return
                }
                
                guard let mapItems = response?.mapItems, !mapItems.isEmpty else {
                    self.handleInvalidCity(city: city, state: state)
                    return
                }
                
                // More flexible city name matching
                let exactMatches = mapItems.filter { item in
                    let itemCity = item.placemark.locality?.lowercased() ?? ""
                    let itemState = item.placemark.administrativeArea ?? ""
                    
                    return itemCity.contains(city.lowercased()) && itemState == state.uppercased()
                }
                
                if exactMatches.isEmpty {
                    self.handleInvalidCity(city: city, state: state)
                    
                    let suggestions = Array(mapItems.prefix(3)).compactMap { item -> String? in
                        guard let suggestionCity = item.placemark.locality,
                              let suggestionState = item.placemark.administrativeArea else {
                            return nil
                        }
                        return "\(suggestionCity), \(suggestionState)"
                    }
                    
                    self.locationSuggestions = suggestions
                    self.showSuggestions = !suggestions.isEmpty
                } else {
                    self.locationValidationMessage = "Valid location"
                    self.isValidLocation = true
                    self.showSuggestions = false
                }
            }
        }
    }
    
    private func handleInvalidCity(city: String, state: String) {
        locationValidationMessage = "\(city) not found in \(state). Did you mean..."
        isValidLocation = false
    }
    
    private func validatePersonalityType() {
        let sanitizedInput = personalityType.filter { $0.isUppercase }
        
        if sanitizedInput.count == 5 {
            if let dashIndex = personalityType.firstIndex(of: "-"),
               dashIndex == personalityType.index(personalityType.startIndex, offsetBy: 4) {
                let g = sanitizedInput[sanitizedInput.index(sanitizedInput.startIndex, offsetBy: 0)]
                let h = sanitizedInput[sanitizedInput.index(sanitizedInput.startIndex, offsetBy: 1)]
                let v = sanitizedInput[sanitizedInput.index(sanitizedInput.startIndex, offsetBy: 2)]
                let b = sanitizedInput[sanitizedInput.index(sanitizedInput.startIndex, offsetBy: 3)]
                let y = sanitizedInput[sanitizedInput.index(sanitizedInput.startIndex, offsetBy: 4)]
                
                let validG = ["E", "I"].contains(g)
                let validH = ["S", "N"].contains(h)
                let validV = ["T", "F"].contains(v)
                let validB = ["J", "P"].contains(b)
                let validY = ["A", "T"].contains(y)
                
                if !(validG && validH && validV && validB && validY) {
                    showInvalidPersonalityAlert = true
                }
            } else {
                showInvalidPersonalityAlert = true
            }
        } else {
            showInvalidPersonalityAlert = false
        }
    }
    
    func submitPersonalDetails(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://circlapp.online/api/users/update-personal-details/") else {
            print("❌ Invalid API URL")
            completion(false)
            return
        }

        let userId = UserDefaults.standard.integer(forKey: "user_id")

        if userId == 0 {
            print("❌ User ID not found. Make sure you completed registration on Page 3.")
            completion(false)
            return
        }

        let payload: [String: Any] = [
            "user_id": userId,
            "birthday": formatDateString(birthday),
            "personality_type": personalityType
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            print("❌ Failed to encode data")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Request Error: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Response Status Code: \(httpResponse.statusCode)")
                    completion(httpResponse.statusCode == 200)
                }

                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("📩 Response Body: \(responseString)")
                }
            }
        }
        task.resume()
    }
    
    func submitLocationToSkillsEndpoint(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://circlapp.online/api/users/update-skills-interests/") else {
            print("❌ Invalid API URL for skills/interests")
            completion(false)
            return
        }

        let userId = UserDefaults.standard.integer(forKey: "user_id")
        if userId == 0 {
            print("❌ User ID not found.")
            completion(false)
            return
        }

        let payload: [String: Any] = [
            "user_id": userId,
            "locations": [location.trimmingCharacters(in: .whitespaces)]
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: payload),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("🚀 Sending location to skills endpoint: \(jsonString)")
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            print("❌ Failed to encode location payload")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Location POST Error: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Location POST Status: \(httpResponse.statusCode)")
                    completion(httpResponse.statusCode == 200)
                }

                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("📩 Location Response Body: \(responseString)")
                }
            }
        }.resume()
    }
}

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(15)
            .background(Color(hex: "d9d9d9"))
            .cornerRadius(10)
            .font(.system(size: 20))
            .foregroundColor(Color(hex: "004aad"))
    }
}

struct DropdownField5: View {
    var placeholder: String
    var options: [String]
    @Binding var selectedOption: String?

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) {
                    selectedOption = option
                }
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "d9d9d9"))
                    .frame(height: 50)

                HStack {
                    Text(selectedOption ?? placeholder)
                        .foregroundColor(
                            selectedOption == nil ?
                                Color(hex: "004aad").opacity(0.6) :
                                Color(hex: "004aad")
                        )
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color(hex: "004aad"))
                }
                .padding(.horizontal, 15)
            }
        }
    }
}

func formatDateString(_ input: String) -> String {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "MMddyyyy" // input format: MM/DD/YYYY (numbers only)

    let raw = input.filter { $0.isNumber }
    if let date = inputFormatter.date(from: raw) {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"
        return outputFormatter.string(from: date)
    }

    return ""
}



struct Page5_Previews: PreviewProvider {
    static var previews: some View {
        Page5()
    }
}
