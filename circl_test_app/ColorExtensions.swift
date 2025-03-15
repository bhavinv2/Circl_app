//
//  ColorExtensions.swift
//  circl_test_app
//
//  Created by Bhavin Vulli on 2/8/25.
//

import SwiftUI

extension Color {
    init(hexCode: String) {
        let scanner = Scanner(string: hexCode)
        if hexCode.hasPrefix("#") {
            scanner.currentIndex = hexCode.index(after: hexCode.startIndex)
        }

        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let red = Double((rgbValue >> 16) & 0xff) / 255
        let green = Double((rgbValue >> 8) & 0xff) / 255
        let blue = Double(rgbValue & 0xff) / 255

        self.init(red: red, green: green, blue: blue)
    }
}
