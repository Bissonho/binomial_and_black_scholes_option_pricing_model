import 'dart:math';
//import 'package:extended_math/extended_math.dart';
import 'package:intl/intl.dart';
import 'package:normal/normal.dart';

enum OptionContractType {
  Call(1),
  Put(2);

  final num Value;
  const OptionContractType(this.Value);
}

class BlackScholes {
  static double D1(
      double S, double K, double T, double sigma, double r, double q) {
    return (log(S / K) + (r - q + (sigma * sigma) / 2) * T) / (sigma * sqrt(T));
  }

  static double D2(double T, double sigma, double d1) {
    return d1 - sigma * sqrt(T);
  }

  /*static double T(DateTime contractExpirationTime, DateTime  time)
        {
            if (time > contractExpirationTime)
                throw new ArgumentOutOfRangeException(nameof(time));

            return contractExpirationTime.subtract(Duration(time.day)).day / 365.0;
           // return (contractExpirationTime - time).TotalDays / 365.0;
        }*/

  /// <summary>
  /// Computes theoretical price.
  /// </summary>
  /// <param name="optionType">call or put</param>
  /// <param name="S">Underlying price</param>
  /// <param name="K">Strike price</param>
  /// <param name="T">Time to expiration in % of year</param>
  /// <param name="sigma">Volatility</param>
  /// <param name="r">continuously compounded risk-free interest rate</param>
  /// <param name="q">continuously compounded dividend yield</param>
  /// <returns></returns>
  double Premium(OptionContractType optionType, double S, double K, double T,
      double sigma, double r, double q) {
    double d1 = D1(S, K, T, sigma, r, q);
    double d2 = D2(T, sigma, d1);

    switch (optionType) {
      case OptionContractType.Call:
        return S * exp(-q * T) * Normal.cdf(d1) -
            K * exp(-r * T) * Normal.cdf(d2);

      case OptionContractType.Put:
        return K * exp(-r * T) * Normal.cdf(-d2) -
            S * exp(-q * T) * Normal.cdf(-d1);

      default:
        throw Exception(
            'Option Type Error 1 " + optionType + "Type does not exist!');
      //throw new NotSupportedException(" Option Type Error 1 " + optionType + "Type does not exist!");
    }
  }

  /// Computes Vega. The amount of option price change for each 1% change in vol (sigma)
  /// <param name="S">Underlying price</param>
  /// <param name="K">Strike price</param>
  /// <param name="T">Time to expiration in % of year</param>
  /// <param name="sigma">Volatility</param>
  /// <param name="r">continuously compounded risk-free interest rate</param>
  /// <param name="q">continuously compounded dividend yield</param>
  /// <returns></returns>
  double Vega(double S, double K, double T, double sigma, double r, double q) {
    double d1 = D1(S, K, T, sigma, r, q);
    double vega = S * exp(-q * T) * Normal.pdf(d1) * sqrt(T);
    return vega / 100;
  }

  /*double IV(OptionContractType optionType, double S, double K, double T, double r, double q, double optionMarketPrice)
        {
            Function<double, double> f = sigma => Premium(optionType, S, K, T, sigma, r, q) - optionMarketPrice;
            Function<double, double> df = sigma => Vega(S, K, T, sigma, r, q);

            return RobustNewtonRaphson.FindRoot(f, df, lowerBound: 0, upperBound: 100, accuracy: 0.001);
            NewtonsMethod
        }*/

  /// <summary>
  /// Computes theta.
  /// </summary>
  /// <param name="optionType">call or put</param>
  /// <param name="S">Underlying price</param>
  /// <param name="K">Strike price</param>
  /// <param name="T">Time to expiration in % of year</param>
  /// <param name="sigma">Volatility</param>
  /// <param name="r">continuously compounded risk-free interest rate</param>
  /// <param name="q">continuously compounded dividend yield</param>
  /// <returns></returns>
  double Theta(OptionContractType optionType, double S, double K, double T,
      double sigma, double r, double q) {
    double d1 = D1(S, K, T, sigma, r, q);
    double d2 = D2(T, sigma, d1);

    switch (optionType) {
      case OptionContractType.Call:
        {
          double theta =
              -exp(-q * T) * (S * Normal.pdf(d1) * sigma) / (2.0 * sqrt(T)) -
                  (r * K * exp(-r * T) * Normal.cdf(d2)) +
                  q * S * exp(-q * T) * Normal.cdf(d1);

          return theta / 365;
        }

      case OptionContractType.Put:
        {
          double theta =
              -exp(-q * T) * (S * Normal.pdf(d1) * sigma) / (2.0 * sqrt(T)) +
                  (r * K * exp(-r * T) * Normal.pdf(-d2)) -
                  q * S * exp(-q * T) * Normal.cdf(-d1);

          return theta / 365;
        }

      default:
        throw Exception('Theta Exception');
    }
  }

  /// <summary>
  /// Computes delta.
  /// </summary>
  /// <param name="optionType">call or put</param>
  /// <param name="S">Underlying price</param>
  /// <param name="K">Strike price</param>
  /// <param name="T">Time to expiration in % of year</param>
  /// <param name="sigma">Volatility</param>
  /// <param name="r">continuously compounded risk-free interest rate</param>
  /// <param name="q">continuously compounded dividend yield</param>
  /// <returns></returns>
  double Delta(OptionContractType optionType, double S, double K, double T,
      double sigma, double r, double q) {
    double d1 = D1(S, K, T, sigma, r, q);

    switch (optionType) {
      case OptionContractType.Call:
        return exp(-r * T) * Normal.cdf(d1);

      case OptionContractType.Put:
        return -exp(-r * T) * Normal.cdf(-d1);

      default:
        throw Exception('Delta Exception');
    }
  }

  /// <summary>
  /// Computes gamma.
  /// </summary>
  /// <param name="S">Underlying price</param>
  /// <param name="K">Strike price</param>
  /// <param name="T">Time to expiration in % of year</param>
  /// <param name="sigma">Volatility</param>
  /// <param name="r">continuously compounded risk-free interest rate</param>
  /// <param name="q">continuously compounded dividend yield</param>
  /// <returns></returns>
  double Gamma(double S, double K, double T, double sigma, double r, double q) {
    double d1 = D1(S, K, T, sigma, r, q);
    return exp(-q * T) * (Normal.pdf(d1) / (S * sigma * sqrt(T)));
  }

  /// <summary>
  /// Computes delta.
  /// </summary>
  /// <param name="optionType">call or put</param>
  /// <param name="S">Underlying price</param>
  /// <param name="K">Strike price</param>
  /// <param name="T">Time to expiration in % of year</param>
  /// <param name="sigma">Volatility</param>
  /// <param name="r">continuously compounded risk-free interest rate</param>
  /// <param name="q">continuously compounded dividend yield</param>
  /// <returns></returns>
  double Rho(OptionContractType optionType, double S, double K, double T,
      double sigma, double r, double q) {
    double d1 = D1(S, K, T, sigma, r, q);
    double d2 = D2(T, sigma, d1);

    switch (optionType) {
      case OptionContractType.Call:
        return K * T * exp(-r * T) * Normal.cdf(d2);

      case OptionContractType.Put:
        return -K * T * exp(-r * T) * Normal.cdf(-d2);

      default:
        throw Exception('Rho');
    }
  }
}
