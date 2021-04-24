//
//  main.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation
import ArgumentParser

struct TweakAccessorGenerator: ParsableCommand {
    
    @Option(name: .shortAndLong, help: "The local tweaks file path.")
    var localTweaksFilePath: String
    
    @Option(name: .shortAndLong, help: "The output folder.")
    var outputFolder: String
    
    @Option(name: .shortAndLong, help: "The configuration folder.")
    var configurationFolder: String
    
    private var tweaksFilename: String {
        let url = URL(fileURLWithPath: localTweaksFilePath)
        return String(url.lastPathComponent.split(separator: ".").first!)
    }
    
    private var configurationFolderURL: URL {
        URL(fileURLWithPath: configurationFolder)
    }
    
    private func loadConfigurationFromJson() -> Configuration {
        let configurationUrl = configurationFolderURL.appendingPathComponent("config.json")
        let jsonData = try! Data(contentsOf: configurationUrl)
        let decodedResult = try! JSONDecoder().decode(Configuration.self, from: jsonData)
        return decodedResult
    }
    
    private func loadCustomTweakProvidersCode() -> [Filename: CodeBlock] {
        let configuration = loadConfigurationFromJson()
        let customTweakProviders = configuration.tweakProviders.filter { $0.type == "CustomTweakProvider" } // costantise
        let filenameReferences = customTweakProviders.map { $0.parameter! }
        
        var customTweakProvidersCode: [Filename: CodeBlock] = [:]
        for reference in filenameReferences {
            let configurationUrl = configurationFolderURL.appendingPathComponent(reference)
            let content = try! String(contentsOf: configurationUrl)
            customTweakProvidersCode[reference] = content
        }
        return customTweakProvidersCode
    }
    
    func run() throws {
        let codeGenerator = TweakAccessorCodeGenerator()
        let tweakLoader = TweakLoader()
        let tweaks = try tweakLoader.load(localTweaksFilePath)
        let configuration = loadConfigurationFromJson()
        let customTweakProvidersSetupCode = loadCustomTweakProvidersCode()
        
        writeConstantsFile(codeGenerator: codeGenerator,
                           tweaks: tweaks,
                           outputFolder: outputFolder,
                           configuration: configuration)
        
        writeAccessorFile(codeGenerator: codeGenerator,
                          tweaks: tweaks,
                          outputFolder: outputFolder,
                          configuration: configuration,
                          customTweakProvidersSetupCode: customTweakProvidersSetupCode)
    }
}

extension TweakAccessorGenerator {
    
    private func writeConstantsFile(codeGenerator: TweakAccessorCodeGenerator,
                                    tweaks: [Tweak],
                                    outputFolder: String,
                                    configuration: Configuration) {
        let fileName = "\(configuration.accessorName)+Constants.swift"
        let url: URL = URL(fileURLWithPath: outputFolder).appendingPathComponent(fileName)
        let constants = codeGenerator.generateConstantsFileContent(tweaks: tweaks,
                                                                   configuration: configuration)
        try! constants.write(to: url, atomically: true, encoding: .utf8)
    }
    
    private func writeAccessorFile(codeGenerator: TweakAccessorCodeGenerator,
                                   tweaks: [Tweak],
                                   outputFolder: String,
                                   configuration: Configuration,
                                   customTweakProvidersSetupCode: [Filename: CodeBlock]) {
        let fileName = "\(configuration.accessorName).swift"
        let url: URL = URL(fileURLWithPath: outputFolder).appendingPathComponent(fileName)
        let constants = codeGenerator.generateAccessorFileContent(tweaksFilename: tweaksFilename,
                                                                  tweaks: tweaks,
                                                                  configuration: configuration,
                                                                  customTweakProvidersSetupCode: customTweakProvidersSetupCode)
        try! constants.write(to: url, atomically: true, encoding: .utf8)
    }
}

TweakAccessorGenerator.main()
