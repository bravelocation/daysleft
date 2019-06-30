//
//  PurchaseViewController.swift
//  daysleft
//
//  Created by John Pollard on 05/04/2017.
//  Copyright © 2017 Brave Location Software. All rights reserved.
//

import UIKit
import StoreKit
import daysleftlibrary

class PurchaseViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelProductDetails: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var buttonAction: UIButton!
    @IBOutlet weak var buttonRestorePurchase: UIButton!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var buttonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var betweenButtonConstraint: NSLayoutConstraint!
    
    var productRequest: SKProductsRequest?
    var product: SKProduct?
    var transactionInProgress: Bool = false
    var model: AppDaysLeftModel?
    var backItem: UIBarButtonItem?
    let appGreen = UIColor(named: "MainAppColor")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.model = appDelegate.model

        // Initialise elements
        self.labelTitle.text = "\u{1F596}"
        
        self.buttonAction.layer.borderWidth = 1.0
        self.buttonAction.layer.cornerRadius = 5.0
        self.buttonAction.layer.borderColor = self.appGreen.cgColor
        self.buttonAction.tintColor = self.appGreen

        self.buttonRestorePurchase.layer.borderWidth = 1.0
        self.buttonRestorePurchase.layer.cornerRadius = 5.0
        self.buttonRestorePurchase.layer.borderColor = self.appGreen.cgColor
        self.buttonRestorePurchase.tintColor = self.appGreen
 
        self.activitySpinner.hidesWhenStopped = true

        self.actionButtonChange(message: "", enable: false)
        self.statusChange(status: "", enableActivityMonitor: false)

        // Setup payment observer
        SKPaymentQueue.default().add(self)
        
        // Customise the nav bar
        // Customise the nav bar
        let navBar = self.navigationController?.navigationBar
        navBar!.barTintColor = appGreen
        navBar!.tintColor = UIColor.white
        navBar!.isTranslucent = false
        navBar!.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        self.title = "Go Ads Free"
        
        // Set product details
        self.productRequest = SKProductsRequest(productIdentifiers: ["com.bravelocation.daysleft.adsfree"])
        self.productRequest!.delegate = self
        
        self.transactionInProgress = false
        
        // Check if already ads free
        if (self.showAds() == false) {
            self.statusChange(status: "You're already Ads Free - thanks!", enableActivityMonitor: false)
        } else {
            // Look for product information
            self.requestProductInfo()
        }
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func requestProductInfo() {
        if (SKPaymentQueue.canMakePayments()) {
            // Get the product details from the store
            self.statusChange(status: "Fetching details from the App Store ...", enableActivityMonitor: true)
            self.productRequest!.start()
        }
    }
    
    func statusChange(status: String, enableActivityMonitor: Bool) {
        self.labelStatus.text = status
        
        if (enableActivityMonitor) {
            self.activitySpinner.startAnimating()
        } else {
            self.activitySpinner.stopAnimating()
        }
        
        print("Status change:", status)
    }
    
    func actionButtonChange(message: String, enable: Bool) {
        if (enable == false || self.showAds() == false) {
            self.buttonAction.setTitle("", for: UIControl.State.normal)
            self.buttonAction.layer.borderColor = UIColor.clear.cgColor
            self.buttonAction.tintColor = UIColor.clear
            self.buttonAction.isEnabled = false
            
            self.buttonRestorePurchase.isEnabled = false
            self.buttonRestorePurchase.isHidden = true
            self.betweenButtonConstraint.constant = 0.0
        } else {
            self.buttonAction.setTitle(message, for: UIControl.State.normal)
            self.buttonAction.layer.borderColor = self.appGreen.cgColor
            self.buttonAction.tintColor = self.appGreen
            self.buttonAction.isEnabled = true
            
            self.buttonRestorePurchase.isEnabled = true
            self.buttonRestorePurchase.isHidden = false
            self.betweenButtonConstraint.constant = 8.0
        }
    }
    
    func successfulPayment() {
        self.model?.adsFree = true
        self.actionButtonChange(message: "", enable: false)
        
        // Hide the restore button
        self.buttonRestorePurchase.isEnabled = false
        self.buttonRestorePurchase.isHidden = true
        self.betweenButtonConstraint.constant = 0.0
    }
    
    func showAds() -> Bool {
        return self.model?.adsFree == false
    }
    
    // MARK: - SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if (response.products.count > 0) {
            if (response.invalidProductIdentifiers.count > 0) {
                print("Invalid product identifier:", response.invalidProductIdentifiers.description)
                self.statusChange(status: "A problem occurred downloading the confirmation :(", enableActivityMonitor: false)
            } else {
                self.product = response.products[0]
                
                 // If we've not already restored
                if (self.showAds()) {
                    self.statusChange(status: "", enableActivityMonitor: false)
                    self.labelProductDetails.text = self.product?.localizedDescription
                    
                    // Format the price
                    let numberFormatter = NumberFormatter()
                    numberFormatter.formatterBehavior = .behavior10_4
                    numberFormatter.numberStyle = .currency
                    numberFormatter.locale = self.product?.priceLocale
                    let formattedPrice = numberFormatter.string(from: (self.product?.price)!)
                    let buttonTextWithPrice = String.init(format: "Go Ads Free for %@", arguments: [formattedPrice!])
                    self.actionButtonChange(message: buttonTextWithPrice, enable: true)
                    
                } else {
                    print("Already Ads Free")
                    self.statusChange(status: "Already Ads Free", enableActivityMonitor: false)
                    self.actionButtonChange(message: "", enable: false)
                }
            }
        } else {
            print("Cannot find product in store")
            self.statusChange(status: "A problem occurred :(", enableActivityMonitor: false)
        }
    }
    
    // MARK: - SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                self.statusChange(status: "Purchasing Ads Free ...", enableActivityMonitor: true)
            case .deferred:
                self.statusChange(status: "Waiting ...", enableActivityMonitor: true)
            case .failed:
                if (self.transactionInProgress) {
                    self.statusChange(status: "Purchase of Ads Free failed", enableActivityMonitor: false)
                    print("Purchase failed", transaction.error.debugDescription)
                    self.transactionInProgress = false
                }
            case .purchased:
                self.statusChange(status: "You are now Ads Free! Thanks!", enableActivityMonitor: false)
                self.successfulPayment()
            case .restored:
                self.statusChange(status: "Ads Free successfully restored!", enableActivityMonitor: false)
                self.successfulPayment()
            
            @unknown default:
                self.statusChange(status: "Purchase of Ads Free failed", enableActivityMonitor: false)
                print("Purchase failed", transaction.error.debugDescription)
                self.transactionInProgress = false
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        self.statusChange(status: "Ads Free successfully restored!", enableActivityMonitor: false)
        self.successfulPayment()
    }

    // MARK: - Button handlers methods
    @IBAction func buttonActionClicked(_ sender: Any) {
        if (self.product != nil && self.transactionInProgress == false) {
            self.transactionInProgress = true
            self.actionButtonChange(message: "", enable: false)
            
            let payment: SKMutablePayment = SKMutablePayment(product: self.product!)
            payment.quantity = 1
            
            self.statusChange(status: "Buying Ads Free from App Store ...", enableActivityMonitor: true)
            SKPaymentQueue.default().add(payment)
        }
    }
 
    @IBAction func buttonRestorePurchaseClicked(_ sender: Any) {
        if (self.transactionInProgress == false) {
            self.transactionInProgress = true
            self.actionButtonChange(message: "", enable: false)
            
            self.statusChange(status: "Restoring Ads Free from App Store ...", enableActivityMonitor: true)
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
}
