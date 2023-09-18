//
//  ServiceViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/04.
//

import UIKit
import Then
import SnapKit

final class ServiceViewController: BaseViewControllerWithNav {
	// MARK: - Constants
	private enum UI {
		static let mainLabelMargin: UIEdgeInsets = .init(top: 24, left: 24, bottom: 0, right: 24)
		static let tableViewMargin: UIEdgeInsets = .init(top: 28, left: 0, bottom: 0, right: 0)
		static let cellHeight: CGFloat = 44
	}
	
	// MARK: - Properties
	private lazy var labelCellList = ["서비스 약관", "문의 남기기"]

    // MARK: - UI Components
    private lazy var mainLabel = UILabel()
    private lazy var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
//MARK: - Attribute & Hierarchy & Layouts
extension ServiceViewController {
	override func setAttribute() {
		// [view]
        navigationItem.title = "문의 및 서비스 약관"
		view.backgroundColor = R.Color.gray100

		tableView = tableView.then {
			$0.delegate = self
			$0.dataSource = self
			$0.showsVerticalScrollIndicator = false
			$0.backgroundColor = R.Color.gray100
	        $0.bounces = false            // TableView Scroll 방지
			$0.separatorStyle = .none
			$0.register(ProfileTableViewCell.self)
		}
		
		mainLabel = mainLabel.then {
			$0.text = "서비스 이용을 위한 약관 및 문의"
			$0.font = R.Font.title1
			$0.textColor = R.Color.gray900
		}
    }
	
	override func setHierarchy() {
		view.addSubviews(mainLabel, tableView)
	}
    
    override func setLayout() {
        mainLabel.snp.makeConstraints {
			$0.top.equalToSuperview().offset(UI.mainLabelMargin.top)
			$0.left.right.equalToSuperview().inset(UI.mainLabelMargin.left)
        }
        
        tableView.snp.makeConstraints {
            // tableView 마진값이 피그마에 재대로 안나와 있음
			$0.top.equalTo(mainLabel.snp.bottom).offset(UI.tableViewMargin.top)
            $0.left.right.bottom.equalToSuperview()
        }
    }
}
// MARK: - UITableView DataSource
extension ServiceViewController: UITableViewDataSource {
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return labelCellList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.className, for: indexPath) as! ProfileTableViewCell
        
        cell.setData(text: labelCellList[indexPath.row], last: indexPath.row == labelCellList.count - 1)
        cell.backgroundColor = R.Color.gray100
		
		let backgroundView = UIView()
		backgroundView.backgroundColor = R.Color.gray400.withAlphaComponent(0.3)
		cell.selectedBackgroundView = backgroundView

		return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UI.cellHeight
    }
}
// MARK: - UITableView Delegate
extension ServiceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var url = ""
        switch indexPath.row {
        case 0:
            url = "https://noisy-cesium-9a6.notion.site/MMM-3e57c92fcba84754806ffbe5ffadce95"
        case 1:
            url = "https://talk.naver.com/ct/w40igt"
        default:
            break
        }
        
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }
}
