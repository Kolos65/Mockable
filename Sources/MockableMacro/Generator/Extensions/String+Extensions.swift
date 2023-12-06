//
//  String+Extensions.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2023. 11. 19..
//

extension String {
    var capitalizedFirstLetter: String {
        let firstLetter = prefix(1).capitalized
        let remainingLetters = dropFirst()
        return firstLetter + remainingLetters
    }
}
