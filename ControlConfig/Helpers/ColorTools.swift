//
//  ColorExtension.swift
//  ControlConfig
//
//  Created by f1shy-dev on 04/03/2023
//

import Foundation
import SwiftUI
import UIKit

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue, opacity
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let opacity = try container.decode(Double.self, forKey: .opacity)
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0

        guard let color = cgColor else { return }
        UIColor(cgColor: color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        try container.encode(Double(red), forKey: .red)
        try container.encode(Double(green), forKey: .green)
        try container.encode(Double(blue), forKey: .blue)
        try container.encode(Double(alpha), forKey: .opacity)
    }
}

enum ColorTools {
    static func getMaterialRecipeColor(filePath: String, isCCModule: Bool) -> Color {
        if !FileManager.default.fileExists(atPath: filePath) { return Color.black }

        if let plist = PlistHelpers.plistToDict(path: filePath), let firstLevel = plist["baseMaterial"] as? [String: Any], let secondLevel = firstLevel["tinting"] as? [String: Any], let thirdLevel = secondLevel["tintColor"] as? [String: Any] {
            let r = thirdLevel["red"] as? Double ?? CIColor.gray.red
            let g = thirdLevel["green"] as? Double ?? CIColor.gray.green
            let b = thirdLevel["blue"] as? Double ?? CIColor.gray.blue
            let mFactor = isCCModule ? 0.8 : 1
            let a = (secondLevel["tintAlpha"] as? Double ?? mFactor) / mFactor

            return Color(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b)).opacity(a)
        }
        return Color.gray
    }

    static func getMaterialRecipeBlur(filePath: String) -> Int {
        if !FileManager.default.fileExists(atPath: filePath) { return 30 }

        if let plist = PlistHelpers.plistToDict(path: filePath), let firstLevel = plist["baseMaterial"] as? [String: Any], let secondLevel = firstLevel["materialFiltering"] as? [String: Any], let thirdLevel = secondLevel["blurRadius"] as? Int {
            return Int(thirdLevel)
        }
        return 30
    }

    static func applyMaterialRecipe(filePath: String, color: Color, blur: Int, includeSpecificsForCCModules: Bool) -> Bool {
        if let cg = color.cgColor {
            let cc = CIColor(cgColor: cg)

            var plistDict: [String: Any] = [
                "baseMaterial": [
                    "tinting": [
                        "tintAlpha": Double(cc.alpha) * (includeSpecificsForCCModules ? 0.8 : 1),
                        "tintColor": [
                            "red": Double(cc.red),
                            "green": Double(cc.green),
                            "blue": Double(cc.blue),
                            "alpha": 1
                        ]
                    ],
                    "materialFiltering": [
                        "blurRadius": blur
                    ]
                ]
            ]

//            if includeSpecificsForCCModules {
            plistDict.merge([
                "styles": [
                    "fill": "moduleFill",
                    "stroke": "moduleStroke"
                ],
                "materialSettingsVersion": 2
            ]) { current, _ in current }
//            }

            return (PlistHelpers.writeDictToPlist(dict: NSMutableDictionary(dictionary: plistDict), path: filePath))
        }
        return false
    }
}
