//
//  MMMActivityWidget.swift
//  MMMWidgetExtension
//
//  Created by geonhyeong on 2023/06/06.
//

import WidgetKit
import SwiftUI
import Intents

struct ActivityProvider: IntentTimelineProvider {
	func placeholder(in context: Context) -> ActivitySimpleEntry {
		ActivitySimpleEntry(date: Date(), configuration: ConfigurationIntent())
	}

	func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (ActivitySimpleEntry) -> ()) {
		let entry = ActivitySimpleEntry(date: Date(), configuration: configuration)
		completion(entry)
	}

	func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
		var entries: [ActivitySimpleEntry] = []

		// Generate a timeline consisting of five entries an hour apart, starting from the current date.
		let currentDate = Date()
		for hourOffset in 0 ..< 5 {
			let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
			let entry = ActivitySimpleEntry(date: entryDate, configuration: configuration)
			entries.append(entry)
		}

		let timeline = Timeline(entries: entries, policy: .atEnd)
		completion(timeline)
	}
}

struct ActivitySimpleEntry: TimelineEntry {
	let date: Date
	let configuration: ConfigurationIntent
}

struct MMMActivityWidgetEntryView : View {
	//MARK: Property wrapper
	
	//MARK: Property
	var entry: ActivityProvider.Entry

	var body: some View {
		let userInfo = UserDefaults(suiteName: "group.labM.project.MMM")
		
		ZStack {
			Color(uiColor: R.Color.gray900)
			
			if let earnStr = userInfo?.string(forKey: "earn"), let payStr = userInfo?.string(forKey: "pay"), let earn = Int(earnStr), let pay = Int(payStr) {
				VStack {
					
					Text("수입 : \(earn.withCommas())")
					Text("지출 : \(pay.withCommas())")
				}
				.foregroundColor(Color(uiColor: R.Color.white))
			}
		}
	}
}

struct MMMActivityWidget: Widget {
	let kind: String = "MMMActivityWidget"

	var body: some WidgetConfiguration {
		IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: ActivityProvider()) { entry in
			MMMActivityWidgetEntryView(entry: entry)
		}
		.configurationDisplayName("경제 활동 현황") // 표시되는 이름
		.description("This is an example widget.") // 표시되는 설명
		.supportedFamilies([.systemSmall]) // 가장 작은 사이즈 하나로만 설정
	}
}

struct MMMActivityWidget_Previews: PreviewProvider {
	static var previews: some View {
		MMMActivityWidgetEntryView(entry: ActivitySimpleEntry(date: Date(), configuration: ConfigurationIntent()))
			.previewContext(WidgetPreviewContext(family: .systemSmall))
	}
}
