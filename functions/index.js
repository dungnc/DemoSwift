const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore()
var request = require('request');

exports.createStripeCharge = functions.https.onRequest((req, res) => {
  return createStripeCharge(req.body)
        .then((charge) => {
          console.log("callback: charge: ", charge);
          res.status(200).json({ stripe_charge_id: charge.id });
        })
        .catch((err) => {
          console.log("callback: err: ", err);
          res.status(400).json({ error: err.message });
        });
});

function createStripeCharge(charge, callback) {
  const live = charge.live
  const stripe = require('stripe')(live ? functions.config().stripe.live_secret_key : functions.config().stripe.dev_secret_key);
  const amount = charge.amount;
  const currency = charge.currency;
  const stripe_customer_id = charge.stripe_customer_id;
  const description = charge.description;
  const capture = charge.capture;
  console.log("createStripeCharge: live: ", live, ", stripe_customer_id: ", stripe_customer_id, ", capture: ", capture, ", amount: ",
   amount, ", description:", description);
  return stripe.charges.create({
            amount: amount,
            currency: "USD",
            customer: stripe_customer_id,
            description: description,
            capture: capture
          });
}

exports.refundStripeCharge = functions.https.onRequest((req, res) => {
  return refundStripeCharge(req.body)
        .then((charge) => {
          console.log("callback: charge: ", charge);
          res.status(200).json({ success: true });
        })
        .catch((err) => {
          console.log("callback: err: ", err);
          res.status(400).json({ error: err.message });
        });
});

function refundStripeCharge(charge, callback) {
  const live = charge.live
  const stripe = require('stripe')(live ? functions.config().stripe.live_secret_key : functions.config().stripe.dev_secret_key);
  const stripeChargeId = charge.stripe_charge_id;
  console.log("refundStripeCharge: live: ", live, ", stripeChargeId: ", stripeChargeId);
  return stripe.refunds.create({
            charge: stripeChargeId
          });
}

//Deleted many functions for security


