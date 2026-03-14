//
//  UIDevice+Extension.swift
//  HowToUseKit
//

import UIKit

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        switch identifier {

        // iPhone 17 Series
        case "iPhone18,1": return "iPhone 17 Pro"
        case "iPhone18,2": return "iPhone 17 Pro Max"
        case "iPhone18,3": return "iPhone 17"
        case "iPhone18,4": return "iPhone Air"

        // iPhone 16 Series
        case "iPhone17,1": return "iPhone 16 Pro"
        case "iPhone17,2": return "iPhone 16 Pro Max"
        case "iPhone17,3": return "iPhone 16"
        case "iPhone17,4": return "iPhone 16 Plus"

        // iPhone 15 Series
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"

        // iPhone 14 Series
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"

        // iPhone 13 Series
        case "iPhone14,5": return "iPhone 13"
        case "iPhone14,2": return "iPhone 13 Pro"
        case "iPhone14,3": return "iPhone 13 Pro Max"
        case "iPhone14,4": return "iPhone 13 mini"

        // iPhone SE
        case "iPhone12,8": return "iPhone SE (2nd gen)"
        case "iPhone14,6": return "iPhone SE (3rd gen)"

        // Simulator
        case "i386", "x86_64", "arm64":
            return "Simulator (\(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS")))"

        default: return identifier
        }
    }

    func mapToDevice(identifier: String) -> String {
        switch identifier {
        case "iPhone17,1": return "iPhone 16 Pro"
        case "iPhone17,2": return "iPhone 16 Pro Max"
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
        default: return identifier
        }
    }
}
