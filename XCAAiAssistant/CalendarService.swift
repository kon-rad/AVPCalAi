//
//  CalendarService.swift
//  XCAAiAssistant
//
//  Created by Konrad Gnat on 2/11/24.
//

import Foundation
import EventKit

struct SimpleEvent: Identifiable, Hashable {
    let id = UUID() // Adds a unique identifier
    var title: String
    var startDate: Date
    var endDate: Date
    var description: String?

    // Implement the hash function
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(startDate)
        hasher.combine(endDate)
        hasher.combine(description)
    }

    // Since `SimpleEvent` is a struct with only simple properties,
    // and it includes an `id` property of type `UUID` (which is already `Hashable`),
    // Swift can automatically provide the implementation for `hash(into:)` and `==`,
    // so you actually don't need to manually implement them unless you have custom logic.
}

class CalendarService {
//    let icsURL = URL(string: "https://calendar.google.com/calendar/ical/konradmgnat%40gmail.com/private-b8aa011fa4ca063fb72c8d22a72c3569/basic.ics")!
//    let icsURL = URL(string: "https://calendar.google.com/calendar/embed?src=konradmgnat%40gmail.com&ctz=America%2FLos_Angeles")!
    let icsURL = URL(string: "https://calendar.google.com/calendar/ical/konradmgnat%40gmail.com/public/basic.ics")!
    
    let googleAPIKey = "AIzaSyA8UtfbT1GSWWG1kmpmwZZ_9xtCnw9zXXg"
    let openAIAPIKey = "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"
    // Fetch and parse .ics data
    func fetchICSCalendar(completion: @escaping ([SimpleEvent]?) -> Void) {
        URLSession.shared.dataTask(with: icsURL) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            print("fetch response data", data)
            let events = self.parseICSEvents(data: data)
            // Filter events for today's date]
            print("events all of them: ", events)
            let todaysEvents = events?.filter { self.isEventToday($0) }
            print("todays events ", todaysEvents)
            completion(todaysEvents)
        }.resume()
    }
    func parseICSEvents(data: Data) -> [SimpleEvent]? {
        guard let icsString = String(data: data, encoding: .utf8) else { return nil }
        let lines = icsString.components(separatedBy: .newlines)
        var events = [SimpleEvent]()
        var currentEventProperties = [String: String]()

        print("parse events: ", events)
        for line in lines {
            if line == "BEGIN:VEVENT" {
                currentEventProperties.removeAll()
            } else if line == "END:VEVENT" {
                if let event = createEvent(from: currentEventProperties) {
                    events.append(event)
                }
            } else {
                let components = line.components(separatedBy: ":")
                if components.count == 2 {
                    let key = components[0]
                    let value = components[1]
                    currentEventProperties[key] = value
                }
            }
        }

        return events
    }

    private func createEvent(from properties: [String: String]) -> SimpleEvent? {
        guard let title = properties["SUMMARY"],
              let startString = properties["DTSTART"],
              let endString = properties["DTEND"],
              let startDate = dateFrom(icsDateString: startString),
              let endDate = dateFrom(icsDateString: endString) else {
            return nil
        }

        let description = properties["DESCRIPTION"]
        return SimpleEvent(title: title, startDate: startDate, endDate: endDate, description: description)
    }

    private func dateFrom(icsDateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.date(from: icsDateString)
    }

    private func isEventToday(_ event: SimpleEvent) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        return event.startDate >= startOfDay && event.startDate < endOfDay
    }


    // Fetch today's events from Google Calendar
    func fetchTodaysEventsFromGoogleCalendar(completion: @escaping ([Any]?) -> Void) {
        // Use Google Calendar API to fetch events
        // Ensure you've handled OAuth2 authentication before making this request
    }

    // Fetch insights or summaries using OpenAI API
    func fetchInsightsWithOpenAI(text: String, completion: @escaping (String?) -> Void) {
        // Use OpenAI API to get insights or summaries
        // Authentication and request logic goes here
    }
}
