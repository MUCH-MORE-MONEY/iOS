//
//  BudgetSettingView.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/20/24.
//

import SwiftUI

struct BudgetSettingView: View {
    var body: some View {
        VStack {
            SegmentedView()
                .padding(.top, 16)
                .padding([.leading, .trailing], 24)
            Spacer()
        }
        .background(Color(R.Color.gray900))
    }
}

#Preview {
    BudgetSettingView()
}

struct SegmentedView: View {

    let segments: [String] = ["OPEN", "COMPLETED", "CANCELLED", "ALL", "Last"]
    @State private var selected: String = "OPEN"
    @Namespace var name

    var body: some View {
        HStack(spacing: 0) {
            ForEach(segments, id: \.self) { segment in
                Button {
                    selected = segment
                } label: {
                    VStack {
                        ZStack {
                            Capsule()
                                .fill(Color(R.Color.gray600))
                                .frame(height: 2)
                            if selected == segment {
                                Capsule()
                                    .fill(selected == segment ? Color(R.Color.white) : Color(R.Color.gray600))
                                    .frame(height: 2)
                                    .matchedGeometryEffect(id: "Tab", in: name)
                            }
                        }
                        .padding([.leading, .trailing], 1)
                    }
                }
            }
        }
    }
}

final class BudgetSettingHostingController: UIHostingController<BudgetSettingView> {
    override func viewDidLoad() {
        
    }
}

final class BudgetSettingViewInterface {
    func budgetSettingViewUI() -> UIViewController {
        let vc = BudgetSettingHostingController(rootView: BudgetSettingView())
        return vc
    }
}
