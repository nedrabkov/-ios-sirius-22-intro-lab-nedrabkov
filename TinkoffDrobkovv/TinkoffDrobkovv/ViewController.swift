//
//  ViewController.swift
//  TinkoffDrobkovv
//
//  Created by Дробков Михамл on 07.02.2022.
//

import UIKit
let reachability = try! Reachability()


class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.companies.keys.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return Array(self.companies.keys)[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.activityIndicator.startAnimating()
        
        let selectedSymbol = Array(self.companies.values)[row]
        self.requestQuote(for: selectedSymbol)
    }
    func pickerView(_ pickerView: UIPickerView, didSelectedRow row: Int, incomponent: Int) {
        
        let selectedSymbol = Array(self.companies.values)[row]
        self.requestQuote(for: selectedSymbol)
    }

    private func requestQuote(for symbol: String) {
    
        let url = URL(string:"https://cloud.iexapis.com/stable/stock/\(symbol)/quote?&token=pk_6d759ebe121d459f80282fc15fdb48bd")!
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
              let data = data
            else {
                print ("!error")
            return
            }

            self.parseQuote(data: data)
        }
    dataTask.resume()
}
        
    private func parseQuote(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject (with: data)
            
            guard
                let json = jsonObject as? [String: Any],
                let companyName = json["companyName"] as? String,
                let companySymbol = json["symbol"] as? String,
                let price = json["latestPrice"] as? Double,
                let priceChange = json["change"] as? Double
            else {
                print ("invalid JSON format")
                return
            }
            DispatchQueue.main.async {
                self.displayStockInfo(companyName: companyName,
                                      symbol: companySymbol,
                                      price: price,
                                      priceChange: priceChange)
                if priceChange > 0 && priceChange != 0 {
                    self.PriceChangeLabel.textColor = .green
                }else if priceChange != 0{
                    self.PriceChangeLabel.textColor = .red
                }else{
                    self.PriceChangeLabel.textColor = .black
                }
            }
            
        } catch {
            print ("! JSON parsing error: " + error.localizedDescription)
        }
    }
    
    private func displayStockInfo(companyName: String, symbol: String, price: Double, priceChange: Double) {
        self.activityIndicator.stopAnimating()
        self.companyNameLabel.text = companyName
        self.companySymbolLabel.text = symbol
        self.PriceLabel.text = "\(price)"
        self.PriceChangeLabel.text = "\(priceChange)"
    }
        
        
        
    private func requestQuoteUpdate() {
        self.activityIndicator.startAnimating()
        self.companyNameLabel.text = "-"
        self.companySymbolLabel.text = "-"
        self.PriceLabel.text = "-"
        self.PriceChangeLabel.text = "-"
        self.PriceChangeLabel.textColor = .black
        
        let selectedRow = self.companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(self.companies.values)[selectedRow]
        self.requestQuote(for: selectedSymbol)
        
    }
    
    @IBOutlet weak var PriceChangeLabel: UILabel!
    @IBOutlet weak var PriceLabel: UILabel!
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var companyPickerView: UIPickerView!
    @IBOutlet weak var companyNameLabel: UILabel!
    
   
    
    private let companies:[String: String] = ["Apple": "AAPL","Microsoft": "MSFT", "GOOGLE": "GOOG", "Amazon": "AMZN", "Facebook": "FB"]
    
   
    override func viewDidLoad(){
        super.viewDidLoad()
        reachability.whenReachable = { reachability in
                   if reachability.connection == .wifi {
                       print("Reachable via wifi")
                   }else{
                       print("Reachable via cellular")
                   }
                   
               }
               reachability.whenUnreachable = { _ in
                   print("Not reachable")
                   self.showAlert()
                   
               }
               do{
                   try reachability.startNotifier()
               }catch{
                   print("unable to start notifier")
               }
               
        self.companyPickerView.dataSource = self
        self.companyPickerView.delegate = self
        self.activityIndicator.hidesWhenStopped = true
        self.requestQuoteUpdate()
    }
    func showAlert(){
      let alert = UIAlertController(title: "Attention", message: "Network error", preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style: .default,handler: nil)
      alert.addAction(okAction)
      present(alert, animated: true, completion: nil)
    }
}
