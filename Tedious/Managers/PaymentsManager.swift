//
//  PaymentsManager.swift
//  TediousCustomer
//
//  Created by Nguyen Chi Dung on 4/26/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import Foundation
import Stripe
import Alamofire

class PaymentsManager: NSObject {

    open static func chargeTip(for task: Task, customer: Customer, completion: @escaping (_ task: Task?, _ error: Error?) -> ()) {
        let params: [String: Any] = [
            "live": customer.live,
            "stripe_customer_id": customer.stripeCustomerId!,
            "amount": task.receipt.price(at: .Tip)!.value,
            "description": "Tip Charge, Email: \(customer.email), Address: \(task.address), Task ID: \(task.id!)",
            "capture": true
        ]
        charge(withParams: params) { (stripeChargeId, error) in
            if let stripeChargeId = stripeChargeId {
                var updatedTask = task
                updatedTask.receipt.addChargeId(stripeChargeId, toItem: .Tip)
                completion(updatedTask, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    static func charge(for task: Task, customer: Customer, capture: Bool, completion: @escaping (_ customer: Task?, _ error: Error?) -> ()) {
        let params: [String: Any] = [
            "v": "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "")",
            "live": customer.live,
            "stripe_customer_id": customer.stripeCustomerId!,
            "amount": task.receipt.total.value,
            "description": "Regular Charge, Email: \(customer.email), Address: \(task.address)",
            "capture": capture
        ]
        charge(withParams: params) { (stripeChargeId, error) in
            if let stripeChargeId = stripeChargeId {
                var updatedTask = task
                updatedTask.receipt.addAuthorize(stripeChargeId)
                completion(updatedTask, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    static func refundCharge(for task: Task, customer: Customer, completion: @escaping (_ task: Task?, _ error: Error?) -> ()) {
        guard let stripeChargeId = task.receipt.authorizeID, !stripeChargeId.isEmpty else {
            return
        }
        let params: [String: Any] = [
            "v": "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "")",
            "live": customer.live,
            "stripe_charge_id": stripeChargeId
        ]
        
        let url = "priavte//refundStripeCharge"
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            if response.result.isSuccess {
                var error: Error? = nil
                if let json = response.result.value as? [String: AnyObject] {
                    if response.response!.statusCode == 200 {
                        var updatedTask = task
                        updatedTask.receipt.removeAuthorize()
                        completion(updatedTask, nil)
                        return
                    } else {
                        error = errorFromJson(json , statusCode: response.response!.statusCode)
                    }
                }
                completion(nil, error)
            } else {
                completion(nil, response.result.error)
            }
        }
    }

    static func captureCharge(for task: Task, provider: Provider, completion: @escaping (_ customer: Task?, _ error: Error?) -> ()) {
        let url = "priavte//captureStripeCharge"
        let params: [String: Any] = [
            "live": task.live,
            "stripe_charge_id": task.receipt.authorizeID!
        ]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            if response.result.isSuccess {
                print("captureCharge value: \(response.result.value)")
                var updatedTask: Task? = nil
                var error: Error? = nil
                if let json = response.result.value as? [String: AnyObject] {
                    let code = (json["code"] as? String) ?? ""
                    if response.response!.statusCode == 200 || code == "charge_already_captured" {
                        updatedTask = task
                        updatedTask?.receipt.addChargeAuthorize(task.receipt.authorizeID!, toItem: .LawnService)
                    } else {
                        error = errorFromJson(json , statusCode: response.response!.statusCode)
                    }
                }
                completion(updatedTask, error)
            } else {
                print("captureCharge error: \(response.result.error)")
                completion(nil, response.result.error)
            }
        }
    }
    
    fileprivate static func charge(withParams params: [String: Any], completion: @escaping (_ stripeChargeId: String?, _ error: Error?) -> ()) {
        let url = "priavte//createStripeCharge"
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            if response.result.isSuccess {
                print("charge value: \(response.result.value)")
                var stripeChargeId: String? = nil
                var error: Error? = nil
                if let json = response.result.value as? [String: AnyObject] {
                    if response.response!.statusCode == 200 {
                        stripeChargeId = json["stripe_charge_id"] as! String
                    } else {
                        error = errorFromJson(json , statusCode: response.response!.statusCode)
                    }
                }
                completion(stripeChargeId, error)
            } else {
                print("charge error: \(response.result.error)")
                completion(nil, response.result.error)
            }
        }
    }
    
    static func addCreditCard(to customer: Customer, token: STPToken, completion: @escaping (_ customer: Customer?, _ error: Error?) -> ()) {
        if let stripeCustomerId = customer.stripeCustomerId {
            let url = "priavte//addCardToStripeCustomer"
            let params: [String: Any] = [
                "live": customer.live,
                "source": token.tokenId,
                "stripe_customer_id": stripeCustomerId
            ]
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
                if response.result.isSuccess {
                    print("\(#function) value: \(response.result.value)")
                    var customer: Customer? = nil
                    var error: Error? = nil
                    if let json = response.result.value as? [String: AnyObject] {
                        if response.response!.statusCode == 200 {
                            customer = Customer.current!
                            var cards = customer?.cards ?? []
                            cards += [Customer.Card(dictionary: json)]
                            customer?.cards = cards
                        } else {
                            error = errorFromJson(json , statusCode: response.response!.statusCode)
                        }
                    }
                    completion(customer, error)
                } else {
                    print("\(#function) error: \(response.result.error)")
                    completion(nil, response.result.error)
                }
            }
        } else {
            createStripeCustomer(with: customer, token: token, completion: completion)
        }
    }
    
    static func deleteCard(_ card: Customer.Card, from customer: Customer, completion: @escaping (_ customer: Customer?, _ error: Error?) -> ()) {
        let url = "priavte//deleteCardFromStripeCustomer"
        let params: [String: Any] = [
            "live": customer.live,
            "stripe_customer_id": customer.stripeCustomerId!,
            "stripe_card_id": card.id
        ]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            if response.result.isSuccess {
                print("\(#function) value: \(response.result.value)")
                var customer: Customer? = nil
                var error: Error? = nil
                if let json = response.result.value as? [String: AnyObject] {
                    if response.response!.statusCode == 200 {
                        customer = Customer.current!
                        let index = customer!.cards!.index(where: { $0.id == card.id })!
                        customer?.cards?.remove(at: index)
                    } else {
                        error = errorFromJson(json , statusCode: response.response!.statusCode)
                    }
                }
                completion(customer, error)
            } else {
                print("\(#function) error: \(response.result.error)")
                completion(nil, response.result.error)
            }
        }
    }
    
    fileprivate static func createStripeCustomer(with customer: Customer, token: STPToken, completion: @escaping (_ customer: Customer?, _ error: Error?) -> ()) {
        let url = "priavte//createStripeCustomer"
        let params: [String: Any] = [
            "live": customer.live,
            "source": token.tokenId,
            "customer_id": customer.id,
            "description": "Email: \(customer.email), Firestore ID: \(customer.id)"
        ]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            if response.result.isSuccess {
                print("\(#function) value: \(response.result.value)")
                var customer: Customer? = nil
                var error: Error? = nil
                if let json = response.result.value as? [String: AnyObject] {
                    if response.response!.statusCode == 200 {
                        let sources = json["sources"] as! [String: Any]
                        let data = sources["data"] as! [[String: Any]]
                        customer = Customer.current!
                        customer?.stripeCustomerId = json["id"] as? String
                        customer?.cards = [Customer.Card(dictionary: data.first!)]
                    } else {
                        error = errorFromJson(json , statusCode: response.response!.statusCode)
                    }
                }
                completion(customer, error)
            } else {
                print("\(#function) error: \(response.result.error)")
                completion(nil, response.result.error)
            }
        }
    }
    
    static func errorFromJson(_ json: [String: AnyObject], statusCode: Int) -> Error {
        var userInfo: [String: String] = [:]
        userInfo[NSLocalizedDescriptionKey] = json["error"] as? String
        let error = NSError(domain: "", code: statusCode, userInfo: userInfo)
        return error
    }
}
