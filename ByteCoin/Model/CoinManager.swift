//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation


protocol CoinManagerDelegate {
    
    func didUpdatePrice ( price:String, currency:String )
    func didFailWithError ( error:Error  )
    
    
}

struct CoinManager {
    
    //Create an optional delegate that will have to implement the delegate methods.
    //Which we can notify when we have updated the price.
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "9E224463-0C1D-43CE-99CD-A69C244F968E"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    
    
    
    
    func getCoinPrice(for currency: String) {
        
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    
                    delegate?.didFailWithError(error: error!)
                    
                    return
                }
                
                if let safeData = data {
                    if let bitcoinPrice = parseJSON(safeData) {
                        //Optional: round the price down to 2 decimal places.
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        
                        delegate?.didUpdatePrice(price: priceString, currency: currency)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON(_ data:Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            return lastPrice
        } catch  {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}



