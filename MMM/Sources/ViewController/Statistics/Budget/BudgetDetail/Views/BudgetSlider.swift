//
//  BudgetSlider.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/23/24.
//

import SwiftUI
import CoreHaptics

struct BudgetSlider: View {
    @Binding var value: Double // 슬라이더의 현재 값
    var range: ClosedRange<Double> // 슬라이더의 범위
    var step: Double = 5.0 // 슬라이더의 단위 변경
    let divisions: Int = 4 // 5개의 구간을 만들기 위한 나눔 수 (0을 포함하여 총 5개)
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 전체 슬라이더의 트랙
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .cornerRadius(4)
                // 사용자가 선택한 값에 따라 변경되는 부분을 표시하는 Rectangle (주황색)
                Rectangle()
                    .fill(Color(R.Color.orange500))
                    .frame(width: self.normalizedValue(in: geometry.size.width), height: 4)
                    .cornerRadius(4)
                
                // 마커
                ForEach(0...divisions, id: \.self) { division in
                    Circle()
                        .fill(Color(R.Color.white))
                        .frame(width: 4, height: 4)
                        .offset(x: CGFloat(division) / CGFloat(divisions) * geometry.size.width, y: 0)
                }
                
                // 슬라이더의 현재 값에 따른 핸들 위치
                ZStack {
                    Circle()
                        .fill(Color(R.Color.white))
                        .frame(width: 20, height: 20)
                    Circle()
                        .fill(Color(R.Color.white))
                        .frame(width: 40, height: 40)
                        .opacity(0.2)
                }
                .offset(x: self.normalizedValue(in: geometry.size.width) - 20)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            self.updateValue(from: gesture, width: geometry.size.width)
                        }
                )
            }
        }
        .frame(height: 44)
    }

    // 슬라이더 값의 변경을 처리하는 메소드
    private func updateValue(from gesture: DragGesture.Value, width: CGFloat) {
        let dragValue = max(0, min(Double(gesture.location.x / width), 1))
        let newValue = dragValue * (range.upperBound - range.lowerBound) + range.lowerBound
        let roundedValue = round(newValue / step) * step
        
        if roundedValue != value {
            value = roundedValue
            // 햅틱 기능 추가
            self.hapticFeedback.impactOccurred()
        }

    }

    // 현재 값에 따른 핸들의 위치를 계산하는 메소드
    private func normalizedValue(in width: CGFloat) -> CGFloat {
        CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * width
    }
}

struct BudgetSlider_Previews: PreviewProvider {
    @State static var value = 5.0
    
  static var previews: some View {
      BudgetSlider(value: $value, range: 0...100, step: 5)
          .background(Color(R.Color.gray900))
  }
}

