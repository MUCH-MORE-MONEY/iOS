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
        if showSheet {
            // presenting Modal View
            let sheetController = CustomHostingController(rootView: sheetView)
            sheetController.presentationController?.delegate = context.coordinator
            uiViewController.present(sheetController, animated: true)
        } else {
            // closing view when showSheet toggled again
            uiViewController.dismiss(animated: true )
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
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [
                .medium(),
                .large()
            ]
            
            // grab protion
            presentationController.prefersGrabberVisible = true
            
        }
        
        
    }
}
