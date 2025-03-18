//
//  XMLDoc.swift
//  TVRemote3
//
//  Created by MK on 2025/3/18.
//

import Foundation
import libxml2

// MARK: - XMLDoc

open class XMLDoc {
    private var doc: xmlDocPtr?

    public init?(xmlString: String) {
        guard let cString = xmlString.cString(using: .utf8) else { return nil }
        doc = xmlParseMemory(cString, Int32(cString.count))
        if doc == nil { return nil }
    }

    public init?(xmlData: Data) {
        let bytes = xmlData.withUnsafeBytes { $0.baseAddress }
        doc = xmlParseMemory(bytes?.assumingMemoryBound(to: Int8.self), Int32(xmlData.count))
        if doc == nil { return nil }
    }

    deinit {
        if doc != nil {
            xmlFreeDoc(doc)
        }
    }

    public func query(xpath: String, withChild: Bool) -> [Node] {
        guard let doc else { return [] }
        let context = xmlXPathNewContext(doc)
        defer { xmlXPathFreeContext(context) }

        guard let result = xmlXPathEvalExpression(xpath, context) else { return [] }
        defer { xmlXPathFreeObject(result) }

        var nodes: [Node] = []
        if let nodeset = result.pointee.nodesetval {
            for i in 0 ..< Int(nodeset.pointee.nodeNr) {
                if let node = nodeset.pointee.nodeTab[i] {
                    nodes.append(parseNode(node, withChild: withChild))
                }
            }
        }
        return nodes
    }

    private func parseNode(_ node: xmlNodePtr, withChild: Bool) -> Node {
        let name = String(cString: node.pointee.name)
        var attributes: [String: String] = [:]
        var children: [Node] = []
        var content = ""

        var attr = node.pointee.properties
        while attr != nil {
            if let name = attr?.pointee.name,
               let value = xmlGetProp(node, name)
            {
                attributes[String(cString: name)] = String(cString: value)
                xmlFree(value)
            }
            attr = attr?.pointee.next
        }

        if withChild {
            var child = node.pointee.children
            while child != nil {
                if child?.pointee.type == XML_TEXT_NODE {
                    if let text = xmlNodeGetContent(child) {
                        content += String(cString: text)
                        xmlFree(text)
                    }
                } else if let childNode = child {
                    children.append(parseNode(childNode, withChild: withChild))
                }
                child = child?.pointee.next
            }
        } else {
            if let text = xmlNodeGetContent(node) {
                content = String(cString: text)
                xmlFree(text)
            }
        }

        return Node(name: name, attributes: attributes, children: children, text: content)
    }
}

// MARK: XMLDoc.Node

public extension XMLDoc {
    struct Node {
        public let name: String
        public let attributes: [String: String]
        public let children: [Node]
        public let text: String
    }
}
