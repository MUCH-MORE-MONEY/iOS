//
//  RadioButton.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/16/24.
//

import SwiftUI

struct RadioButton: View {

    @Environment(\.colorScheme) var colorScheme

    let id: String
    let callback: (String)->()
    let selectedID : String

    var isSelected: Bool {
        get {
            return selectedID == id
        }
    }
    
    init(_ id: String, callback: @escaping (String)->(), selectedID: String) {
        self.id = id
        self.selectedID = selectedID
        self.callback = callback
    }
    
    var body: some View {
        Button {
            callback(self.id)
        } label: {
            HStack(alignment: .center, spacing: 8) {
                
                Image(uiImage: (isSelected ? R.Icon.iconRadiobuttonActive : R.Icon.iconRadiobuttonEnable) ?? UIImage())
                Text(id)
                    .font(Font(isSelected ? R.Font.medium1 : R.Font.body0))
                    .foregroundStyle(Color(isSelected ? R.Color.gray800 : R.Color.gray600))
                Spacer()
            }
        }
        .animation(nil)
        .padding([.top, .bottom], 11)
    }
}

struct RadioButtonGroup: View {
    let items: [String]
    @State var selectedId: String = ""
    let callback: (String) -> ()
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(items, id: \.self) { id in
                RadioButton(id, callback: radioGroupCallback, selectedID: selectedId)
                    .padding(0)
            }
        }
    }
    
    func radioGroupCallback(id: String) {
        selectedId = id
        callback(id)
    }
}
