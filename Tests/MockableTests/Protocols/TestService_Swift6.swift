//
//  TestService6.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 28/09/2024.
//

import Mockable

#if swift(>=6)
@Mockable
protocol TestService_Swift6 {
    // MARK: Typed Throws

    func fetch() throws(UserError)
    var fetched: User { get throws(UserError) }
}
#endif
