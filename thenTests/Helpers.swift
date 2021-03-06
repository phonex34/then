//
//  Helpers.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 08/08/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import XCTest
import then
import Dispatch

var globalCount = 0
var blockPromiseCExpectation: XCTestExpectation!

func promiseA() -> Promise<Int> {
    return Promise { resolve, _ in
        XCTAssertTrue(globalCount == 0)
        globalCount+=1
        resolve(globalCount)
    }
}

func promiseB() -> Promise<Int> {
    return Promise { resolve, _ in
        XCTAssertTrue(globalCount == 1)
        globalCount+=1
        resolve(globalCount)
    }
}

func promiseC() -> Promise<Int> {
    return Promise { resolve, _ in
        XCTAssertTrue(globalCount == 2)
        globalCount+=1
        resolve(globalCount)
        blockPromiseCExpectation.fulfill()
        
    }
}

func promise1() -> Promise<Int> {
    return Promise.resolve(1)
}

func promise2() -> Promise<Int> {
    return Promise.resolve(2)
}

func promise3() -> Promise<Int> {
    return Promise.resolve(3)
}

func promiseArray1() -> Promise<[Int]> {
    return Promise.resolve([1, 2, 3])
}

func promiseArray2() -> Promise<[Int]> {
    return Promise.resolve([4, 5, 6])
}

func promiseArray3() -> Promise<[Int]> {
    return Promise.resolve([7, 8, 9])
}

func syncRejectionPromise() -> Promise<Int> {
    return Promise.reject(MyError.defaultError)
}

func fetchUserId() -> Promise<Int> {
    return Promise { resolve, _ in
        print("fetching user Id ...")
        testWait {
            resolve(1234)
            print("GOT USER ID 1234")
        }
    }
}

func fetchUserNameFromId(_ identifier: Int) -> Promise<String> {
    return Promise { resolve, _ in
        print("fetching UserName FromId : \(identifier) ...")
        testWait { resolve("John Smith") }
    }
}

func fetchUserFollowStatusFromName(_ name: String) -> Promise<Bool> {
    return Promise { resolve, _ in
        print("fetchUserFollowStatusFromName: \(name) ...")
        testWait { resolve(false) }
    }
}

func failingFetchUserFollowStatusFromName(_ name: String) -> Promise<Bool> {
    return Promise { _, reject in
        print("fetchUserFollowStatusFromName: \(name) ...")
        testWait { reject(MyError.defaultError) }
    }
}

func testWait(_ callback:@escaping () -> Void) {
    let delay = 0.1 * Double(NSEC_PER_SEC)
    let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
    DispatchQueue.global(qos: DispatchQoS.QoSClass.background).asyncAfter(deadline: time) {
        callback()
    }
}

func testWait(_ time: Double, callback: @escaping () -> Void) {
    let delay = time * Double(NSEC_PER_SEC)
    let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time) {
        callback()
    }
}

func upload() -> Promise<Void> {
    return Promise<Void> { resolve, _, progress in
        testWait {
            progress(0.8)
            testWait {
                resolve()
            }
        }
    }
}

func failingUpload() -> Promise<Void> {
    return Promise<Void> { _, reject, progress in
        testWait {
            progress(0.8)
            testWait {
                reject(NSError(domain: "", code: 1223, userInfo: nil))
            }
        }
    }
}

enum MyError: Error {
    case defaultError
}
