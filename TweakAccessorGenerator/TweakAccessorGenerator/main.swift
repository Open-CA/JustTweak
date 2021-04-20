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
    
    @Option(name: .shortAndLong, help: "The configuration file path.")
    var configurationFilePath: String
    
    private var tweaksFilename: String {
        let url = URL(fileURLWithPath: localTweaksFilePath)
        return String(url.lastPathComponent.split(separator: ".").first!)
    }
    
    private func loadConfigurationFromJson() -> Configuration {
        let url = URL(fileURLWithPath: configurationFilePath)
        let jsonData = try! Data(contentsOf: url)
        let decodedResult = try! JSONDecoder().decode(Configuration.self, from: jsonData)
        return decodedResult
    }
    
    func run() throws {
        let codeGenerator = TweakAccessorCodeGenerator()
        let tweakLoader = TweakLoader()
        let tweaks = try tweakLoader.load(localTweaksFilePath)
        let configuration = loadConfigurationFromJson()
        
        writeConstantsFile(codeGenerator: codeGenerator,
                           tweaks: tweaks,
                           outputFolder: outputFolder,
                           configuration: configuration)
        
        writeAccessorFile(codeGenerator: codeGenerator,
                          tweaks: tweaks,
                          outputFolder: outputFolder,
                          configuration: configuration)
    }
}

extension TweakAccessorGenerator {
    
    private func writeAccessorFile(codeGenerator: TweakAccessorCodeGenerator,
                                   tweaks: [Tweak],
                                   outputFolder: String,
                                   configuration: Configuration) {
        let fileName = "\(configuration.accessorName).swift"
        let url: URL = URL(fileURLWithPath: outputFolder).appendingPathComponent(fileName)
        let constants = codeGenerator.generateAccessorFileContent(tweaksFilename: tweaksFilename,
                                                                  tweaks: tweaks,
                                                                  configuration: configuration)
        try! constants.write(to: url, atomically: true, encoding: .utf8)
    }
    
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
}

TweakAccessorGenerator.main()
