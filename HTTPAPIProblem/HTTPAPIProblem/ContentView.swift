//
//  ContentView.swift
//  HTTPAPIProblem
//
//  Created by Thomas Smedmann on 07/01/2025.
//

import SwiftUI

/// A simple HTTP Client with the notion of a `Response` and a `UnexpectedResponse` (when the HTTP status code in the response was unexpected).
struct HTTPClient {
    struct Response: Sendable {
        let statusCode: Int
        let body: Data

        init(statusCode: Int, body: Data) {
            self.statusCode = statusCode
            self.body = body
        }

        func decode<Value: Decodable>(as _: Value.Type = Value.self) throws -> Value {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(Value.self, from: body)
        }
    }

    struct UnexpectedResponse: Error {
        let statusCode: Int
        let body: Data

        init(statusCode: Int, body: Data) {
            self.statusCode = statusCode
            self.body = body
        }

        func decode<Value: Decodable>(as _: Value.Type = Value.self) throws -> Value {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(Value.self, from: body)
        }
    }

    private func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, httpResponse) = try await URLSession.shared.data(for: request)
        guard let httpURLResponse = httpResponse as? HTTPURLResponse else {
            fatalError("Why did this happen?")
        }
        return (data, httpURLResponse)
    }

    func response(for request: URLRequest) async throws -> Response {
        let (data, httpResponse) = try await data(for: request)
        if (200..<300).contains(httpResponse.statusCode) {
            return Response(statusCode: httpResponse.statusCode, body: data)
        } else {
            throw UnexpectedResponse(statusCode: httpResponse.statusCode, body: data)
        }
    }
}

/// A simple struct to represent an Alert.
struct AlertDetails {
    struct Action {
        let title: String
        let handler: () -> Void
    }

    let message: String
    let actions: [Action]
}

// MARK: ContentView

struct ContentView: View {
    @Environment(\.openURL) private var openURL

    @State private var alertDetails: AlertDetails?

    var body: some View {
        VStack {
            Text("Hello HTTP API Problem!")
        }
        .alert(
            "Ups!",
            isPresented: Binding(
                get: { alertDetails != nil },
                set: { _ in alertDetails = nil }
            ),
            presenting: alertDetails,
            actions: { alertDetails in
                ForEach(alertDetails.actions.indices, id: \.self) { index in
                    Button(
                        alertDetails.actions[index].title,
                        action: alertDetails.actions[index].handler
                    )
                }

                Button("Close", role: .cancel) {}
            },
            message: { alertDetails in
                Text(alertDetails.message)
            }
        )
        .task {
            do {
                let httpClient = HTTPClient()

                let request = URLRequest(url: URL(string: "www.example.ios")!)

                let _ = try await httpClient.response(for: request)
            } catch let unexpectedResponse as HTTPClient.UnexpectedResponse {
                if let coreProblem = try? unexpectedResponse.decode(as: CoreHTTPAPIProblem.self) {
                    handle(coreProblem)
                } else if let unknownProblem = try? unexpectedResponse.decode(as: OpaqueHTTPAPIProblem.self) {
                    handle(unknownProblem)
                } else {
                    handleUnexpectedResponseWithoutAProblem()
                }
            } catch {
                alertDetails = AlertDetails(
                    message: "Network issue",
                    actions: []
                )
            }
        }
    }

    private func handle(_ coreProblem: CoreHTTPAPIProblem) {
        switch coreProblem {
        case .someProblem(let someProblem):
            alertDetails = AlertDetails(
                message: someProblem.extras.description,
                actions: []
            )

        case .someOtherProblem(let someOtherProblem):
            alertDetails = AlertDetails(
                message: someOtherProblem.extras.message,
                actions: []
            )

        case .userActionRequired(let action):
            alertDetails = AlertDetails(
                message: action.extras.description,
                actions: [
                    AlertDetails.Action(
                        title: "Act Now",
                        handler: {
                            openURL(action.extras.action)
                        }
                    )
                ]
            )
        }
    }

    private func handle(_ unknownProblem: OpaqueHTTPAPIProblem) {
        alertDetails = AlertDetails(
            message: unknownProblem.detail,
            actions: []
        )
    }

    private func handleUnexpectedResponseWithoutAProblem() {
        alertDetails = AlertDetails(
            message: "Something unexpected happened, but the server did not report it in the form of a Problem.",
            actions: []
        )
    }
}

#Preview {
    ContentView()
}
