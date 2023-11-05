//
//  MMMAddWidget.swift
//  MMMWidget
//
//  Created by geonhyeong on 2023/06/06.
//

import WidgetKit
import SwiftUI
import Intents

struct AddProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> AddSimpleEntry {
        AddSimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (AddSimpleEntry) -> ()) {
        let entry = AddSimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [AddSimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = AddSimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct AddSimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct MMMAddWidgetEntryView : View {
	//MARK: Property wrapper
	
	//MARK: Property
    var entry: AddProvider.Entry

	var body: some View {
		let userInfo = UserDefaults(suiteName: "group.labM.project.MMM")
		let bounds = UIScreen.main.bounds
		let height = bounds.size.height
		let isSmall = height <= 667.0 // 4.7 inch

		VStack {
			ZStack(alignment: .top) {
				HStack {
					VStack(alignment: .leading, spacing: 4) {
						HStack(spacing: 2) {
							if let today = userInfo?.integer(forKey: "today"), let weekly = userInfo?.integer(forKey: "weekly") {
								let bool = (weekly >= 100 || isSmall)

								Text("오늘")
									.layoutPriority(1)
									.font(bool ? R.Fonts.body5 : R.Fonts.body3)
									.foregroundColor(Color(uiColor: R.Color.gray300))
								Text("\(today)개")
									.layoutPriority(2)
									.font(bool ? R.Fonts.body4 : R.Fonts.body2)
									.lineLimit(1)
									.foregroundColor(Color(uiColor: R.Color.gray500))
								Text("이번주")
									.layoutPriority(3)
									.font(bool ? R.Fonts.body5 : R.Fonts.body3)
									.lineLimit(1)
									.foregroundColor(Color(uiColor: R.Color.gray300))
								HStack(spacing: 0) {
									Text("\(weekly)")
										.lineLimit(1)
									Text("개")
								}
								.font(bool ? R.Fonts.body4 : R.Fonts.body2)
								.foregroundColor(Color(uiColor: R.Color.orange500))
							}
						}
						
						Text("새로운 경제활동")
						Text("추가하기")
					}
					.foregroundColor(Color(uiColor: R.Color.white))
					.font(R.Fonts.title1)
					.padding(.init(top: 16, leading: 16, bottom: 16, trailing: 14))
					Spacer()
				}
				
				VStack {
					Spacer()
					HStack {
						Spacer()
						Image("iconAddWidget")
							.resizable()
							.scaledToFit()
							.frame(width: Screen.maxWidth * 0.19)
							.padding(8)
					}
				}
			}
		}
		.background(Color(uiColor: R.Color.gray900))
		.widgetURL(URL(string: "myApp://Add"))
    }
}

struct MMMAddWidget: Widget {
    let kind: String = "MMMAddWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: AddProvider()) { entry in
			MMMAddWidgetEntryView(entry: entry)
        }
		.configurationDisplayName("경제 활동 추가") // 표시되는 이름
        .description("오늘 소비하거나 지출한 이력을 빠르게 작성할 수 있어요") // 표시되는 설명
		.contentMarginsDisabledIfAvailable() // iOS 17 부터 Margin이 나타남
		.supportedFamilies([.systemSmall]) // 가장 작은 사이즈 하나로만 설정
	}
}

struct MMMAddWidget_Previews: PreviewProvider {
    static var previews: some View {
        MMMAddWidgetEntryView(entry: AddSimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
