//
//  Constants.swift
//  Tedious
//
//  Created by Nguyen Chi Dung on 4/12/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import UIKit

struct K {
    struct App {
        static let Live: Int = 1
        static let ProviderAppStoreId = "private"
        static let CustomerAppStoreId = "private"
    }
    
    struct API {
        struct Google {
            struct Key {
                static let Services = "private"
                static let Places = "private"
            }
            struct URL {
                static let Direction = "private"
            }
        }
        struct Stripe {
            static let PublishTestKey = "private"
            static let PublishLiveKey = "private"
        }
    }

    struct Storyboard {
        struct SegueIdentifier {
            static let TaskDetails = "TaskDetailsSegueIdentifier"
            static let TaskStatus = "TaskStatusSegueIdentifier"
            static let TaskReview = "ReviewSegueIdentifier"
            static let TaskReviewNoAnimation = "ReviewNoAnimationSegueIdentifier"
            static let Home = "HomeSegueIdentifier"
            static let Properties = "PropertiesSegueIdentifier"
            static let TaskHistory = "TaskHistorySegueIdentifier"
            static let Payment = "PaymentSegueIdentifier"
            static let GetFreeService = "GetFreeServiceSegueIdentifier"
            static let Help = "HelpSegueIdentifier"
            static let Settings = "SettingsSegueIdentifier"
            static let SignUp = "SignUpSegueIdentifier"
            static let LogIn = "LogInSegueIdentifier"
            static let Onboarding = "OnboardingSegueIdentifier"
            static let SelectAddress = "SelectAddressSegueIdentifier"
            static let ServiceDetails = "ServiceDetailsSegueIdentifier"
            static let EarningsDaily = "EarningsDailySegueIdentifier"
            static let TaskPhoto = "TaskPhotoSegueIdentifier"
            static let AddProperty = "AddPropertySegueIdentifier"
            static let EnterCode = "EnterCodeSegueIdentifier"
            static let Email = "EmailSegueIdentifier"
            static let Password = "PasswordSegueIdentifier"
            static let Name = "NameSegueIdentifier"
            static let Subscription = "SubscriptionSegueIdentifier"
            static let TermsAndConditions = "TermsAndConditionsSegueIdentifier"
            static let PrivacyPolicy = "PrivacyPolicySegueIdentifier"
        }
    }
    struct Firestore {
        struct Collection {
            struct Providers {
                static let Name = "providers"
                struct Field {
                    static let Id = "id"
                    static let Name = "name"
                    static let Email = "email"
                    static let Phone = "phone"
                    static let PhotoUrl = "photo_url"
                    static let CurrentLocation = "current_location"
                    static let LocationTimestamp = "location_timestamp"
                }
            }
            struct Customers {
                static let Name = "customers"
                struct Field {
                    static let Id = "id"
                    static let Name = "name"
                    static let Email = "email"
                    static let Phone = "phone"
                    static let Address = "address"
                    static let Location = "location"
                    static let PhotoUrl = "photo_url"
                    static let StripeCustomerId = "stripe_customer_id"
                    static let Cards = "cards"
                }
            }
            struct Users {
                struct Field {
                    static let PushToken = "push_token"
                    static let Live = "live"
                }
            }
            struct Tasks {
                static let Name = "tasks"
                struct Available {
                    static let Name = "available_tasks"
                }
                struct Field {
                    static let Id = "id"
                    static let SubscriptionId = "subscription_id"
                    static let CustomerId = "customer_id"
                    static let CreatedAt = "created_at"
                    static let Status = "status"
                    static let StartedAt = "started_at"
                    static let Location = "location"
                    static let Address = "address"
                    static let ProviderId = "provider_id"
                    static let PhotoUrl = "photo_url"
                    static let Duration = "duration"
                    static let GrassLength = "grass_length"
                    static let ScheduleAt = "schedule_at"
                    static let Frequency = "frequency"
                    static let LawnSize = "lawn_size"
                    static let When = "when"
                    static let Receipt = "receipt"
                    static let Live = "live"
                }
            }
            struct Subscriptions {
                static let Name = "subscriptions"
                struct Field {
                    static let Id = "id"
                    static let CustomerId = "customer_id"
                    static let CreatedAt = "created_at"
                    static let Location = "location"
                    static let Address = "address"
                    static let Price = "price"
                    static let ScheduleAt = "schedule_at"
                    static let Frequency = "frequency"
                    static let LawnSize = "lawn_size"
                    static let NextTaskScheduleAt = "next_task_schedule_at"
                    static let SkipNextTask = "skip_next_task"
                    static let Live = "live"
                }
            }
            struct Reviews {
                static let Name = "reviews"
                struct Field {
                    static let TaskId = "task_id"
                    static let CustomerId = "customer_id"
                    static let ProviderId = "provider_id"
                    static let Rating = "rating"
                    static let Text = "text"
                    static let CreatedAt = "created_at"
                    static let StripeChargeId = "stripe_charge_id"
                }
            }
            struct Properties {
                static let Name = "properties"
                struct Field {
                    static let Id = "id"
                    static let Address = "address"
                    static let LawnSize = "lawn_size"
                    static let CarLengths = "car_lengths"
                    static let CarWidths = "car_widths"
                    static let Notes = "notes"
                    static let Location = "location"
                    static let Frequency = "frequency"
                }
            }
            struct Pricing {
                static let Name = "pricing"
                struct LawnService {
                    static let Name = "lawn_service"
                    struct Field {
                        static let SmallOneTime = "small_one_time"
                        static let MediumOneTime = "medium_one_time"
                        static let LargeOneTime = "large_one_time"
                        static let SmallWeekly = "small_weekly"
                        static let MediumWeekly = "medium_weekly"
                        static let LargeWeekly = "large_weekly"
                        static let SmallBiweekly = "small_biweekly"
                        static let LargeBiweekly = "large_biweekly"
                        static let MediumBiweekly = "medium_biweekly"
                        static let Now = "now"
                        static let Overgrown = "overgrown"
                    }
                }
            }
        }
    }
    struct Device {
        static let IS_IPHONE_4 = (UIScreen.main.bounds.size.height == 480.0)
        static let IS_IPHONE_5 = (UIScreen.main.bounds.size.height == 568.0)
        static let IS_IPHONE_6 = (UIScreen.main.bounds.size.height == 667.0)
        static let IS_IPHONE_6_PLUS = (UIScreen.main.bounds.size.height == 736.0)
        static let IS_IPHONE_X = (UIScreen.main.bounds.size.height == 812.0)
    }
    struct UserDefaults {
        static let NeedsCurrentLocationTracking = "NeedsCurrentLocationTracking"
        static let LoggedInUser = "LoggedInUser"
        static let LastSelectedAddressTitle = "LastSelectedAddressTitle"
        static let LastSelectedAddressSubTitle = "LastSelectedAddressSubTitle"
        static let LastSelectedLocationLatitude = "LastSelectedLocationLatitude"
        static let LastSelectedLocationLongitude = "LastSelectedLocationLongitude"
    }
    struct Font {
        static let Bold = "Oswald-Bold"
        static let SemiBold = "Oswald-SemiBold"
        static let Medium = "Oswald-Medium"
        static let Regular = "Oswald-Regular"
        static let Light = "Oswald-Light"
        static let ExtraLight = "Oswald-ExtraLight"
    }
    struct Value {
        static let ProfilePhotoMaxSize: CGFloat = 256.0
        static let TaskPhotoMaxSize: CGFloat = 1024.0
        struct Map {
            static let MarkersLimit: Int = 50
        }
    }
    
    struct SupportContact {
        static let Email = "private"
        static let Phone = "+private"
    }
}

struct Constants {
    // DBPRovider
    static let Customer = "customer"
    static let EMAIL = "email"
    static let PASSWORD = "passowrd"
    static let FIRST_NAME = "First_Name"
    static let LAST_NAME = "Last_Name"
    static let Phone_Number = "Phone_Number"
    static let DATA = "data"
    static let isCustomer = "isCustomer"
    static let SERVICE_REQUEST = "Service_Request"
    static let SERVICE_ACCEPTED = "Service_Accepted"
    static let Profile_Image = "Profile_Image"
    
    //Provider Handler
    static let NAME = "name"
    static let LATITUDE = "latitude"
    static let LONGITUDE = "longitude"
}

enum Target {
    case Customer
    case Provider
}
