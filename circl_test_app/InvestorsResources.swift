import SwiftUI

struct InvestorsResources: View {
    var body: some View {
        VStack {
            Text("Investors Resources Page")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding()
            
            Spacer()
        }
    }
}

struct InvestorsResources_Previews: PreviewProvider {
    static var previews: some View {
        InvestorsResources()
    }
}
