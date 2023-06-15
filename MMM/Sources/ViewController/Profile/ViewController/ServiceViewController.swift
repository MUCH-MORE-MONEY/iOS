//
//  ServiceViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/04.
//

import UIKit
import Then
import SnapKit

final class ServiceViewController: BaseViewController {
	// MARK: - Properties
	private lazy var labelCellList = ["서비스 약관", "문의 남기기"]

    // MARK: - UI Components
    private lazy var mainLabel = UILabel()
    private lazy var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(false, animated: animated)	// navigation bar 노출
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setNavigationBarHidden(true, animated: animated)	// navigation bar 숨김
	}
}
// MARK: - Style & Layout
private extension ServiceViewController {
	// 초기 셋업할 코드들
    private func setup() {
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
		// [view]
        navigationItem.title = "문의 및 서비스 약관"
		
		tableView = tableView.then {
			$0.delegate = self
			$0.dataSource = self
			$0.showsVerticalScrollIndicator = false
			$0.backgroundColor = R.Color.gray100
	        $0.bounces = false            // TableView Scroll 방지
			$0.separatorInset.left = 24
			$0.separatorInset.right = 24
			$0.register(ProfileTableViewCell.self)
		}
		
		mainLabel = mainLabel.then {
			$0.text = "서비스 이용을 위한 약관 및 문의"
			$0.font = R.Font.title1
			$0.textColor = R.Color.gray900
		}
    }
    
    private func setLayout() {
		view.addSubviews(mainLabel, tableView)
		
        mainLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.left.right.equalToSuperview().inset(24)
        }
        
        tableView.snp.makeConstraints {
            // tableView 마진값이 피그마에 재대로 안나와 있음
            $0.top.equalTo(mainLabel.snp.bottom).offset(28)
            $0.left.right.bottom.equalToSuperview()
        }
        
    }
}
// MARK: - UITableView DataSource
extension ServiceViewController: UITableViewDataSource {
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.className, for: indexPath) as! ProfileTableViewCell
        
        if indexPath.row == 1 {
            DispatchQueue.main.async {
                cell.addAboveTheBottomBorderWithColor(color: R.Color.gray100)
            }
        }
        
        cell.setData(text: labelCellList[indexPath.row])
        cell.backgroundColor = R.Color.gray100

		return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
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
