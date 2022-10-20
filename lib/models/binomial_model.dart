import 'dart:math';
//import 'package:extended_math/extended_math.dart';
import 'package:intl/intl.dart';
import 'package:normal/normal.dart';

enum EPutCall {
  Call(0),
  Put(1);

  final num Value;
  const EPutCall(this.Value);
}

class BinomialTree {
  double assetPrice; // Stock Price
  double strike; // Strike Option
  double timeStep; // the time to maturity is 0.5 years
  double volatility;
  EPutCall putCall;
  double riskFreeRate;
  int steps; //discrete time steps

  BinomialTree({
    required this.assetPrice,
    required this.strike,
    required this.timeStep,
    required this.volatility,
    required this.putCall,
    required this.riskFreeRate,
    required this.steps,
  });

  double BinomialCoefficient(int m, int n) {
    return Factorial(n) / (Factorial(m) * Factorial(n - m));
  }

  double BinomialNodeValue(int m, int n, double p) {
    return BinomialCoefficient(m, n) *
        pow(p, m) *
        pow(
            1.0 - p,
            (n -
                m)); // Multiplicando a probabilidade de alta com a probabilidade de baixa resolvendo a árvore
    // Probabilidade de baixa é 1-P  ( 1 menos a probalidade de alta).
  }

  double OptionValue() {
    double totalValue = 0.0;
    double u = OptionUp(timeStep, volatility, steps);
    double d = OptionDown(timeStep, volatility, steps);
    double p = Probability(timeStep, volatility, steps, riskFreeRate);
    double nodeValue = 0.0;
    double payoffValue = 0.0;
    for (int j = 0; j <= steps; j++) {
      payoffValue =
          Payoff(assetPrice * pow(u, j) * pow(d, (steps - j)), strike, putCall);
      //Result:
      //3.12
      //1.11
      //0.0
      nodeValue = BinomialNodeValue(j, steps, p);
      totalValue += nodeValue * payoffValue;
      //System.Diagnostics.Debug.WriteLine("payoffValue:" + payoffValue.ToString());
      //System.Diagnostics.Debug.WriteLine("nodeValue:" + nodeValue.ToString());
      //System.Diagnostics.Debug.WriteLine("totalValue:" + totalValue.ToString() + "\n\n");
    }
    return PresentValue(totalValue, riskFreeRate, timeStep);
  }

  // Probabilities
  double OptionUp(double t, double s, int n) {
    return exp(s * sqrt(t / n));
  }

  double OptionDown(double t, double s, int n) {
    //print((t / n));
    return exp(-s * sqrt(t / n));
  }

  double Probability(double t, double s, int n, double r) {
    double d1 = FutureValue(1.0, r, t / n);
    double d2 = OptionUp(t, s, n);
    double d3 = OptionDown(t, s, n);
    return (d1 - d3) / (d2 - d3);
  }

  double Payoff(double S, double X, EPutCall PutCall) {
    switch (PutCall) {
      case EPutCall.Call:
        return Call(S, X);

      case EPutCall.Put:
        return Put(S, X);

      default:
        return 0.0;
    }
  }

  double Call(double S, double X) {
    return max(0.0, S - X);
  }

  double Put(double S, double X) {
    return max(0.0, X - S);
  }

  // Financial Math Utility Functions
  double Factorial(int n) {
    double d = 1.0;
    for (int j = 1; j <= n; j++) {
      d *= j;
    }
    return d;
  }

  double FutureValue(double P, double r, double n) {
    return P * pow(1.0 + r, n);
  }

  double PresentValue(double F, double r, double n) {
    return F / exp(r * n);
  }
}
