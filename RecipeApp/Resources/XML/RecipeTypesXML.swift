//
//  RecipeTypesXML.swift
//  RecipeApp
//
//  Created by Scott.L on 16/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//

import Foundation

class RecipeTypeXML: NSObject, XMLParserDelegate {
    
    var recipeTypes: [RecipeType] = []
    
    private var typeName: String = ""
    private var title: String = ""
    
    enum Value: String {
        case typeName = "type"
        case title = "title"
    }
    
    init(contentsOf path: URL) {
        super.init()
        guard let parser = XMLParser(contentsOf: path) else {
            return
        }
        parser.delegate = self
        parser.parse()
    }
    
}

extension RecipeTypeXML {
    
    func parser(_ parser: XMLParser, didEndElement typeName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        guard typeName == Value.typeName.rawValue else {
            return
        }
        let type = RecipeType(title: title)
        recipeTypes.append(type)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard data.isEmpty == false, self.typeName == Value.title.rawValue  else {
            return
        }
        title += data
        
    }
    
    func parser(_ parser: XMLParser, didStartElement typeName: String,
                namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        guard typeName == Value.typeName.rawValue else {
            return self.typeName = typeName
        }
        title = String()
    }
    
}
