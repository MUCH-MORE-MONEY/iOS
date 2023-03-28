//
//  ViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/28.
//

import UIKit

class ViewController: UIViewController {

	let label = UILabel()

	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
		style()
		layout()
	}
  }

  //MARK: - Style & Layouts
  extension ViewController {

	private func setup() {
		// 초기 셋업할 코드들
	}

	private func style() {
		// [view]
		view.backgroundColor = .systemBackground

		// [Label]
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.font = UIFont.preferredFont(forTextStyle: .title1)
		label.textAlignment = .center
		label.text = "Welcome to \n ViewController"
		
		view.addSubview(label)


	}

	private func layout() {

		// [label] 기본 중앙 배치
		NSLayoutConstraint.activate([
			label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
	}


}

