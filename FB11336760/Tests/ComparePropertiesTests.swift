//
//  ComparePropertiesTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 7/28/22.
//

import MirrorExample
import XCTest


class ComparePropertiesTests : XCTestCase {
    
    func test_mirror_performance() {
        
        print("Compare based on properties...")
        
        determineAverage(for: 1.0) {
            _ = compareEquatableProperties(
                TestValue(
                    title: "A Title",
                    count: 10,
                    enumValue: .foo,
                    closure: {}
                ),
                TestValue(
                    title: "A Title",
                    count: 10,
                    enumValue: .foo,
                    closure: {}
                )
            )
        }
        
        print("Compare based on properties, removing enum...")
        
        determineAverage(for: 1.0) {
            _ = compareEquatableProperties(
                TestValue.ButNoEnums(
                    title: "A Title",
                    count: 10,
                    closure: {}
                ),
                TestValue.ButNoEnums(
                    title: "A Title",
                    count: 10,
                    closure: {}
                )
            )
        }
    }
    
    func test_synthesized_performance() {
        
        print("Compare based on synthesized Equatable implementation...")

        determineAverage(for: 1.0) {
            _ = compareEquatableProperties(
                TestValue.ButEquatable(
                    title: "A Title",
                    count: 10,
                    enumValue: .foo
                ),
                TestValue.ButEquatable(
                    title: "A Title",
                    count: 10,
                    enumValue: .foo
                )
            )
        }
    }
}


fileprivate struct TestValue {
    
    var title : String
    var detail : String?
    var count : Int
    
    var enumValue : EnumValue
    
    var nonEquatable: NonEquatableValue = .init(value: "An inner string")
    
    var closure : () -> ()
    
    enum EnumValue : Equatable {
        case foo
        case bar(String)
    }
    
    /// Removing enums
    
    fileprivate struct ButNoEnums {
        
        var title : String
        var detail : String?
        var count : Int
        
        var nonEquatable: EquatableValue = .init(value: "An inner string")
        
        var closure : () -> ()
        
        fileprivate struct EquatableValue : Equatable {
            
            var value : AnyHashable
        }
    }
    
    /// Mirrors the structure of the parent type but with a synthesized `Equatable`
    /// implementation to compare performance.
    
    fileprivate struct ButEquatable : Equatable {
        
        var title : String
        var detail : String?
        var count : Int
        
        var enumValue : EnumValue
        
        var nonEquatable: EquatableValue = .init(value: "An inner string")
        
        enum EnumValue : Equatable {
            case foo
            case bar(String)
        }
        
        fileprivate struct EquatableValue : Equatable {
            
            var value : AnyHashable
        }
    }
}


fileprivate struct NonEquatableValue {
    
    var value : Any
}
