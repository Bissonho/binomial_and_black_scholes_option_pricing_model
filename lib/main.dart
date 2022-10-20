import 'models/binomial_model.dart';
import 'models/black_scholes_model.dart';

void main(List<String> args) {
  double assetPrice = 36.46;
  double optionStrike = 36.27;

  // Binomial Model
  BinomialTree optionPrice = BinomialTree(
      assetPrice: assetPrice,
      strike: optionStrike,
      timeStep: (1 / 252),
      volatility: 0.5915,
      putCall: EPutCall.Call,
      riskFreeRate: (13.65 / 100),
      steps: 170);

  print("BinomialTree: " + optionPrice.OptionValue().toString());

  //BlackandScholes
  /*optionType call or put
   S -- Underlying price
   K -- Strike price
   R -- Time to expiration in % of year
   Sigma -- Volatility
   r - continuously compounded risk-free interest rate
   q - continuously compounded dividend yield*/

  BlackScholes optionPriceBlackScholes = BlackScholes();
  print("BlackScholes: " +
      optionPriceBlackScholes.Premium(OptionContractType.Call, assetPrice,
              optionStrike, 1 / 252, 0.5915, 13.65 / 100, 0.0)
          .toString());
}
