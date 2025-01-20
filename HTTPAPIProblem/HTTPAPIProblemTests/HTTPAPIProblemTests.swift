//
//  HTTPAPIProblemTests.swift
//  HTTPAPIProblemTests
//
//  Created by Thomas Smedmann on 18/01/2025.
//

import Foundation
import Testing

@testable import HTTPAPIProblem

struct HTTPAPIProblemTests {
    @Test func test_decode_opaqueHTTPAPIProblem() async throws {
        let problemJSONs = [
            """
            {
                "type": "\("urn:some:problem")",
                "title": "\("Title")",
                "status": \(400),
                "detail": "\("Detail")",
                "instance": "\("https://some.domain/problem/instance")",
            }
            """,
            """
            {
                "type": "\("https://some.domain/some/problem")",
                "title": "\("Title")",
                "status": \(400),
                "detail": "\("Detail")",
                "instance": "\("https://some.domain/problem/instance")",
                "foo": "\("Foo")",
            }
            """,
            """
            {
                "type": "\("https://some.domain/problem/with/extras-object")",
                "title": "\("Title")",
                "status": \(400),
                "detail": "\("Detail")",
                "instance": "\("https://some.domain/problem/instance")",
                "extras": {
                    "title": "Action required",
                    "message": "Please visit the URL",
                    "action": "VISIT_URL",
                    "url": "https://some.domain/some/path"
                }
            }
            """,
        ]

        let jsonDecoder = JSONDecoder()

        try problemJSONs.forEach { problemJSON in
            let _ = try jsonDecoder.decode(
                OpaqueHTTPAPIProblem.self, from: Data(problemJSON.utf8)
            )
        }
    }

    @Test func test_decode_someHTTPAPIProblem() async throws {
        let problemJSON = """
            {
                "type": "\(SomeExtras.associatedProblemType!)",
                "title": "\("Title")",
                "status": \(400),
                "detail": "\("Detail")",
                "instance": "\("https://some.domain/problem/instance")",
                "description": "\("Description")",
            }
            """

        let jsonDecoder = JSONDecoder()

        let someProblem = try jsonDecoder.decode(
            SomeHTTPAPIProblem.self, from: Data(problemJSON.utf8)
        )
        let opaqueProblem = try jsonDecoder.decode(
            OpaqueHTTPAPIProblem.self, from: Data(problemJSON.utf8)
        )

        #expect(someProblem.type == SomeExtras.associatedProblemType)
        #expect(opaqueProblem.type == SomeExtras.associatedProblemType)
    }

    @Test func test_decode_someOtherHTTPAPIProblem() async throws {
        let problemJSON = """
            {
                "type": "\(SomeOtherExtras.associatedProblemType!)",
                "title": "\("Title")",
                "status": \(400),
                "detail": "\("Detail")",
                "instance": "\("https://some.domain/problem/instance")",
                "message": "\("Message")",
            }
            """

        let jsonDecoder = JSONDecoder()

        let someOtherProblem = try jsonDecoder.decode(
            SomeOtherHTTPAPIProblem.self, from: Data(problemJSON.utf8)
        )
        let opaqueProblem = try jsonDecoder.decode(
            OpaqueHTTPAPIProblem.self, from: Data(problemJSON.utf8)
        )

        #expect(someOtherProblem.type == SomeOtherExtras.associatedProblemType)
        #expect(opaqueProblem.type == SomeOtherExtras.associatedProblemType)
    }

    @Test func test_decode_userActionRequiredHTTPAPIProblem() async throws {
        let problemJSON = """
            {
                "type": "\(UserActionRequiredExtras.associatedProblemType!)",
                "title": "\("Title")",
                "status": \(400),
                "detail": "\("Detail")",
                "instance": "\("https://some.domain/problem/instance")",
                "description": "\("Description")",
                "action": "\("https://some.domain/some/action/url")",
            }
            """

        let jsonDecoder = JSONDecoder()

        let userActionRequiredProblem = try jsonDecoder.decode(
            UserActionRequiredHTTPAPIProblem.self, from: Data(problemJSON.utf8)
        )
        let opaqueProblem = try jsonDecoder.decode(
            OpaqueHTTPAPIProblem.self, from: Data(problemJSON.utf8)
        )

        #expect(userActionRequiredProblem.type == UserActionRequiredExtras.associatedProblemType)
        #expect(opaqueProblem.type == UserActionRequiredExtras.associatedProblemType)
    }

