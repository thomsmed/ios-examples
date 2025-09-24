//
//  Models.swift
//  DomainModeling
//
//  Created by Thomas Smedmann on 24/09/2025.
//

import Foundation

// MARK: Expressions and statements

func entryPoint() {
    // Statements
    let x = 1
    var y = 2
    y = 3

    if x > 1 {
        y = 4
    } else {
        y = 5
    }

    switch x {
    case 0:
        y = 6
    case 1..<3:
        y = 7
    case 3...6:
        y = 8
    default:
        y = 9
    }

    print("X:", x, ", Y:", y)

    // Expressions
    let squared =
        { (number: Int) in
            number * number
        }
    let doubled =
        { (number: Int) in
            number + number
        }
    print("1 squared and doubled:", doubled(squared(1)))

    var max = { (left: Int, right: Int) in
        if right > left {
            right
        } else {
            left
        }
    }

    var min = { (left: Int, right: Int) in
        switch right - left {
        case 0:
            left
        case 1...Int.max:
            left
        default:
            right
        }
    }

    print("Is 1 between 0 and 10:", max(min(1, 10), 0) == 1)
}

// MARK: Functions (and methods)

func myVoidReturningFunction(text: String, number: Int) {
    var aFunction: (String, Int) -> (String, Int)

    aFunction = { text, number in
        (text, number)
    }

    aFunction = myTupleReturningFunction

    let anotherFunction = { (text: String, number: Int) in
        (text, number)
    }

    aFunction = anotherFunction

    print(aFunction("Text", 1337))
}

func myTupleReturningFunction(text: String, number: Int) -> (String, Int) {

    struct MakeTuple<First, Second> {

        let first: First
        let second: Second

        func callAsFunction() -> (First, Second) {
            self(first: self.first, second: self.second)
        }

        func callAsFunction(first: First, second: Second) -> (First, Second) {
            (first, second)
        }
    }

    let makeTuple = MakeTuple(first: text, second: number)

    return makeTuple()
}

// MARK: Union types (enums with associated values)

enum MyUnion {
    case one
    case two(Int)
    case three(String)
}

/// The type parameter `Tag` is a [phantom type](https://www.hackingwithswift.com/plus/advanced-swift/how-to-use-phantom-types-in-swift).
enum MyTaggedUnion<Tag> {
    case one
    case two(Int)
    case three(String)
}

// MARK: Compound types (structs)

struct MyComposite {
    let one: MyUnion
    let two: Int
    let three: String
}

/// The type parameter `Tag` is a [phantom type](https://www.hackingwithswift.com/plus/advanced-swift/how-to-use-phantom-types-in-swift).
struct MyTaggedComposite<Tag> {
    let one: MyUnion
    let two: Int
    let three: String
}
