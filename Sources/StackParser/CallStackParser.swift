import Foundation

public class CallStackParser {
    
    private static func cleanMethod(method: String) -> String {
        var result = method
        if method.count > 1 {
            let char: Character = method[method.startIndex]
            if char == "(" {
                result = String(result[result.startIndex...])
            }
        }
        if !result.hasSuffix(")") {
            result = result + ")"
        }
        
        return method
    }
    
    /**
     Takes a specific item from 'NSThread.callStackSymbols()' and returns the class and method call contained within.
     
     - Parameter stackSymbol: a specific item from 'NSThread.callStackSymbols()'
     - Parameter includeImmediateParentClass: Whether or not to include the parent class in an innerclass situation.
     
     - Returns: a tuple containing the (class,method) or nil if it could not be parsed
     */
    public static func classAndMethod(forStackSymbol stackSymbol: String, includeImmediateParentClass: Bool? = false) -> (klass: String, method: String)? {
        let replaced = stackSymbol.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression, range: nil)
        let components = replaced.split(separator: " ")
        if (components.count >= 4) {
            guard var packageClassAndMethodStr = try? parseMangledSwiftSymbol(String(components[3])).description else {
                return nil
            }
            
            packageClassAndMethodStr = packageClassAndMethodStr.replacingOccurrences(
                of: "\\s+",
                with: " ",
                options: .regularExpression,
                range: nil
            )
            let packageComponent = String(packageClassAndMethodStr.split(separator: " ").first ?? "")
            let packageClassAndMethod = packageComponent.split(separator: ".")
            let numberOfComponents = packageClassAndMethod.count
            if (numberOfComponents >= 2) {
                let method = cleanMethod(method: String(packageClassAndMethod[numberOfComponents - 1]))
                if includeImmediateParentClass != nil {
                    if (includeImmediateParentClass == true && numberOfComponents >= 4) {
                        return (packageClassAndMethod[numberOfComponents - 3] + "." + packageClassAndMethod[numberOfComponents - 2], method)
                    }
                }
                return (String(packageClassAndMethod[numberOfComponents - 2]), method)
            }
        }
        
        return nil
    }
    
    /**
     Analyzies the 'NSThread.callStackSymbols()' and returns the calling class and method in the scope of the caller.
     
     - Parameter includeImmediateParentClass: Whether or not to include the parent class in an innerclass situation.
     
     - Returns: a tuple containing the (class,method) or nil if it could not be parsed
     */
    public static func callingClassAndMethodInScope(includeImmediateParentClass: Bool? = false) -> (klass: String, method: String)? {
        let stackSymbols = Thread.callStackSymbols
        if (stackSymbols.count >= 3) {
            return classAndMethod(forStackSymbol: stackSymbols[2], includeImmediateParentClass: includeImmediateParentClass)
        }
        return nil
    }
    
    /**
     Analyzies the 'NSThread.callStackSymbols()' and returns the current class and method in the scope of the caller.
     
     - Parameter includeImmediateParentClass: Whether or not to include the parent class in an innerclass situation.
     
     - Returns: a tuple containing the (class,method) or nil if it could not be parsed
     */
    public static func thisClassAndMethodInScope(includeImmediateParentClass: Bool? = false) -> (klass: String, method: String)? {
        let stackSymbols = Thread.callStackSymbols
        if (stackSymbols.count >= 2) {
            return classAndMethod(forStackSymbol: stackSymbols[1], includeImmediateParentClass: includeImmediateParentClass)
        }
        return nil
    }
}
