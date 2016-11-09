//
//  ViewController.swift
//  IAPTutorial
//
//  Created by FV iMAGINATION on 08/11/2016.
//  Copyright © 2016 FV iMAGINATION. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController,
SKProductsRequestDelegate,
SKPaymentTransactionObserver
{

    /* Views */
    @IBOutlet weak var coinsLabel: UILabel!
    @IBOutlet weak var premiumLabel: UILabel!
    @IBOutlet weak var consumableLabel: UILabel!
    @IBOutlet weak var nonConsumableLabel: UILabel!
    
    
    
    /* Variables */
    let COINS_PRODUCT_ID = "com.iaptutorial.coins"
    let PREMIUM_PRODUCT_ID = "com.iaptutorial.premium"
    
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var nonConsumablePurchaseMade = UserDefaults.standard.bool(forKey: "nonConsumablePurchaseMade")
    var coins = UserDefaults.standard.integer(forKey: "coins")
    
    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    // Check your In-App Purchases
    print("NON CONSUMABLE PURCHASE MADE: \(nonConsumablePurchaseMade)")
    print("COINS: \(coins)")
    
    // Set text
    coinsLabel.text = "COINS: \(coins)"
    
    if nonConsumablePurchaseMade { premiumLabel.text = "Premium version PURCHASED!"
    } else { premiumLabel.text = "Premium version LOCKED!"}
    
    
    
    // Fetch IAP Products available
    fetchAvailableProducts()
}


    
    
   
// MARK: -  BUY 10 COINS BUTTON
@IBAction func buy10coinsButt(_ sender: Any) {
    purchaseMyProduct(product: iapProducts[0])
}
    
    
    
// MARK: - UNLOCK PREMIUM BUTTON
@IBAction func unlockPremiumButt(_ sender: Any) {
    purchaseMyProduct(product: iapProducts[1])
}
    

    
// MARK: - RESTORE NON-CONSUMABLE PURCHASE BUTTON
@IBAction func restorePurchaseButt(_ sender: Any) {
    SKPaymentQueue.default().add(self)
    SKPaymentQueue.default().restoreCompletedTransactions()
}
    
func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
    nonConsumablePurchaseMade = true
    UserDefaults.standard.set(nonConsumablePurchaseMade, forKey: "nonConsumablePurchaseMade")
        
    UIAlertView(title: "IAP Tutorial",
    message: "You've successfully restored your purchase!",
    delegate: nil, cancelButtonTitle: "OK").show()
}
 

    
    
    
    
    
// MARK: - FETCH AVAILABLE IAP PRODUCTS
func fetchAvailableProducts()  {
        
    // Put here your IAP Products ID's
    let productIdentifiers = NSSet(objects:
        COINS_PRODUCT_ID,
        PREMIUM_PRODUCT_ID
    )
        
    productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
    productsRequest.delegate = self
    productsRequest.start()
}
    
   
// MARK: - REQUEST IAP PRODUCTS
func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
    if (response.products.count > 0) {
        iapProducts = response.products
            
        // 1st IAP Product (Consumable) ------------------------------------
        let firstProduct = response.products[0] as SKProduct
        
        // Get its price from iTunes Connect
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = firstProduct.priceLocale
        let price1Str = numberFormatter.string(from: firstProduct.price)
        
        // Show its description
        consumableLabel.text = firstProduct.localizedDescription + "\nfor just \(price1Str!)"
        // ------------------------------------------------
        
        
        
        // 2nd IAP Product (Non-Consumable) ------------------------------
        let secondProd = response.products[1] as SKProduct
        
        // Get its price from iTunes Connect
        numberFormatter.locale = secondProd.priceLocale
        let price2Str = numberFormatter.string(from: secondProd.price)
        
        // Show its description
        nonConsumableLabel.text = secondProd.localizedDescription + "\nfor just \(price2Str!)"
        // ------------------------------------
    }
}
    
    
    

// MARK: - MAKE PURCHASE OF A PRODUCT
func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
func purchaseMyProduct(product: SKProduct) {
    if self.canMakePurchases() {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
        
        print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
        productID = product.productIdentifier
        
        
    // IAP Purchases dsabled on the Device
    } else {
        UIAlertView(title: "IAP Tutorial",
        message: "Purchases are disabled in your device!",
        delegate: nil, cancelButtonTitle: "OK").show()
    }
}
    
    
    
// MARK:- IAP PAYMENT QUEUE
func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                    
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    // The Consumale product (10 coins) has been purchased -> gain 10 extra coins!
                   if productID == COINS_PRODUCT_ID {
                        
                        // Add 10 coins and save their total amount
                        coins += 10
                        UserDefaults.standard.set(coins, forKey: "coins")
                        coinsLabel.text = "COINS: \(coins)"
                        
                        UIAlertView(title: "IAP Tutorial",
                        message: "You've successfully bought 10 extra coins!",
                        delegate: nil,
                        cancelButtonTitle: "OK").show()
                        
                        
                        
                    // The Non-Consumable product (Premium) has been purchased!
                    } else if productID == PREMIUM_PRODUCT_ID {
                        
                        // Save your purchase locally (needed only for Non-Consumable IAP)
                        nonConsumablePurchaseMade = true
                        UserDefaults.standard.set(nonConsumablePurchaseMade, forKey: "nonConsumablePurchaseMade")
                    
                        premiumLabel.text = "Premium version PURCHASED!"
                        
                        UIAlertView(title: "IAP Tutorial",
                        message: "You've successfully unlocked the Premium version!",
                        delegate: nil,
                        cancelButtonTitle: "OK").show()
                    }
                    
                    break
                    
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                default: break
    }}}
}
    
    
   
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

