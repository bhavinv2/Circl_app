import SwiftUI
import MapKit

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
        ZStack {
            Color(hexCode: "004aad")
                .edgesIgnoringSafeArea(.all)
            
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
                    .foregroundColor(Color(hexCode: "ffde59"))
                
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
                    
                    // Location Field
                    VStack(alignment: .leading) {
                        TextField("Location (City, ST)", text: $location)
                            .onChange(of: location) { newValue in
                                formatLocation(newValue)
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
                                            }
                                    }
                                }
                            }
                            .frame(maxHeight: 150)
                            .background(Color(hexCode: "d9d9d9"))
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
                        .foregroundColor(Color(hexCode: "ffde59"))
                        .underline(true, color: Color(hexCode: "ffde59"))
                        .padding(.top, 8)
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)
                
                Spacer()
                
                NavigationLink(destination: Page10()) {
                    Text("Next")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hexCode: "004aad"))
                        .frame(maxWidth: 300)
                        .padding(.vertical, 15)
                        .background(Color(hexCode: "ffde59"))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .padding(.horizontal, 50)
                }
                .disabled(!isFormComplete())
                .opacity(isFormComplete() ? 1.0 : 0.6)
                .alert("Please fill out all the fields.", isPresented: $showIncompleteFormAlert) {
                    Button("OK", role: .cancel) { }
                }
                .onTapGesture {
                    if !isFormComplete() {
                        showIncompleteFormAlert = true
                    }
                }
                .disabled(!isValidLocation)
                .opacity(isValidLocation ? 1.0 : 0.6)
                
                Spacer()
            }
        }
    }
    
    private func isFormComplete() -> Bool {
        return !birthday.isEmpty &&
               isValidLocation &&
               gender != nil &&
               availability != nil &&
               !personalityType.isEmpty
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
    
    private func formatLocation(_ newValue: String) {
        let parts = newValue.components(separatedBy: ",")
        
        if parts.count == 1 {
            let city = parts[0].trimmingCharacters(in: .whitespaces)
            if !city.isEmpty {
                let capitalizedCity = city.prefix(1).capitalized + city.dropFirst()
                location = capitalizedCity
            }
        } else if parts.count == 2 {
            let city = parts[0].trimmingCharacters(in: .whitespaces)
            var state = parts[1].trimmingCharacters(in: .whitespaces)
            
            let capitalizedCity = city.isEmpty ? "" : city.prefix(1).capitalized + city.dropFirst()
            state = String(state.prefix(2)).uppercased()
            
            location = "\(capitalizedCity), \(state)"
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
                
                let exactMatches = mapItems.filter { item in
                    let itemCity = item.placemark.locality?.lowercased() ?? ""
                    let itemState = item.placemark.administrativeArea ?? ""
                    
                    return itemCity == city.lowercased() && itemState == state.uppercased()
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
}

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(15)
            .background(Color(hexCode: "d9d9d9"))
            .cornerRadius(10)
            .font(.system(size: 20))
            .foregroundColor(Color(hexCode: "004aad"))
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
                    .fill(Color(hexCode: "d9d9d9"))
                    .frame(height: 50)

                HStack {
                    Text(selectedOption ?? placeholder)
                        .foregroundColor(
                            selectedOption == nil ?
                                Color(hexCode: "004aad").opacity(0.6) :
                                Color(hexCode: "004aad")
                        )
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color(hexCode: "004aad"))
                }
                .padding(.horizontal, 15)
            }
        }
    }
}

extension Color {
    init(hexCode2: String) {
        let scanner = Scanner(string: hexCode2)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

struct Page5_Previews: PreviewProvider {
    static var previews: some View {
        Page5()
    }
}
