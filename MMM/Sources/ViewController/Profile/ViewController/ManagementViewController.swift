//
//  ManagementViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/30.
//

import UIKit

class ManagementViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = .darkGray
		self.navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = [.foregroundColor: UIColor.black]
		navigationController?.setNavigationBarHidden(false, animated: animated)	// navigation bar 숨김
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
