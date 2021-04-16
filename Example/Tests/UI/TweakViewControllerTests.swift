//
//  TweakViewControllerTests.swift
//  Copyright (c) 2019 Just Eat Holding Ltd. All rights reserved.
//

import XCTest
@testable import JustTweak

class TweakViewControllerTests: XCTestCase {
    
    private var rootWindow: UIWindow!
    private var viewController: TweakViewController!
    private var tweakManager: TweakManager!
    
    override func setUp() {
        super.setUp()
        buildViewControllerWithConfigurationFromFileNamed("test_configuration")
    }
    
    override func tearDown() {
        let mutableConfiguration = tweakManager.mutableConfiguration!
        mutableConfiguration.deleteValue(feature: "feature_1", variable: "variable_1")
        viewController = nil
        
        let rootViewController = rootWindow!.rootViewController!
        rootViewController.viewWillDisappear(false)
        rootViewController.viewDidDisappear(false)
        rootWindow.rootViewController = nil
        rootWindow.isHidden = true
        self.rootWindow = nil
        self.viewController = nil
        
        super.tearDown()
    }
    
    // MARK: Generic Data Display
    
    func testHasExpectedNumberOfSections() {
        XCTAssertEqual(2, viewController.numberOfSections(in: viewController.tableView))
    }
    
    func testGroupedTweaksAreDisplayedInTheirOwnSections() {
        XCTAssertEqual(2, viewController.tableView(viewController.tableView, numberOfRowsInSection: 0))
        XCTAssertEqual("General", viewController.tableView(viewController.tableView, titleForHeaderInSection: 0))
        XCTAssertEqual(5, viewController.tableView(viewController.tableView, numberOfRowsInSection: 1))
        XCTAssertEqual("UI Customization", viewController.tableView(viewController.tableView, titleForHeaderInSection: 1))
    }
    
    // MARK: Convenience Methods
    
    func testReturnsCorrectIndexPathForTweak_WhenTweakFound() {
        let indexPath = viewController.indexPathForTweak(with: Features.UICustomization, variable: Variables.displayGreenView)!
        let expectedIndexPath = IndexPath(row: 0, section: 1)
        XCTAssertEqual(indexPath, expectedIndexPath)
    }
    
    func testReturnsCorrectIndexPathForTweak_WhenTweakFound_2() {
        let indexPath = viewController.indexPathForTweak(with: Features.UICustomization, variable: Variables.displayRedView)!
        let expectedIndexPath = IndexPath(row: 1, section: 1)
        XCTAssertEqual(indexPath, expectedIndexPath)
    }
    
    func testReturnsCorrectIndexPathForTweak_WhenTweakFound_3() {
        let indexPath = viewController.indexPathForTweak(with: Features.UICustomization, variable: Variables.displayYellowView)!
        let expectedIndexPath = IndexPath(row: 2, section: 1)
        XCTAssertEqual(indexPath, expectedIndexPath)
    }
    
    // MARK: Tweak Cells Display
    
    func testReturnsCorrectIndexPathForTweak_WhenTweakNotFound() {
        let indexPath = viewController.indexPathForTweak(with: Features.general, variable: "some_nonexisting_tweak")
        XCTAssertNil(indexPath)
    }
    
    func testDisplaysTweakOn_IfEnabled() {
        let indexPath = viewController.indexPathForTweak(with: Features.UICustomization, variable: Variables.displayYellowView)!
        let cell = viewController.tableView(viewController.tableView, cellForRowAt: indexPath) as! BooleanTweakTableViewCell
        XCTAssertFalse(cell.switchControl.isOn)
    }
    
    func testDisplaysTweakOff_IfDisabled() {
        let indexPath = viewController.indexPathForTweak(with: Features.UICustomization, variable: Variables.displayRedView)!
        let cell = viewController.tableView(viewController.tableView, cellForRowAt: indexPath) as! BooleanTweakTableViewCell
        XCTAssertTrue(cell.switchControl.isOn)
    }
    
    func testDisplaysTweakTitle_ForTweakThatHaveIt() {
        let indexPath = viewController.indexPathForTweak(with: Features.UICustomization, variable: Variables.displayRedView)!
        let cell = viewController.tableView(viewController.tableView, cellForRowAt: indexPath)
        XCTAssertEqual(cell.textLabel?.text, "Display Red View")
        XCTAssertEqual((cell as! TweakViewControllerCell).title, "Display Red View")
    }
    
    func testDisplaysNumericTweaksCorrectly() {
        let indexPath = viewController.indexPathForTweak(with: Features.UICustomization, variable: Variables.redViewAlpha)!
        let cell = viewController.tableView(viewController.tableView, cellForRowAt: indexPath) as? NumericTweakTableViewCell
        XCTAssertEqual(cell?.title, "Red View Alpha Component")
        XCTAssertEqual(cell?.textField.text, "1.0")
    }
    
    func testDisplaysTextTweaksCorrectly() {
        let indexPath = viewController.indexPathForTweak(with: Features.UICustomization, variable: Variables.labelText)!
        let cell = viewController.tableView(viewController.tableView, cellForRowAt: indexPath)  as? TextTweakTableViewCell
        XCTAssertEqual(cell?.title, "Label Text")
        XCTAssertEqual(cell?.textField.text, "Test value")
    }
    
    // MARK: Cells Actions
    
    func testUpdatesValueOfTweak_WhenUserTooglesSwitchOnBooleanCell() {
        viewController.beginAppearanceTransition(true, animated: false)
        viewController.endAppearanceTransition()
        
        let indexPath = viewController.indexPathForTweak(with: Features.UICustomization, variable: Variables.displayYellowView)!
        let cell = viewController.tableView.cellForRow(at: indexPath) as! BooleanTweakTableViewCell
        cell.switchControl.isOn = true
        cell.switchControl.sendActions(for: .valueChanged)
        XCTAssertTrue(tweakManager.tweakWith(feature: Features.UICustomization, variable: Variables.displayYellowView)!.boolValue)
    }
    
    // MARK: Other Actions
    
    func testAsksToBeDismissedWhenDoneButtonIsTapped() {
        class FakeViewController: TweakViewController {
            fileprivate let mockPresentingViewController = MockPresentingViewController()
            override var presentingViewController: UIViewController? {
                get {
                    return mockPresentingViewController
                }
            }
        }
        let vc = FakeViewController(style: .grouped, tweakManager: tweakManager)
        vc.dismissViewController()
        XCTAssertTrue(vc.mockPresentingViewController.didCallDismissal)
    }
    
    // MARK: Helpers
    
    private func buildViewControllerWithConfigurationFromFileNamed(_ fileName: String) {
        let bundle = Bundle(for: TweakViewControllerTests.self)
        let jsonURL = bundle.url(forResource: fileName, withExtension: "json")
        let localConfiguration = LocalConfiguration(jsonURL: jsonURL!)
        let userDefaults = UserDefaults(suiteName: "com.JustTweaks.Tests\(NSDate.timeIntervalSinceReferenceDate)")!
        let userDefaultsConfiguration = UserDefaultsConfiguration(userDefaults: userDefaults)
        let configurations: [Configuration] = [userDefaultsConfiguration, localConfiguration]
        tweakManager = TweakManager(configurations: configurations)
        viewController = TweakViewController(style: .plain, tweakManager: tweakManager)
        
        rootWindow = UIWindow(frame: UIScreen.main.bounds)
        rootWindow.makeKeyAndVisible()
        rootWindow.isHidden = false
        rootWindow.rootViewController = viewController
        _ = viewController.view
        viewController.viewWillAppear(false)
        viewController.viewDidAppear(false)
    }
}
