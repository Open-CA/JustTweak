//
//  Types.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation

typealias LocalConfigurationFormat = [FeatureKey: FeatureFormat]
typealias FeatureFormat = [VariableKey: TweakFormat]
typealias TweakFormat = [String: Any]

typealias FeatureKey = String
typealias VariableKey = String
