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
		VStack {
			ZStack(alignment: .top) {
				HStack {
					VStack(alignment: .leading, spacing: 4) {
						Text("오늘의")
						Text("경제활동")
						Text("추가하기")
					}
					.foregroundColor(Color(uiColor: R.Color.white))
					.font(R.Fonts.title1)
					.padding(.init(top: 20, leading: 16, bottom: 20, trailing: 16))
					Spacer()
				}
				
				VStack {
					Spacer()
					HStack {
						Spacer()
						Image("iconWidget")
							.resizable()
							.scaledToFit()
							.frame(width: Screen.maxWidth * 0.22)
					}
				}
			}
		}
		.background(Color(uiColor: R.Color.gray900))
    }
}

struct MMMAddWidget: Widget {
    let kind: String = "MMMAddWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: AddProvider()) { entry in
			MMMAddWidgetEntryView(entry: entry)
        }
		.configurationDisplayName("경제 활동 추가") // 표시되는 이름
        .description("This is an example widget.") // 표시되는 설명
		.supportedFamilies([.systemSmall]) // 가장 작은 사이즈 하나로만 설정
	}
}

struct MMMAddWidget_Previews: PreviewProvider {
    static var previews: some View {
        MMMAddWidgetEntryView(entry: AddSimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
