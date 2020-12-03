//
//  AdminViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

extension EventLoopFuture {

    /// throwing version of the .flatMap function
    func throwingFlatMap<NewValue>(file: StaticString = #file,
                        line: UInt = #line,
                        _ callback: @escaping (Value) throws -> EventLoopFuture<NewValue>) -> EventLoopFuture<NewValue> {
        flatMap(file: file, line: line) { [self] value in
            do {
                return try callback(value)
            }
            catch {
                return eventLoop.makeFailedFuture(error, file: file, line: line)
            }
        }
    }

    /// throwing version of the .map function
    func throwingMap<NewValue>(file: StaticString = #file,
                           line: UInt = #line,
                           _ callback: @escaping (Value) throws -> NewValue) -> EventLoopFuture<NewValue> {
        flatMapThrowing(file: file, line: line, callback)
    }
}
