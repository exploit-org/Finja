# Value & Amount Conversion

This section documents how Finja represents and converts monetary values across different blockchains.

Since most blockchains operate on smallest indivisible units (e.g., satoshis, wei), Finja separates internal and human-facing representations using the `Value` model and unified conversion interfaces.

---

## `Value`

A structured representation of a blockchain amount in both human and native forms.

```java
public record Value(BigDecimal amount, BigInteger unit) {
    public Value() {
        this(BigDecimal.ZERO, BigInteger.ZERO);
    }
}
```

- `amount` — human-readable form (e.g., 0.01 BTC)
- `unit` — smallest unit of the currency (e.g., 1,000,000 satoshi)

Used consistently throughout the wallet, transaction, and event systems to avoid precision issues and rounding errors.

> Both fields are required — no implicit conversions are performed inside the record.

---

## `ValueConverter`

Used to convert values between user-facing and internal formats for a given coin.

### Methods:

- `toUnit(BigDecimal amount)`  
  Converts a decimal input (e.g., `0.025`) to the smallest blockchain unit (e.g., `2500000` for 8 decimals)

- `toHuman(BigInteger unit)`  
  Converts native units to a human-readable decimal (e.g., `123456789000000000L → 0.123456789` ETH)

This is essential when constructing transactions from user input or displaying values in the UI.

---

## `SmartValueConverter`

Extended version of `ValueConverter` for smart-contract-based tokens.

### Why?

Each token may have its own decimals (e.g., USDT = 6, WETH = 18), so conversion must be contract-specific.

### Methods:

- `toUnit(BigDecimal amount, String contractAddress)`
- `toHuman(BigInteger unit, String contractAddress)`

This ensures accuracy when interacting with ERC20/TRC20 tokens or similar.

---

## `Amount`

The `Amount` model represents an amount **before** conversion.  
Unlike `Value`, which always contains both representations, `Amount` only stores:

- `value` — the numeric value
- `amountUnit` — either `HUMAN` (decimal) or `UNIT` (raw)

### Enum: `AmountUnit`

- `HUMAN`: the value is a human-readable decimal (e.g., `0.5`)
- `UNIT`: the value is in smallest units already (e.g., `500000`)

This is typically used when constructing transactions:

- If the user inputs "0.01 BTC", wrap as `Amount(value, HUMAN)`
- If working with exact units, wrap as `Amount(value, UNIT)`

> `Amount` is converted into `BigInteger` during transaction assembly using the provider’s `ValueConverter`.

## Summary

| Component             | Purpose                                                |
|-----------------------|--------------------------------------------------------|
| `Value`               | Holds both decimal and smallest unit representation    |
| `ValueConverter`      | Converts between human input and blockchain unit       |
| `SmartValueConverter` | Adds contract-specific conversion for tokenized assets |