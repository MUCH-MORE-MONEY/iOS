//
//  Ex+View.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/19/24.
//

import SwiftUI

// Custom Half Sheet Modifier
extension View {
    // Binding Show Variable
    func halfSheet<SheetView: View>(showSheet: Binding<Bool>, @ViewBuilder sheetView: @escaping () -> SheetView, onEnd: @escaping () -> () = {}) -> some View {
        
        // why we using overlay
        // bcz it will automatically user the SwiftUI frame size only
        return self
            .background {
                HalfSheetHelper(sheetView: sheetView(), showSheet: showSheet, onEnd: onEnd)
            }
    }
    
    func navigationTransition(start insertion: Edge, to removal: Edge) -> some View {
        self.transition(.asymmetric(insertion: .move(edge: insertion), removal: .move(edge: removal)))
    }
}

// UIKit Integration
struct HalfSheetHelper<SheetView: View>: UIViewControllerRepresentable {
    var sheetView: SheetView
    @Binding var showSheet: Bool
    var onEnd: () -> ()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    let controller = UIViewController()
    func makeUIViewController(context: Context) -> some UIViewController {
        controller.view.backgroundColor = .clear
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        let sheetController = CustomHostingController(rootView: sheetView)
        sheetController.presentationController?.delegate = context.coordinator
        if showSheet {
            // presenting Modal View
            uiViewController.present(sheetController, animated: true)
        } else {
            // closing view when showSheet toggled again
            sheetController.dismiss(animated: true)
        }
    }
    
    class Coordinator: NSObject, UISheetPresentationControllerDelegate {
        var parent: HalfSheetHelper
        
        init(parent: HalfSheetHelper) {
            self.parent = parent
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.showSheet = false
            parent.onEnd()
        }
    }
}

// Custom UIHostingController for halfSheet
final class CustomHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidLoad() {
        
        var detents: [UISheetPresentationController.Detent] = []
        
        if #available(iOS 16.0, *) {
            detents = [.custom { _ in return UIScreen.height * 0.5 },
                       .custom { _ in return UIScreen.height * 0.8 }]
        } else {
            detents = [.medium(), .large()]
        }
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = detents
            // grab protion
            presentationController.prefersGrabberVisible = true
        }
    }
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amount * sin(animatableData * .pi * shakesPerUnit), y: 0))
    }
}

extension View {
    func shake(animatableData: CGFloat) -> some View {
        modifier(ShakeEffect(animatableData: animatableData))
    }
    
    /// Automatically triggers a shake animation based on a boolean flag.
    func autoShake(shakeCount: Binding<CGFloat>, triggerFlag: Bool) -> some View {
        self.modifier(AutoShakeModifier(shakeCount: shakeCount, triggerFlag: triggerFlag))
    }
}