    @Test func test_decode_throwsHTTPAPIProblemTypeMismatch() async throws {
        struct EmptyUntypedExtras: HTTPAPIProblemExtras {
            static let associatedProblemType: String? = nil
        }

        struct EmptyTypedExtras: HTTPAPIProblemExtras {
            static let associatedProblemType: String? = ""
        }

        let problemWithWrongTypeJSON = """
            {
                "type": "\(SomeExtras.associatedProblemType!)",
                "title": "\("Title")",
                "status": \(400),
                "detail": "\("Detail")",
                "instance": "\("https://some.domain/problem/instance")",
                "description": "\("Description")",
                "action": "\("https://some.domain/some/action/url")",
            }
            """

        let problemWithEmptyTypeJSON = """
            {
                "type": "",
                "title": "\("Title")",
                "status": \(400),
                "detail": "\("Detail")",
                "instance": "\("https://some.domain/problem/instance")",
                "description": "\("Description")",
                "action": "\("https://some.domain/some/action/url")",
            }
            """

        let jsonDecoder = JSONDecoder()

        #expect(throws: HTTPAPIProblemTypeMismatch.self) {
            try jsonDecoder.decode(
                UserActionRequiredHTTPAPIProblem.self, from: Data(problemWithWrongTypeJSON.utf8)
            )
        }

        let opaqueProblem = try jsonDecoder.decode(
            OpaqueHTTPAPIProblem.self, from: Data(problemWithWrongTypeJSON.utf8)
        )

        #expect(opaqueProblem.type != UserActionRequiredExtras.associatedProblemType)

        let untypedProblem = try jsonDecoder.decode(
            HTTPAPIProblem<EmptyUntypedExtras>.self, from: Data(problemWithWrongTypeJSON.utf8)
        )
        #expect(untypedProblem.type != UserActionRequiredExtras.associatedProblemType)

        #expect(throws: HTTPAPIProblemTypeMissing.self) {
            try jsonDecoder.decode(
                UserActionRequiredHTTPAPIProblem.self, from: Data(problemWithEmptyTypeJSON.utf8)
            )
        }

        #expect(throws: HTTPAPIProblemTypeMissing.self) {
            try jsonDecoder.decode(
                OpaqueHTTPAPIProblem.self, from: Data(problemWithEmptyTypeJSON.utf8)
            )
        }

        #expect(throws: HTTPAPIProblemTypeMismatch.self) {
            try jsonDecoder.decode(
                HTTPAPIProblem<EmptyTypedExtras>.self, from: Data(problemWithWrongTypeJSON.utf8)
            )
        }
    }

    @Test func test_initialize_someHTTPAPIProblem() async throws {
        let someProblem = try SomeHTTPAPIProblem(
            title: "Title",
            status: 400,
            detail: "Detail",
            instance: "https://some.domain/problem/instance",
            extras: SomeExtras(description: "Description")
        )
        let opaqueProblem = OpaqueHTTPAPIProblem(someProblem)

        #expect(someProblem.type == SomeExtras.associatedProblemType)
        #expect(opaqueProblem.type == SomeExtras.associatedProblemType)
    }

    @Test func test_initialize_someOtherHTTPAPIProblem() async throws {
        let someOtherProblem = try SomeOtherHTTPAPIProblem(
            title: "Title",
            status: 400,
            detail: "Detail",
            instance: "https://some.domain/problem/instance",
            extras: SomeOtherExtras(message: "Message")
        )
        let opaqueProblem = OpaqueHTTPAPIProblem(someOtherProblem)

        #expect(someOtherProblem.type == SomeOtherExtras.associatedProblemType)
        #expect(opaqueProblem.type == SomeOtherExtras.associatedProblemType)
    }

    @Test func test_initialize_userActionRequiredHTTPAPIProblem() async throws {
        let userActionRequiredProblem = try UserActionRequiredHTTPAPIProblem(
            title: "Title",
            status: 400,
            detail: "Detail",
            instance: "https://some.domain/problem/instance",
            extras: UserActionRequiredExtras(
                description: "Description",
                action: URL(string: "https://some.domain/some/action/url")!
            )
        )
        let opaqueProblem = OpaqueHTTPAPIProblem(userActionRequiredProblem)

        #expect(userActionRequiredProblem.type == UserActionRequiredExtras.associatedProblemType)
        #expect(opaqueProblem.type == UserActionRequiredExtras.associatedProblemType)
    }

    @Test func test_initialize_throwsHTTPAPIProblemTypeMismatch() async throws {
        struct EmptyUntypedExtras: HTTPAPIProblemExtras {
            static let associatedProblemType: String? = nil
        }

        struct EmptyTypedExtras: HTTPAPIProblemExtras {
            static let associatedProblemType: String? = ""
        }

        #expect(throws: HTTPAPIProblemTypeMissing.self) {
            try HTTPAPIProblem(
                title: "Title",
                status: 400,
                detail: "Detail",
                instance: "https://some.domain/problem/instance",
                extras: EmptyUntypedExtras()
            )
        }

        #expect(throws: HTTPAPIProblemTypeMissing.self) {
            try HTTPAPIProblem(
                title: "Title",
                status: 400,
                detail: "Detail",
                instance: "https://some.domain/problem/instance",
                extras: EmptyTypedExtras()
            )
        }

        #expect(throws: HTTPAPIProblemTypeMismatch.self) {
            try HTTPAPIProblem(
                type: "\(SomeExtras.associatedProblemType)",
                title: "Title",
                status: 400,
                detail: "Detail",
                instance: "https://some.domain/problem/instance",
                extras: UserActionRequiredExtras(
                    description: "Description",
                    action: URL(string: "https://some.domain/some/action/url")!
                )
            )
        }

        #expect(throws: HTTPAPIProblemTypeMissing.self) {
            try HTTPAPIProblem(
                type: "",
                title: "Title",
                status: 400,
                detail: "Detail",
                instance: "https://some.domain/problem/instance"
            )
        }
    }
}

