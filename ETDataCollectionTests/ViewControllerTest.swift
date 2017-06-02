import XCTest
@testable import ETDataCollection

class MockNSCoder : NSCoder {

    override func version(forClassName className: String) -> Int {
        return 0
    }
    
    override func decodeObject(forKey key: String) -> Any? {
        return nil
    }
    
    override func decodeBool(forKey key: String) -> Bool {
        return false
    }
    
    override func containsValue(forKey key: String) -> Bool {
        return false
    }
}

class ViewControllerTest: XCTestCase {
    
    func testConstructorShallCreateAnInstance() {
        let mockNSCoder = MockNSCoder.init()
        
        // ~given
        var controller:ViewController? = nil
        
        // ~when
        controller = ViewController.init(coder: mockNSCoder)

        // ~then
        XCTAssert(controller != nil)
    }
}
