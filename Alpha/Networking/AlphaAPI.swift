//
//  AlphaAPI.swift
//  Alpha
//
//  Created by Theo Mendes on 20/10/19.
//  Copyright © 2019 Hurb. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol AlphaAPI {
    /**
    Perform a search with the API

    - Parameters:
       - query: The city to be searched.
       - page: Page to retrive the results

    - Returns: An HurbResponse sequence
    */
    func search(query: String, page: Int) -> Single<[Deal]>
}
