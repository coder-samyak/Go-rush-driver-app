export class Money {
  constructor(
    public readonly amountMinor: number,
    public readonly currency: string = 'INR'
  ) {}

  add(other: Money): Money {
    if (this.currency !== other.currency) {
      throw new Error('Currency mismatch');
    }
    return new Money(this.amountMinor + other.amountMinor, this.currency);
  }

  subtract(other: Money): Money {
    if (this.currency !== other.currency) {
      throw new Error('Currency mismatch');
    }
    return new Money(this.amountMinor - other.amountMinor, this.currency);
  }
}
