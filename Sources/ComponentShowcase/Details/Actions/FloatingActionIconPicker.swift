import SwiftUI

struct FloatingActionIconPicker: View {
    let title: String
    @Binding var selection: FloatingActionIcon

    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(FloatingActionIcon.allCases, id: \.self) { icon in
                Label(icon.title, systemImage: icon.rawValue)
                    .tag(icon)
            }
        }
        .pickerStyle(.menu)
    }
}
