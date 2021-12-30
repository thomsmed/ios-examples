//
//  SharedAppAuthStateWidget.swift
//  SharedAppAuthStateWidget
//
//  Created by Thomas Asheim Smedmann on 30/12/2021.
//

import WidgetKit
import SwiftUI
import Intents

struct Dependencies {
    private static let migrationRepository: AuthStateRepository = SharedUserDefaultsAuthStateRepository(appGroupIdentifier: "group.com.my.app")
    private static let authStateRepository: AuthStateRepository = KeyChainAuthStateRepository(accessGroup: "<TeamId>.com.my.app",
                                                                                            serviceName: "com.my.app",
                                                                                            accountName: "My App",
                                                                                            migrationRepository: migrationRepository)
    static let authTokenProvider: AuthTokenProvider = WidgetAuthTokenProvider(authStateRepository: authStateRepository)
}

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date(), state: AppAuthState(token: nil, error: nil), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent,
                     in context: Context,
                     completion: @escaping (WidgetEntry) -> ()) {
        if context.isPreview {
            // Note: Should be quick to return when preview
            let entry = WidgetEntry(date: Date(), state: AppAuthState(token: nil, error: nil), configuration: configuration)
            completion(entry)
        } else {
            Dependencies.authTokenProvider.performWithFreshToken({ result in
                let currentDate = Date()
                let entry: WidgetEntry
                switch result {
                case .failure(let error):
                    if error is AuthError, case AuthError.notAuthenticated = error {
                        entry = WidgetEntry(date: currentDate, state: AppAuthState(token: nil, error: nil), configuration: configuration)
                    } else {
                        entry = WidgetEntry(date: currentDate, state: AppAuthState(token: nil, error: error), configuration: configuration)
                    }
                case .success(let token):
                    entry = WidgetEntry(date: currentDate, state: AppAuthState(token: token, error: nil), configuration: configuration)
                }
                completion(entry)
            })
        }
    }

    func getTimeline(for configuration: ConfigurationIntent,
                     in context: Context,
                     completion: @escaping (Timeline<Entry>) -> ()) {
        Dependencies.authTokenProvider.performWithFreshToken({ result in
            let currentDate = Date()
            var entries: [WidgetEntry] = []
            let entry: WidgetEntry
            switch result {
            case .failure(let error):
                if error is AuthError, case AuthError.notAuthenticated = error {
                    entry = WidgetEntry(date: currentDate, state: AppAuthState(token: nil, error: nil), configuration: configuration)
                } else {
                    entry = WidgetEntry(date: currentDate, state: AppAuthState(token: nil, error: error), configuration: configuration)
                }
            case .success(let token):
                entry = WidgetEntry(date: currentDate, state: AppAuthState(token: token, error: nil), configuration: configuration)
            }
            entries.append(entry)
            let nextDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
            let timeline = Timeline(entries: entries, policy: .after(nextDate))
            completion(timeline)
        })
    }
}

struct AppAuthState {
    let token: String?
    let error: Error?
}

struct WidgetEntry: TimelineEntry {
    let date: Date
    let state: AppAuthState
    let configuration: ConfigurationIntent
}

struct SharedAppAuthStateWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            if entry.state.error != nil {
                Text("Ups! Something went wrong...")
            } else {
                Text(entry.state.token?.isEmpty == false ? "You are signed in!" : "You are not signed in")
            }
            HStack {
                Text("Last checked:")
                Text(entry.date, style: .time)
            }
        }
    }
}

@main
struct SharedAppAuthStateWidget: Widget {
    let kind: String = "SharedAppAuthStateWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            SharedAppAuthStateWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct SharedAppAuthStateWidget_Previews: PreviewProvider {
    static var previews: some View {
        SharedAppAuthStateWidgetEntryView(entry: WidgetEntry(date: Date(),
                                                             state: AppAuthState(token: nil, error: nil),
                                                             configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
