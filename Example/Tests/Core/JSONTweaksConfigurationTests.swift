
import XCTest
import JustTweak

class JSONTweaksConfigurationTests: XCTestCase {
    
    var configuration: JSONTweaksConfiguration!
    
    override func setUp() {
        super.setUp()
        configuration = configurationWithFileNamed("test_configuration")!
    }
    
    override func tearDown() {
        configuration = nil
        super.tearDown()
    }
    
    private func configurationWithFileNamed(_ fileName: String) -> JSONTweaksConfiguration? {
        let bundle = Bundle(for: JSONTweaksConfigurationTests.self)
        let jsonURL = bundle.url(forResource: fileName, withExtension: "json")!
        return JSONTweaksConfiguration(jsonURL: jsonURL)
    }
    
    func testGetsNilInitialized_IfURLContainsNoData() {
        let fileURL = URL(fileURLWithPath: "/none")
        XCTAssertNil(JSONTweaksConfiguration(jsonURL: fileURL))
    }
    
    func testGetsNilInitialized_IfJSONIsInvalid() {
        XCTAssertNil(configurationWithFileNamed("test_configuration_invalid"))
    }
    
    func testParsesBoolTweak() {
        let redViewTweak = Tweak(feature: Features.UICustomization.rawValue, variable: Variables.DisplayRedView.rawValue, value: true, title: "Display Red View", group: "UI Customization")
        XCTAssertEqual(redViewTweak, configuration.tweakWith(feature: Features.UICustomization.rawValue, variable: Variables.DisplayRedView.rawValue))
    }
    
    func testParsesFloatTweak() {
        let redViewAlphaTweak = Tweak(feature: Features.UICustomization.rawValue, variable: Variables.RedViewAlpha.rawValue, value: 1.0, title: "Red View Alpha Component", group: "UI Customization")
        XCTAssertEqual(redViewAlphaTweak, configuration.tweakWith(feature: Features.UICustomization.rawValue, variable: Variables.RedViewAlpha.rawValue))
    }
    
    func testParsesStringTweak() {
        let buttonLabelTweak = Tweak(feature: Features.UICustomization.rawValue, variable: Variables.ChangeConfigurationButton.rawValue, value: "Change Configuration", title: "Change Tweaks Button Label Text", group: "UI Customization")
        XCTAssertEqual(buttonLabelTweak, configuration.tweakWith(feature: Features.UICustomization.rawValue, variable: Variables.ChangeConfigurationButton.rawValue))
    }
}
