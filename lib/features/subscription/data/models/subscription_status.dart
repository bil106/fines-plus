enum SubscriptionStatus {
  none, // user never started trial
  trialActive, // trial running now
  trialEnded, // trial finished, cannot activate again
  subscribed, // paid user
}
