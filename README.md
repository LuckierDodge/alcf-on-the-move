# alcf_on_the_move

An on-the-go, cross-platform app for monitoring ALCF compute resources.

## Getting Started

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

## Topography

* main.dart: Entry point for the app, launches straight into the Dashboard page
* dashboard.dart: Main page for the app, contains the list of machines and buttons to navigate to other pages
    * status.dart: custom widget that displays the usage of each machine. Tap to display additional info
        * mapvisualization.dart: displays a collapsible representation of the map visualization
        * joblist.dart: lists all the running and queued jobs, as well as reservations.
    * settings.dart: manage settings for the app, accessed by gear icon
    * newspage.dart: scrapes https://alcf.anl.gov and displays a list of news articles
        * alcfscraper.dart: used by the news page to scrape the website
    * utils.dart: contains functions and classes used in multiple widgets
* activity.dart: JSON deserializer for status.alcf.anl.gov/<machinename>/activity.json,
includes the fetchActivity function
    * activity.g.dart: generated function created from activity.dart
        * Build using: flutter pub run build_runner build