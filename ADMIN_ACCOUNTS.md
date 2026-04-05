# 🏦 ADMIN ACCOUNTS & PAYMENT INTEGRATION

---

## ⚠️ CRITICAL - MUST BE CONFIGURED

**Status**: ❌ NOT CONFIGURED - MUST FIX

---

## 📋 REQUIRED

### 1. PayPal (Primary)
```
- PayPal Business Account
- Client ID & Secret
- Webhook URL
```

### 2. Stripe/Bank
```
- Stripe Connect (recommended)
- Bank account linking
```

### 3. Payment Gateway
```
- Card processing
- Apple Pay / Google Pay
```

### 4. Wallet Reserves
```
- Hot Wallet: 10,000-50,000 PINC
- Cold Storage: 90%
- Escrow for jobs
```

### 5. Platform Fee
```
- 3% on jobs
- Collection account
```

---

## 🔧 CONFIGURATION

```dart
class PaymentConfig {
  static const paypalClientId = 'TODO'; // CONFIGURE
  static const paypalSecret = 'TODO';   // CONFIGURE
  static const stripePublicKey = 'TODO'; // CONFIGURE
  static const stripeSecretKey = 'TODO'; // CONFIGURE
  static const platformFeePercent = 3.0;
}
```

---

## ✅ AUDIT CHECKLIST

- [ ] PayPal configured
- [ ] Stripe configured
- [ ] Wallet reserves set
- [ ] Escrow working
- [ ] Test transactions