import SwiftUI

struct Page19: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer() // Moves content down slightly
            
            Text("Thank You for Signing Up!")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .foregroundColor(Color.white)
            
            Text("Your account is now awaiting approval. Once approved, you will receive an email with your login credentials.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(Color.white)
            
            Text("You can close the app now.")
                .font(.headline)
                .foregroundColor(.gray)
            
            Spacer() // Centers content vertically by balancing space
            
            
            .padding(.bottom, 20)
        }
        .padding()
        .background(Color.fromHex("004aad")) // Blue color
        .cornerRadius(20)
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
    }
}

struct Page19_Previews: PreviewProvider {
    static var previews: some View {
        Page19()
    }
}


