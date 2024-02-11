//
//  CalView.swift
//  XCAAiAssistant
//
//  Created by Konrad Gnat on 2/11/24.
//

import Foundation
import SwiftUI
import EventKit

struct CalView: View {
    @State private var events: [SimpleEvent] = []

    var body: some View {
        Text("today's calendar")
        List(events, id: \.self) { event in
            Text(event.title)
        }
        .onAppear {
            CalendarService().fetchICSCalendar { events in
                if let events = events {
                    self.events = events
                }
            }
        }
    }
}
