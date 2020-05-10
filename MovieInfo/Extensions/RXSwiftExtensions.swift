//
//  RXSwiftExtensions.swift
//  MovieInfo
//
//  Created by Innovez One on 09/05/2020.
//  Copyright © 2020 Antonio. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

extension BehaviorRelay where Element: RangeReplaceableCollection {

    func add(_ element: Element.Element) {
        var array = self.value
        array.append(element)
        self.accept(array)
    }
    
    func addArray(elements: [Element.Element]) {
        var array = self.value
        array.append(contentsOf: elements)
        self.accept(array)
    }
}
