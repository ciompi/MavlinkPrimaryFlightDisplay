//
//  StaticPool.swift
//  MavlinkPrimaryFlightDisplay
//
//  Created by Michael Koukoullis on 31/01/2016.
//  Copyright © 2016 Michael Koukoullis. All rights reserved.
//


enum StaticPoolError: ErrorType {
    case ReleaseOfElementNotOwnedByPool
    case RequestCannotBeFulfilled
}

class StaticPool <ElementType: Equatable> {
    
    typealias RequestHandler = (element: ElementType) -> Void
    typealias ReleaseHandler = (element: ElementType) -> Void
    
    private var idleElements: [ElementType]
    private var usedElements = [ElementType]()
    private let requestHandler: RequestHandler?
    private let releaseHandler: ReleaseHandler?

    init(elements: [ElementType], onRequest: RequestHandler? = nil, onRelease: ReleaseHandler? = nil) {
        self.idleElements = elements
        self.requestHandler = onRequest
        self.releaseHandler = onRelease
    }

    func request() throws -> ElementType {
        guard !idleElements.isEmpty else {
            throw StaticPoolError.RequestCannotBeFulfilled
        }
        
        let element = idleElements.removeFirst()
        usedElements.append(element)
        requestHandler?(element: element)
        return element
    }
    
    func release(element: ElementType) throws {
        guard let index = usedElements.indexOf(element) else {
            throw StaticPoolError.ReleaseOfElementNotOwnedByPool
        }
        
        releaseHandler?(element: element)
        usedElements.removeAtIndex(index)
        idleElements.append(element)
    }
    
    func forEach(handler: ElementType -> Void) {
        usedElements.forEach { handler($0) }
    }
}