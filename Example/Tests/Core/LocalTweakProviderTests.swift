//
//  LocalTweakProviderTests.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import XCTest
import JustTweak

class LocalConfigurationTests: XCTestCase {
    
    var tweakProvider: LocalTweakProvider!
    
    override func setUp() {
        super.setUp()
        tweakProvider = tweakProviderWithFileNamed("test_tweak_provider")!
    }
    
    override func tearDown() {
        tweakProvider = nil
        super.tearDown()
    }
    
    private func tweakProviderWithFileNamed(_ fileName: String) -> LocalTweakProvider? {
        let bundle = Bundle(for: LocalConfigurationTests.self)
        let jsonURL = bundle.url(forResource: fileName, withExtension: "json")!
        return LocalTweakProvider(jsonURL: jsonURL)
    }
    
    func testParsesBoolTweak() {
        let redViewTweak = Tweak(feature: Features.uiCustomization, variable: Variables.displayRedView, value: true, title: "Display Red View", group: "UI Customization")
        XCTAssertEqual(redViewTweak, tweakProvider.tweakWith(feature: Features.uiCustomization, variable: Variables.displayRedView))
    }
    
    func testParsesFloatTweak() {
        let redViewAlphaTweak = Tweak(feature: Features.uiCustomization, variable: Variables.redViewAlpha, value: 1.0, title: "Red View Alpha Component", group: "UI Customization")
        XCTAssertEqual(redViewAlphaTweak, tweakProvider.tweakWith(feature: Features.uiCustomization, variable: Variables.redViewAlpha))
    }
    
    func testParsesStringTweak() {
        let buttonLabelTweak = Tweak(feature: Features.uiCustomization, variable: Variables.labelText, value: "Test value", title: "Label Text", group: "UI Customization")
        XCTAssertEqual(buttonLabelTweak, tweakProvider.tweakWith(feature: Features.uiCustomization, variable: Variables.labelText))
    }
}
