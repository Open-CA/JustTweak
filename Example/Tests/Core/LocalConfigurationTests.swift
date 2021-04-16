//
//  LocalConfigurationTests.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import XCTest
import JustTweak

class LocalConfigurationTests: XCTestCase {
    
    var configuration: LocalConfiguration!
    
    override func setUp() {
        super.setUp()
        configuration = configurationWithFileNamed("test_configuration")!
    }
    
    override func tearDown() {
        configuration = nil
        super.tearDown()
    }
    
    private func configurationWithFileNamed(_ fileName: String) -> LocalConfiguration? {
        let bundle = Bundle(for: LocalConfigurationTests.self)
        let jsonURL = bundle.url(forResource: fileName, withExtension: "json")!
        return LocalConfiguration(jsonURL: jsonURL)
    }
    
    func testParsesBoolTweak() {
        let redViewTweak = Tweak(feature: Features.UICustomization, variable: Variables.displayRedView, value: true, title: "Display Red View", group: "UI Customization")
        XCTAssertEqual(redViewTweak, configuration.tweakWith(feature: Features.UICustomization, variable: Variables.displayRedView))
    }
    
    func testParsesFloatTweak() {
        let redViewAlphaTweak = Tweak(feature: Features.UICustomization, variable: Variables.redViewAlpha, value: 1.0, title: "Red View Alpha Component", group: "UI Customization")
        XCTAssertEqual(redViewAlphaTweak, configuration.tweakWith(feature: Features.UICustomization, variable: Variables.redViewAlpha))
    }
    
    func testParsesStringTweak() {
        let buttonLabelTweak = Tweak(feature: Features.UICustomization, variable: Variables.labelText, value: "Test value", title: "Label Text", group: "UI Customization")
        XCTAssertEqual(buttonLabelTweak, configuration.tweakWith(feature: Features.UICustomization, variable: Variables.labelText))
    }
}
