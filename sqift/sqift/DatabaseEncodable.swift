//
//  DatabaseEncodable.swift
//  sqift
//
//  Created by Dave Camp on 3/21/15.
//  Copyright (c) 2015 thinbits. All rights reserved.
//

import Foundation

public protocol DatabaseEncodable
{
    /// Table name of this class
    static var tableName: String { get }
    
    /// Column definitions for this class
    static var columnDefinitions: [Column] { get }
    
    /// Object properites turned into an array of values corresponding in table column order
    var columnValues: [Any] { get }
    
    /**
    <#Description#>
    
    :param: statement <#statement description#>
    
    :returns: <#return value description#>
    */
    static func objectFromStatement(statement: Statement) -> DatabaseEncodable?
}

public extension Database
{
    /**
    Create a table based on an encodable class
    
    :param: encodable Class to use as a template
    
    :returns: Result
    */
    public func createTable<T: DatabaseEncodable>(encodable: T.Type) -> DatabaseResult
    {
        return createTable(T.tableName, columns: T.columnDefinitions)
    }
    
    /**
    Insert a row with an encodable object
    
    :param: encodable Class to encode
    :param: instance  Instance of object to encode
    
    :returns: Result
    */
    public func insertRowIntoTable<T: DatabaseEncodable>(encodable: T.Type, _ instance: T) -> DatabaseResult
    {
        return insertRowIntoTable(encodable.tableName, values: instance.columnValues)
    }
}

public extension Statement
{
    /**
    Create an object for the current row
    
    :param: objectClass Class to create from the current row
    
    :returns: Object created or nil
    */
    public func objectForRow<T: DatabaseEncodable>(objectClass: T.Type) -> T?
    {
        return objectClass.objectFromStatement(self) as? T
    }
    
    /**
    Create an array of objects for all rows
    
    :param: objectClass Object class to return
    
    :returns: Array of objects
    */
    public func objectsForRows<T: DatabaseEncodable>(objectClass: T.Type) -> [T]
    {
        var objects = [T]()
        while step() == .More
        {
            if let object = objectForRow(T)
            {
                objects.append(object)
            }
        }
        return objects
    }
}