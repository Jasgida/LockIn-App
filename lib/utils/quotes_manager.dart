import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote.dart';

class QuotesManager {
  static const _prefsDate = 'quotes_date';
  static const _prefsAm = 'quotes_am_index';
  static const _prefsPm = 'quotes_pm_index';

  /// Load all quotes from assets/quotes.json
  static Future<List<Quote>> _loadQuotes() async {
    final String response = await rootBundle.loadString('assets/quotes.json');
    final List<dynamic> data = json.decode(response);
    return data.map((e) => Quote.fromJson(e)).toList();
  }

  /// Ensure we have 2 random quotes saved for today (AM + PM)
  static Future<void> ensureQuotesForToday() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _dateString(DateTime.now());
    final storedDate = prefs.getString(_prefsDate);

    // Already set for today — nothing to do
    if (storedDate == todayStr) return;

    final quotes = await _loadQuotes();
    if (quotes.isEmpty) return;

    final rng = Random();
    final total = quotes.length;

    int am = rng.nextInt(total);
    int pm = rng.nextInt(total);
    while (pm == am && total > 1) {
      pm = rng.nextInt(total);
    }

    await prefs.setString(_prefsDate, todayStr);
    await prefs.setInt(_prefsAm, am);
    await prefs.setInt(_prefsPm, pm);
  }

  /// Return the correct quote depending on time (AM or PM)
  static Future<Quote> getQuoteForNow() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _dateString(DateTime.now());
    final storedDate = prefs.getString(_prefsDate);

    if (storedDate != todayStr) {
      await ensureQuotesForToday();
    }

    final quotes = await _loadQuotes();
    if (quotes.isEmpty) {
      return Quote(author: 'Unknown', quote: '');
    }

    final hour = DateTime.now().hour;
    final amIndex = prefs.getInt(_prefsAm) ?? 0;
    final pmIndex = prefs.getInt(_prefsPm) ?? 0;

    final index = (hour < 12) ? amIndex : pmIndex;
    return quotes[index % quotes.length];
  }

  static String _dateString(DateTime d) => '${d.year}-${d.month}-${d.day}';
}