// MARK: Testing Opaque Problem with OpaqueValue as Extras

extension OpaqueValue: @retroactive HTTPAPIProblemExtras {
    public static let associatedProblemType: String? = nil
}

extension HTTPAPIProblemTests {
    @Test func test_decode_opaqueHTTPAPIProblemOfOpaqueValue() async throws {
        let problemJSONs = [
            """
            {
                "type": "\("urn:some:problem")",
                "title": "\("Title")",
                "status": \(400),
                "detail": "\("Detail")",
                "instance": "\("https://some.domain/problem/instance")",
            }
            """,
            """
            {
                "type": "\("https://some.domain/some/problem")",
                "title": "\("Title")",
                "status": \(400),
                "detail": "\("Detail")",
                "instance": "\("https://some.domain/problem/instance")",
                "foo": "\("Foo")",
            }
            """,
            """
            {
                "type": "\("https://some.domain/problem/with/extras-object")",
                "title": "\("Title")",
                "status": \(400),
                "detail": "\("Detail")",
                "instance": "\("https://some.domain/problem/instance")",
                "extras": {
                    "title": "Action required",
                    "message": "Please visit the URL",
                    "action": "VISIT_URL",
                    "url": "https://some.domain/some/path"
                }
            }
            """,
        ]

        let jsonDecoder = JSONDecoder()

        let firstOpaqueProblem = try jsonDecoder.decode(
            HTTPAPIProblem<OpaqueValue>.self, from: Data(problemJSONs[0].utf8)
        )

        #expect(firstOpaqueProblem.extras == .object([
            .init(stringValue: "type"): .string("urn:some:problem"),
            .init(stringValue: "title"): .string("Title"),
            .init(stringValue: "status"): .number(400),
            .init(stringValue: "detail"): .string("Detail"),
            .init(stringValue: "instance"): .string("https://some.domain/problem/instance"),
        ]))

        let secondOpaqueProblem = try jsonDecoder.decode(
            HTTPAPIProblem<OpaqueValue>.self, from: Data(problemJSONs[1].utf8)
        )

        #expect(secondOpaqueProblem.extras == .object([
            .init(stringValue: "type"): .string("https://some.domain/some/problem"),
            .init(stringValue: "title"): .string("Title"),
            .init(stringValue: "status"): .number(400),
            .init(stringValue: "detail"): .string("Detail"),
            .init(stringValue: "instance"): .string("https://some.domain/problem/instance"),
            .init(stringValue: "foo"): .string("Foo"),
        ]))

        let thirdOpaqueProblem = try jsonDecoder.decode(
            HTTPAPIProblem<OpaqueValue>.self, from: Data(problemJSONs[2].utf8)
        )

        #expect(thirdOpaqueProblem.extras == .object([
            .init(stringValue: "type"): .string("https://some.domain/problem/with/extras-object"),
            .init(stringValue: "title"): .string("Title"),
            .init(stringValue: "status"): .number(400),
            .init(stringValue: "detail"): .string("Detail"),
            .init(stringValue: "instance"): .string("https://some.domain/problem/instance"),
            .init(stringValue: "extras"): .object([
                .init(stringValue: "title"): .string("Action required"),
                .init(stringValue: "message"): .string("Please visit the URL"),
                .init(stringValue: "action"): .string("VISIT_URL"),
                .init(stringValue: "url"): .string("https://some.domain/some/path"),
            ]),
        ]))
    }
}
