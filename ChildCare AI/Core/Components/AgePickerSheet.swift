import SwiftUI

public struct AgePickerSheet: View {
    public let title: String
    @Binding public var selection: String
    public let options: [String]
    public let onDone: () -> Void
    
    public init(title: String, selection: Binding<String>, options: [String], onDone: @escaping () -> Void) {
        self.title = title
        self._selection = selection
        self.options = options
        self.onDone = onDone
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
                .padding(.top)
            
            Picker(title, selection: $selection) {
                if selection.isEmpty {
                    Text("Select Age").tag("")
                }
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            
            Button(action: onDone) {
                Text("Done")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .presentationDetents([.height(350)])
        .onAppear {
            if selection.isEmpty {
                selection = options[0]
            }
        }
    }
}
