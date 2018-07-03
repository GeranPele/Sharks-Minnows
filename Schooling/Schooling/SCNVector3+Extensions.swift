//
//  SCNVector3+Extensions.swift
//  Sharks&Minnows2.0
//
//  Created by Geran Pele on 6/1/18.
//  Copyright © 2018 Geran Pele. All rights reserved.
//

import Foundation
import CoreGraphics
import SceneKit

import Foundation
import CoreGraphics
import SceneKit

//Cross reference the math here with my own SCNVector3 extension!

extension SCNVector3 {
    
    /**
     Inverts vector
     */
    mutating func invert() -> SCNVector3 {
        return self * -1
    }
    
    /**
     Calculates vector length based on Pythagoras theorem
     */
    var length:Float {
        get {
            return sqrtf(x*x + y*y + z*z)
        }
        set {
            self = self.unit * newValue
        }
    }
    
    /**
     Calculate Length Squared of Vector
     - Use this to determine Longest/Shortest vector. Much faster than using v.length
     */
    var lengthSquared:Float {
        get {
            return self.x * self.x + self.y * self.y + self.z * self.z;
        }
    }
    
    /**
     Returns unit vector (aka Normalized Vector)
     - v.length = 1.0
     */
    var unit:SCNVector3 {
        get {
            return self / self.length
        }
    }
    
    /**
     Normalizes vector
     - v.Length = 1.0
     */
    mutating func normalize() {
        self = self.unit
    }
    
    /**
     Calculates distance to vector
     */
    func distance(toVector: SCNVector3) -> Float {
        return (self - toVector).length
    }
    
    
    /**
     Calculates dot product to vector
     */
    func dot(toVector: SCNVector3) -> Float {
        return x * toVector.x + y * toVector.y + z * toVector.z
    }
    
    /**
     Calculates cross product to vector
     */
    func cross(toVector: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(y * toVector.z - z * toVector.y, z * toVector.x - x * toVector.z, x * toVector.y - y * toVector.x)
    }
    
    func magSquare() -> Float{
        //Forcing pemdas:
        return ((x * x) + (y * y) + (z * z))
    }
    
    public mutating func limit(mag: Float){
        
        if magSquare() > (mag * mag){
            normalize()
            x = x * mag
            y = y * mag
            z = z * mag
        }
    }
    
    /**
     Get/Set vector angle on XY axis
     */
    var xyAngle:Float {
        get {
            return atan2(self.y, self.x)
        }
        set {
            let length = self.length
            self.x = cos(newValue) * length
            self.y = sin(newValue) * length
        }
    }
    
    /**
     Get/Set vector angle on XZ axis
     */
    var xzAngle:Float {
        get {
            return atan2(self.z, self.x)
        }
        set {
            let length = self.length
            self.x = cos(newValue) * length
            self.z = sin(newValue) * length
        }
    }
}


// SCNVector Operators

/**
 v1 = v2 + v3
 */
func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

/**
 v1 += v2
 */
func +=( left: inout SCNVector3, right: SCNVector3) {
    left = left + right
}

/**
 v1 = v2 - v3
 */
func -(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

/**
 v1 -= v2
 */
func -=( left: inout SCNVector3, right: SCNVector3) {
    left = left - right
}

/**
 v1 = v2 * v3
 */
func *(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x * right.x, left.y * right.y, left.z * right.z)
}

/**
 v1 *= v2
 */
func *=( left: inout SCNVector3, right: SCNVector3) {
    left = left * right
}

/**
 v1 = v2 * x
 */
func *(left: SCNVector3, right: Float) -> SCNVector3 {
    return SCNVector3Make(left.x * right, left.y * right, left.z * right)
}

/**
 v *= x
 */
func *=( left: inout SCNVector3, right: Float) {
    left = SCNVector3Make(left.x * right, left.y * right, left.z * right)
}

/**
 v1 = v2 / v3
 */
func /(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x / right.x, left.y / right.y, left.z / right.z)
}

/**
 v1 /= v2
 */
func /=( left: inout SCNVector3, right: SCNVector3) {
    left = SCNVector3Make(left.x / right.x, left.y / right.y, left.z / right.z)
}

/**
 v1 = v2 / x
 */
func /(left: SCNVector3, right: Float) -> SCNVector3 {
    return SCNVector3Make(left.x / right, left.y / right, left.z / right)
}

/**
 v /= x
 */
func /=( left: inout SCNVector3, right: Float) {
    left = SCNVector3Make(left.x / right, left.y / right, left.z / right)
}

/**
 v = -v
 */
prefix func -(v: SCNVector3) -> SCNVector3 {
    return v * -1
}





