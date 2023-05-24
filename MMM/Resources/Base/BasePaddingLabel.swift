//
//  BasePaddingLabel.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/08.
//

import UIKit

class BasePaddingLabel: UILabel {
    private var padding = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
    
    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.padding = padding
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right
        
        return contentSize
    }
}

extension BasePaddingLabel {
    func setSatisfyingLabel(by star: Int) {
        switch star {
        case 0:
            self.isHidden = true
        case 1:
            self.text = "아쉬워요"
        case 2:
            self.text = "그저그래요"
        case 3:
            self.text = "괜찮아요"
        case 4:
            self.text = "만족해요"
        case 5:
            self.text = "완전 만족해요"
        default:
            break
        }
    }
    
    func setSatisfyingLabelEdit(by star: Int) {
        switch star {
        case 0:
            self.text = "별점이 비어있어요"
        case 1:
            self.text = "아쉬워요"
        case 2:
            self.text = "그저그래요"
        case 3:
            self.text = "괜찮아요"
        case 4:
            self.text = "만족해요"
        case 5:
            self.text = "완전 만족해요"
        default:
            break
        }
    }
}
