import ProjectDescription
import ProjectDescriptionHelpers
import MyPlugin

/*
 +-------------+
 |             |
 |     App     | Contains MMM App target and MMM unit-test target
 |             |
 +------+-------------+-------+
 |         depends on         |
 |                            |
 +----v-----+                   +-----v-----+
 |          |                   |           |
 |   Kit    |                   |     UI    |   Two independent frameworks to share code and start modularising your app
 |          |                   |           |
 +----------+                   +-----------+
 
 */

// MARK: - Project

// MARK: - Project
private let appName = "MMM"
private let bundleId = "com.lab.MMM"
private let targetVersion = "14.0"
private let organizationName = "Lab.M"

// Local plugin loaded
let localHelper = LocalHelper(name: "MyPlugin")

let infoPlist: [String: InfoPlist.Value] = [
	"CFBundleShortVersionString": "1.0",
	"CFBundleVersion": "1",
	"UIMainStoryboardFile": "",
	"UILaunchStoryboardName": "LaunchScreen"
]


let project = Project(
	name: appName,
	organizationName: organizationName,
	packages: [
		.remote(url: "https://github.com/SnapKit/SnapKit.git", requirement: .upToNextMajor(from: "5.6.0")),
		.remote(url: "https://github.com/devxoul/Then.git", requirement: .upToNextMajor(from: "3.0.0")),
		.remote(url: "https://github.com/jrendel/SwiftKeychainWrapper", requirement: .upToNextMajor(from: "4.0.0"))
	],
	targets: [
		Target(name: appName,
			   platform: .iOS,
			   product: .app,
			   bundleId: bundleId,
			   deploymentTarget: .iOS(targetVersion: targetVersion, devices: [.iphone]),
			   infoPlist: .extendingDefault(with: infoPlist),
			   sources: ["Targets/\(appName)/Sources/**"],
			   resources: ["Targets/\(appName)/Resources/**"],
			   dependencies: [
				.package(product: "Then"),
				.package(product: "SnapKit"),
				.package(product: "SwiftKeychainWrapper")
			   ]
			  )
	]
)
