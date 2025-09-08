import SwiftUI
import AVFoundation
import CoreLocation
import AudioToolbox

// Use baseURL from APIConfig.swift

// MARK: - QR Scanner Models
struct QRCheckInRequest: Codable {
    let qr_code: String
    let user_id: Int
    let latitude: Double?
    let longitude: Double?
}

struct QRCheckInResponse: Codable {
    let message: String
    let checkin: CheckInData?
    let points_earned: Int
    let event_title: String
    let error: String?
    let requires_location: Bool?
    let event_location: EventLocationData?
}

struct CheckInData: Codable {
    let id: Int
    let user: Int
    let event: Int
    let timestamp: String
    let points_earned: Int
    let check_in_method: String
}

struct EventLocationData: Codable {
    let latitude: Double
    let longitude: Double
    let radius: Int
}

// MARK: - QR Scanner View
struct QRScannerView: View {
    @Binding var isPresented: Bool
    @AppStorage("user_id") private var userId: Int = 0
    @State private var isScanning = false
    @State private var scannedCode: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var isCheckingIn = false
    @State private var requiresLocation = false
    @State private var locationManager = LocationManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                if isScanning {
                    QRCodeScannerRepresentable { code in
                        handleScannedCode(code)
                    }
                    
                    // Scanning overlay
                    VStack {
                        Text("Scan QR Code")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                        
                        Spacer()
                        
                        VStack(spacing: 20) {
                            if isCheckingIn {
                                VStack(spacing: 12) {
                                    ProgressView()
                                        .scaleEffect(1.5)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    
                                    Text("Checking you in...")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                .padding(20)
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(15)
                            }
                            
                            Text("Position the QR code within the frame")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.bottom, 100)
                    }
                } else {
                    // Permission or error state
                    VStack(spacing: 20) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Camera Access Required")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Please allow camera access to scan QR codes for event check-ins.")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button("Enable Camera") {
                            requestCameraPermission()
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color(hex: "004aad"))
                        .cornerRadius(10)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(.white)
            )
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertTitle == "Success!" {
                        isPresented = false
                    }
                }
            )
        }
        .onAppear {
            requestCameraPermission()
            locationManager.requestPermission()
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                isScanning = granted
            }
        }
    }
    
    private func handleScannedCode(_ code: String) {
        guard !isCheckingIn else { return }
        
        scannedCode = code
        
        // Extract QR code from URL if needed
        let qrCode = extractQRCode(from: code)
        
        // Check if we have location permission and get current location
        if locationManager.hasPermission {
            locationManager.getCurrentLocation { location in
                checkInWithQR(qrCode: qrCode, location: location)
            }
        } else {
            checkInWithQR(qrCode: qrCode, location: nil)
        }
    }
    
    private func extractQRCode(from scannedString: String) -> String {
        // Handle custom URL scheme: circl://event/checkin/{qr_code}
        if scannedString.hasPrefix("circl://event/checkin/") {
            return String(scannedString.dropFirst("circl://event/checkin/".count))
        }
        // If it's just the QR code directly
        return scannedString
    }
    
    private func checkInWithQR(qrCode: String, location: CLLocation?) {
        isCheckingIn = true
        
        guard let url = URL(string: "\(baseURL)circles/qr_checkin/") else {
            showError("Invalid API URL")
            return
        }
        
        let request = QRCheckInRequest(
            qr_code: qrCode,
            user_id: userId,
            latitude: location?.coordinate.latitude,
            longitude: location?.coordinate.longitude
        )
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            showError("Failed to prepare request")
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                isCheckingIn = false
                
                if let error = error {
                    showError("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    showError("No response data")
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(QRCheckInResponse.self, from: data)
                    
                    if let error = response.error {
                        if response.requires_location == true {
                            handleLocationRequired(error: error, eventLocation: response.event_location)
                        } else {
                            showError(error)
                        }
                    } else {
                        showSuccess(
                            title: "Success!",
                            message: "✅ \(response.message)\n\n🎉 You earned \(response.points_earned) points for attending \(response.event_title)!"
                        )
                    }
                } catch {
                    // Try to parse error response
                    if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorMessage = errorData["error"] as? String {
                        showError(errorMessage)
                    } else {
                        showError("Failed to process response")
                    }
                }
            }
        }.resume()
    }
    
    private func handleLocationRequired(error: String, eventLocation: EventLocationData?) {
        if let eventLocation = eventLocation {
            showError("\(error)\n\nEvent Location:\nLat: \(eventLocation.latitude)\nLng: \(eventLocation.longitude)\nRadius: \(eventLocation.radius)m")
        } else {
            showError(error)
        }
    }
    
    private func showError(_ message: String) {
        alertTitle = "Check-in Failed"
        alertMessage = message
        showAlert = true
    }
    
    private func showSuccess(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var hasPermission = false
    @Published var currentLocation: CLLocation?
    
    private var locationCallback: ((CLLocation?) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        checkPermission()
    }
    
    func requestPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            hasPermission = false
        case .authorizedWhenInUse, .authorizedAlways:
            hasPermission = true
        @unknown default:
            hasPermission = false
        }
    }
    
    private func checkPermission() {
        hasPermission = locationManager.authorizationStatus == .authorizedWhenInUse || 
                       locationManager.authorizationStatus == .authorizedAlways
    }
    
    func getCurrentLocation(completion: @escaping (CLLocation?) -> Void) {
        locationCallback = completion
        
        guard hasPermission else {
            completion(nil)
            return
        }
        
        locationManager.requestLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        locationCallback?(locations.last)
        locationCallback = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        locationCallback?(nil)
        locationCallback = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkPermission()
    }
}

// MARK: - QR Code Scanner Representable
struct QRCodeScannerRepresentable: UIViewControllerRepresentable {
    let onCodeScanned: (String) -> Void
    
    func makeUIViewController(context: Context) -> QRCodeScannerViewController {
        let scanner = QRCodeScannerViewController()
        scanner.onCodeScanned = onCodeScanned
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: QRCodeScannerViewController, context: Context) {}
}

// MARK: - QR Code Scanner View Controller
class QRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCodeScanned: ((String) -> Void)?
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            onCodeScanned?(stringValue)
        }
    }
}

// Use Color(hex:) from ColorExtensions.swift

// MARK: - Preview
struct QRScannerView_Previews: PreviewProvider {
    static var previews: some View {
        QRScannerView(isPresented: .constant(true))
    }
}
