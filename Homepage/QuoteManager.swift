//
//  QuoteManager.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-02-19.
//

import Foundation
import SwiftUI

final class QuoteManager{
    
    static let shared = QuoteManager()
    var firstQuote = ""
    var secondQuote = ""
    var thirdQuote = ""
    var fourthQuote = ""
    var quotesArray: [String] = ["'In the end, we will remember not the words of our enemies, but the silence of our friends.' - Martin Luther King Jr.","'The only way to do great work is to love what you do.' - Steve Jobs","'Hard work beats talent when talent doesn't work hard.' - Tim Notke", "'Opportunities are usually disguised as hard work, so most people don't recognize them.' - Ann Landers"]
    
    
    func addQuotes(quote: String){
        
        quotesArray.insert(quote, at: 0)
        removeLastQuote()
    }
    
    func removeLastQuote(){
        quotesArray.removeLast()
    }
    
    func getFirstQuote() -> String{
        firstQuote = quotesArray[0]
        return firstQuote
    }
    
    func getSecondQuote() -> String{
        secondQuote = quotesArray[1]
        return secondQuote
    }
    
    func getThirdQuote() -> String{
        thirdQuote = quotesArray[2]
        return thirdQuote
    }
    
    func getFourthQuote() -> String{
        fourthQuote = quotesArray[3]
        return fourthQuote
    }
    
    func getQuotesSize() -> Int{
        return quotesArray.count
    }
    
    func getQuote(count: Int) -> String {
        return quotesArray[count]
    }
    
}
