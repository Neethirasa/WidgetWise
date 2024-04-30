//
//  tempWidgetCustom.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-26.
//

import SwiftUI
import WidgetKit

class tempTextFieldSettingsViewModel: ObservableObject {
    @Published var textFieldColor: Color = .black {
        didSet { saveColor(textFieldColor, forKey: "textFieldColor") }
    }
    @Published var textColor: Color = .white {
        didSet { saveColor(textColor, forKey: "textColor") }
    }
    @Published var selectedFont: String = "System" {
        didSet { saveFontSelection(fontName: selectedFont) }
    }
    
    @Published var selectedFontSize: CGFloat = 14 {
            didSet { saveFontSizeSelection(fontSize: selectedFontSize) }
        }

    init() {
        loadSavedColors()
        loadSavedFont()
        loadSavedFontSize()
    }
    
    private func saveFontSizeSelection(fontSize: CGFloat) {
            UserDefaults(suiteName: "group.Nivethikan-Neethirasa.InspireSync")?.set(Double(fontSize), forKey: "selectedFontSize")
        }

        private func loadSavedFontSize() {
            if let savedFontSize = UserDefaults(suiteName: "group.Nivethikan-Neethirasa.InspireSync")?.double(forKey: "selectedFontSize") {
                selectedFontSize = CGFloat(savedFontSize)
            }
        }

    private func saveColor(_ color: Color, forKey key: String) {
        guard let defaults = UserDefaults(suiteName: "group.Nivethikan-Neethirasa.InspireSync") else { return }
        do {
            let uiColor = UIColor(color)
            let colorData = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
            defaults.set(colorData, forKey: key)
        } catch {
            print("Failed to save color")
        }
    }

    private func saveFontSelection(fontName: String) {
        UserDefaults(suiteName: "group.Nivethikan-Neethirasa.InspireSync")?.set(fontName, forKey: "selectedFont")
    }

    func loadSavedColors() {
        textFieldColor = loadColor(forKey: "textFieldColor") ?? .black
        textColor = loadColor(forKey: "textColor") ?? .white
    }
    
    func loadSavedFont() {
        if let savedFont = UserDefaults(suiteName: "group.Nivethikan-Neethirasa.InspireSync")?.string(forKey: "selectedFont") {
            selectedFont = savedFont
        }
    }

    private func loadColor(forKey key: String) -> Color? {
        guard let defaults = UserDefaults(suiteName: "group.Nivethikan-Neethirasa.InspireSync"),
              let colorData = defaults.data(forKey: key),
              let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) else { return nil }
        return Color(uiColor)
    }
}

struct tempWidgetCustom: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = tempTextFieldSettingsViewModel()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var sampleText: String = "Success is not measured by what you accomplish, but by the obstacles you overcome."
    let fonts = ["Futura-Medium", "San Francisco", "Helvetica Neue", "Arial", "Times New Roman", "Courier New", "Georgia", "Trebuchet MS", "Verdana", "Gill Sans", "Avenir Next", "Baskerville", "Didot", "American Typewriter", "Chalkboard SE"]
    
    var body: some View {
        ZStack {
            Color("WashedBlack").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                TextField("Sample", text: $sampleText, axis: .vertical)
                    .multilineTextAlignment(.center)
                    .font(.custom(viewModel.selectedFont, size: viewModel.selectedFontSize))
                    .frame(width: textFieldWidth, height: 150)
                    .padding()
                    .background(viewModel.textFieldColor)
                    .foregroundColor(viewModel.textColor)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                    
                
                formContent
                
                actionButtons
            }
            .padding()
        }
    }
    
    private var formContent: some View {
        Form {
            Section(header: Text("Customize").foregroundColor(.white)) {
                ColorPicker("Widget Color", selection: $viewModel.textFieldColor).foregroundStyle(.white).font(.custom(
                    "Futura-Medium",
                    fixedSize: 14))
                ColorPicker("Text Color", selection: $viewModel.textColor).foregroundStyle(.white).font(.custom(
                    "Futura-Medium",
                    fixedSize: 14))
                
                Picker("Font", selection: $viewModel.selectedFont) {
                    ForEach(fonts, id: \.self) { font in
                        Text(font).tag(font)
                            .foregroundColor(.white)
                            .font(.custom(
                                font,
                                fixedSize: 16))
                    }
                }
                .pickerStyle(.wheel)
                .background(Color("WashedBlack"))
                
                Slider(value: $viewModel.selectedFontSize, in: 8...28, step: 1)
                Text("Font Size: \(Int(viewModel.selectedFontSize))")
                    .foregroundStyle(.white)
                    .font(.custom(
                        "Futura-Medium",
                        fixedSize: 14))
            }
            .listRowBackground(Color("WashedBlack"))
        }
        .onAppear {
            UITableView.appearance().backgroundColor = .clear
        }
    }
    
    private var actionButtons: some View {
        HStack {
            Button(role: .destructive){
              dismiss()
            }label: {
            Text("Cancel")
          }
            .font(.custom(
                    "Futura-Medium",
                    fixedSize: 20))
        Spacer().frame(width: UIScreen.main.bounds.width * 0.45)
            
            Button(){
                WidgetCenter.shared.reloadAllTimelines()
                dismiss()
                
            }label: {
            Text("Done")
          }
            .font(.custom(
                    "Futura-Medium",
                    fixedSize: 20))
        }
        .padding(.horizontal,40)
    }
    
    // Adjust width based on device orientation and type
    private var textFieldWidth: CGFloat {
        horizontalSizeClass == .compact ? UIScreen.main.bounds.width * 0.9 : UIScreen.main.bounds.width * 0.5
    }
}

struct tempWidgetCustom_Previews: PreviewProvider {
    static var previews: some View {
        tempWidgetCustom()
    }
}

