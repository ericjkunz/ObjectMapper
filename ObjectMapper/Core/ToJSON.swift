//
//  ToJSON.swift
//  ObjectMapper
//
//  Created by Tristan Himmelman on 2014-10-13.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014-2015 Hearst
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import class Foundation.NSNumber

private func setValue(_ value: AnyObject, map: Map) {
	setValue(value, key: map.currentKey!, checkForNestedKeys: map.keyIsNested, dictionary: &map.JSONDictionary)
}

private func setValue(_ value: AnyObject, key: String, checkForNestedKeys: Bool, dictionary: inout [String : AnyObject]) {
	if checkForNestedKeys {
		let keyComponents = ArraySlice(key.characters.split { $0 == "." })
		setValue(value, forKeyPathComponents: keyComponents, dictionary: &dictionary)
	} else {
		dictionary[key] = value
	}
}

private func setValue(_ value: AnyObject, forKeyPathComponents components: ArraySlice<String.CharacterView.SubSequence>, dictionary: inout [String : AnyObject]) {
	if components.isEmpty {
		return
	}
	
	let head = components.first!
	
	if components.count == 1 {
		dictionary[String(head)] = value
	} else {
		var child = dictionary[String(head)] as? [String : AnyObject]
		if child == nil {
			child = [:]
		}
		
		let tail = components.dropFirst()
		setValue(value, forKeyPathComponents: tail, dictionary: &child!)
		
		dictionary[String(head)] = child as AnyObject
	}
}

internal final class ToJSON {
	
	class func basicType<N>(_ field: N, map: Map) {
		let x = field as AnyObject
		if false
			|| x is NSNumber // Basic types
			|| x is Bool
			|| x is Int
			|| x is Double
			|| x is Float
			|| x is String
			|| x is Array<NSNumber> // Arrays
			|| x is Array<Bool>
			|| x is Array<Int>
			|| x is Array<Double>
			|| x is Array<Float>
			|| x is Array<String>
			|| x is Array<AnyObject>
			|| x is Array<Dictionary<String, AnyObject>>
			|| x is Dictionary<String, NSNumber> // Dictionaries
			|| x is Dictionary<String, Bool>
			|| x is Dictionary<String, Int>
			|| x is Dictionary<String, Double>
			|| x is Dictionary<String, Float>
			|| x is Dictionary<String, String>
			|| x is Dictionary<String, AnyObject>
		{
			setValue(x, map: map)
		}
	}
	
	class func optionalBasicType<N>(_ field: N?, map: Map) {
		if let field = field {
			basicType(field, map: map)
		}
	}
	
	class func object<N: Mappable>(_ field: N, map: Map) {
		let m = Mapper<N>(context: map.context)
		let j = m.toJSON(field) as AnyObject
		setValue(j, map: map)
	}
	
	class func optionalObject<N: Mappable>(_ field: N?, map: Map) {
		if let field = field {
			object(field, map: map)
		}
	}
	
	class func objectArray<N: Mappable>(_ field: Array<N>, map: Map) {
		let JSONObjects = Mapper(context: map.context).toJSONArray(field)
		
		setValue(JSONObjects as AnyObject, map: map)
	}
	
	class func optionalObjectArray<N: Mappable>(_ field: Array<N>?, map: Map) {
		if let field = field {
			objectArray(field, map: map)
		}
	}
	
	class func twoDimensionalObjectArray<N: Mappable>(_ field: Array<Array<N>>, map: Map) {
		var array = [[[String : AnyObject]]]()
		for innerArray in field {
			let JSONObjects = Mapper(context: map.context).toJSONArray(innerArray)
			array.append(JSONObjects)
		}
		setValue(array as AnyObject, map: map)
	}
	
	class func optionalTwoDimensionalObjectArray<N: Mappable>(_ field: Array<Array<N>>?, map: Map) {
		if let field = field {
			twoDimensionalObjectArray(field, map: map)
		}
	}
	
	class func objectSet<N: Mappable>(_ field: Set<N>, map: Map) where N: Hashable {
		let JSONObjects = Mapper(context: map.context).toJSONSet(field)
		
		setValue(JSONObjects as AnyObject, map: map)
	}
	
	class func optionalObjectSet<N: Mappable>(_ field: Set<N>?, map: Map) where N: Hashable {
		if let field = field {
			objectSet(field, map: map)
		}
	}
	
	class func objectDictionary<N: Mappable>(_ field: Dictionary<String, N>, map: Map) {
		let JSONObjects = Mapper(context: map.context).toJSONDictionary(field)
		
		setValue(JSONObjects as AnyObject, map: map)
	}
	
	class func optionalObjectDictionary<N: Mappable>(_ field: Dictionary<String, N>?, map: Map) {
		if let field = field {
			objectDictionary(field, map: map)
		}
	}
	
	class func objectDictionaryOfArrays<N: Mappable>(_ field: Dictionary<String, [N]>, map: Map) {
		let JSONObjects = Mapper(context: map.context).toJSONDictionaryOfArrays(field)
		
		setValue(JSONObjects as AnyObject, map: map)
	}
	
	class func optionalObjectDictionaryOfArrays<N: Mappable>(_ field: Dictionary<String, [N]>?, map: Map) {
		if let field = field {
			objectDictionaryOfArrays(field, map: map)
		}
	}
}
