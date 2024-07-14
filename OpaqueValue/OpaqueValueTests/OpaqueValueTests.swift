//
//  OpaqueValueTests.swift
//  OpaqueValueTests
//
//  Created by Thomas Asheim Smedmann on 14/07/2024.
//

import Testing
import Foundation

@testable import OpaqueValue

struct OpaqueValueTests {
    @Test func testOpaqueValueIsObject() async throws {
        let jsonData = Data("""
        { "object": { "string": "Hello World" }, "array": ["Hello World"], "string": "Hello World", "number": 1337, "boolean": true, "null": null }
        """.utf8)

        let opaqueValue = try JSONDecoder().decode(OpaqueValue.self, from: jsonData)

        #expect(opaqueValue == OpaqueValue.object([
            OpaqueValue.PropertyKey(stringValue: "object")!: .object([OpaqueValue.PropertyKey(stringValue: "string")!: .string("Hello World")]),
            OpaqueValue.PropertyKey(stringValue: "array")!: .array([.string("Hello World")]),
            OpaqueValue.PropertyKey(stringValue: "string")!: .string("Hello World"),
            OpaqueValue.PropertyKey(stringValue: "number")!: .number(1337),
            OpaqueValue.PropertyKey(stringValue: "boolean")!: .boolean(true),
            OpaqueValue.PropertyKey(stringValue: "null")!: .null
        ]))
    }

    @Test func testOpaqueValueIsEmptyObject() async throws {
        let jsonData = Data("""
        {}
        """.utf8)

        let opaqueValue = try JSONDecoder().decode(OpaqueValue.self, from: jsonData)

        #expect(opaqueValue == OpaqueValue.object([:]))
    }

    @Test func testOpaqueValueIsArrayOfObject() async throws {
        let jsonData = Data("""
        [{ "string": "Hello World" }, { "number": 1337 }, { "boolean": true }]
        """.utf8)

        let opaqueValue = try JSONDecoder().decode(OpaqueValue.self, from: jsonData)

        #expect(opaqueValue == OpaqueValue.array([
            .object([OpaqueValue.PropertyKey(stringValue: "string")!: .string("Hello World")]),
            .object([OpaqueValue.PropertyKey(stringValue: "number")!: .number(1337)]),
            .object([OpaqueValue.PropertyKey(stringValue: "boolean")!: .boolean(true)]),
        ]))
    }

    @Test func testOpaqueValueIsArrayOfArray() async throws {
        let jsonData = Data("""
        [[{ "string": "Hello World" }], ["Hello", "World"], [1337, 13.37], [true, false], [null, null]]
        """.utf8)

        let opaqueValue = try JSONDecoder().decode(OpaqueValue.self, from: jsonData)

        #expect(opaqueValue == OpaqueValue.array([
            .array([.object([OpaqueValue.PropertyKey(stringValue: "string")!: .string("Hello World")])]),
            .array([.string("Hello"), .string("World")]),
            .array([.number(1337), .number(13.37)]),
            .array([.boolean(true), .boolean(false)]),
            .array([.null, .null])
        ]))
    }

    @Test func testOpaqueValueIsArrayOfString() async throws {
        let jsonData = Data("""
        ["Hello", "World"]
        """.utf8)

        let opaqueValue = try JSONDecoder().decode(OpaqueValue.self, from: jsonData)

        #expect(opaqueValue == OpaqueValue.array([.string("Hello"), .string("World")]))
    }

    @Test func testOpaqueValueIsArrayOfNumber() async throws {
        let jsonData = Data("""
        [1337, 13.37, 0.1337]
        """.utf8)

        let opaqueValue = try JSONDecoder().decode(OpaqueValue.self, from: jsonData)

        #expect(opaqueValue == OpaqueValue.array([.number(1337), .number(13.37), .number(0.1337)]))
    }

    @Test func testOpaqueValueIsArrayOfBoolean() async throws {
        let jsonData = Data("""
        [true, false]
        """.utf8)

        let opaqueValue = try JSONDecoder().decode(OpaqueValue.self, from: jsonData)

        #expect(opaqueValue == OpaqueValue.array([.boolean(true), .boolean(false)]))
    }

    @Test func testOpaqueValueIsArrayOfNull() async throws {
        let jsonData = Data("""
        [null, null, null]
        """.utf8)

        let opaqueValue = try JSONDecoder().decode(OpaqueValue.self, from: jsonData)

        #expect(opaqueValue == OpaqueValue.array([.null, .null, .null]))
    }

    @Test func testOpaqueValueIsArrayOfMixed() async throws {
        let jsonData = Data("""
        [{ "string": "Hello World" }, ["Hello World"], "Hello World", 1337, true, null]
        """.utf8)

        let opaqueValue = try JSONDecoder().decode(OpaqueValue.self, from: jsonData)

        #expect(opaqueValue == OpaqueValue.array([
            .object([OpaqueValue.PropertyKey(stringValue: "string")!: .string("Hello World")]),
            .array([.string("Hello World")]),
            .string("Hello World"),
            .number(1337),
            .boolean(true),
            .null
        ]))
    }

    @Test func testOpaqueValueIsString() async throws {
        let jsonData = Data("""
        "Hello World"
        """.utf8)

        let opaqueValue = try JSONDecoder().decode(OpaqueValue.self, from: jsonData)

        #expect(opaqueValue == OpaqueValue.string("Hello World"))
    }

    @Test(arguments: [
        13.37,
        0.1337,
        1337.1337
    ]) func testOpaqueValueIsDoubleNumber(number: Double) async throws {
        let jsonData = Data("""
        \(number)
        """.utf8)

        let opaqueValue = try JSONDecoder().decode(OpaqueValue.self, from: jsonData)

        #expect(opaqueValue == OpaqueValue.number(number))

        if case let .number(value) = opaqueValue {
            #expect(Int(exactly: value) == nil)
        } else {
            Issue.record("Expected Opaque.number")
        }
    }

    @Test(arguments: [
        1337,
        133,
        13,
        1,
        0
    ]) func testOpaqueValueIsIntegerNumber(number: Int) async throws {
        let jsonData = Data("""
        \(number)
        """.utf8)

        let opaqueValue = try JSONDecoder().decode(OpaqueValue.self, from: jsonData)

        #expect(opaqueValue == OpaqueValue.number(Double(number)))

        if case let .number(value) = opaqueValue {
            let integer = try #require(Int(exactly: value))
            #expect(integer == number)
        } else {
            Issue.record("Expected Opaque.number")
        }
    }

    @Test func testOpaqueValueNumberIsBothIntegerAndDouble() async throws {
        let number = 1337.0

        let jsonData = Data("""
        \(number)
        """.utf8)

        let opaqueValue = try JSONDecoder().decode(OpaqueValue.self, from: jsonData)

        #expect(opaqueValue == OpaqueValue.number(number))

        if case let .number(value) = opaqueValue {
            let integer = try #require(Int(exactly: value))
            let number = try #require(Int(exactly: number))
            #expect(integer == number)
        } else {
            Issue.record("Expected Opaque.number")
        }
    }

    @Test func testOpaqueValueIsBooleanFalse() async throws {
        let jsonData = Data("""
        false
        """.utf8)

        let opaqueValue = try JSONDecoder().decode(OpaqueValue.self, from: jsonData)

        #expect(opaqueValue == OpaqueValue.boolean(false))
    }

    @Test func testOpaqueValueIsBooleanTrue() async throws {
        let jsonData = Data("""
        true
        """.utf8)

        let opaqueValue = try JSONDecoder().decode(OpaqueValue.self, from: jsonData)

        #expect(opaqueValue == OpaqueValue.boolean(true))
    }

    @Test func testOpaqueValueIsNull() async throws {
        let jsonData = Data("""
        null
        """.utf8)

        let opaqueValue = try JSONDecoder().decode(OpaqueValue.self, from: jsonData)

        #expect(opaqueValue == OpaqueValue.null)
    }
}
