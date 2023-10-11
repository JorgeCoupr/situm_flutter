part of wayfinding;

// Public definitions:

/// The [MapView] settings.
///
/// ```dart
/// MapView(
///   key: const Key("situm_map"),
///   configuration: MapViewConfiguration(
///   // Your Situm credentials.
///     situmUser: "YOUR-SITUM-USER",
///     situmApiKey: "YOUR-SITUM-API-KEY",
///   // Set your building identifier:
///     buildingIdentifier: "YOUR-SITUM-BUILDING-IDENTIFIER",
///   // Alternatively, you can set an identifier that allows you to remotely configure all map settings.
///   // For now, you need to contact Situm to obtain yours.
///   // remoteIdentifier: null;
///     viewerDomain: "map-viewer.situm.com",
///     apiDomain: "dashboard.situm.com",
///     directionality: TextDirection.ltr,
///     enableDebugging: false,
///   ),
/// ),
/// ```
class MapViewConfiguration {
  /// Your Situm user.
  final String? situmUser;

  /// Your Situm API key.
  final String situmApiKey;

  /// The building that will be loaded on the map. Alternatively you can pass a
  /// remoteIdentifier (that will be prioritized).
  final String? buildingIdentifier;

  /// A String identifier that allows you to remotely configure all map settings.
  /// Alternatively you can pass a buildingIdentifier, remoteIdentifier
  /// will be prioritized.
  final String? remoteIdentifier;

  /// A String parameter that allows you to specify
  /// which domain will be displayed inside our webview.
  ///
  /// Default is [map-viewer.situm.com] (https://map-viewer.situm.com).
  ///
  ///[viewerDomain] should include only the domain (e.g., "map-viewer.situm.com").
  late final String viewerDomain;

  /// A String parameter that allows you to choose the API you will be retrieving
  /// our cartography from. Default is [dashboard.situm.com](https://dashboard.situm.com).
  ///
  /// [apiDomain] should include only the domain (e.g., "dashboard.situm.com").
  /// * **Note**: When using [SitumSdk.setDashboardURL], make sure you introduce the same domain.
  final String apiDomain;

  /// Sets the directionality of the texts that will be displayed inside [MapView].
  /// Default is [TextDirection.ltr].
  final TextDirection directionality;

  /// Whether to enable the platform's webview content debugging tools.
  /// See [AndroidWebViewController.enableDebugging].
  ///
  /// Default is false.
  final bool enableDebugging;

  ///When set to true, the camera will be locked to the building so the user can't move it away
  ///
  /// Default is false.
  final bool? lockCameraToBuilding;

  /// The [MapView] settings. Required fields are your Situm user and API key,
  /// but also a buildingIdentifier or remoteIdentifier.
  MapViewConfiguration({
    this.situmUser,
    required this.situmApiKey,
    this.buildingIdentifier,
    this.remoteIdentifier,
    String? viewerDomain,
    this.apiDomain = "dashboard.situm.com",
    this.directionality = TextDirection.ltr,
    this.enableDebugging = false,
    this.lockCameraToBuilding,
  }) {
    if (viewerDomain != null) {
      if (!viewerDomain.startsWith("https://") &&
          !viewerDomain.startsWith("http://")) {
        viewerDomain = "https://$viewerDomain";
      }
      if (viewerDomain.endsWith("/")) {
        viewerDomain = viewerDomain.substring(0, viewerDomain.length - 1);
      }
      this.viewerDomain = viewerDomain;
    } else {
      this.viewerDomain = "https://map-viewer.situm.com";
    }
  }

  String get _internalApiDomain {
    String finalApiDomain = apiDomain.replaceFirst(RegExp(r'https://'), '');

    if (finalApiDomain.endsWith('/')) {
      finalApiDomain = finalApiDomain.substring(0, finalApiDomain.length - 1);
    }

    return finalApiDomain;
  }

  String _getViewerURL() {
    var base = viewerDomain;
    var query = "apikey=$situmApiKey&domain=$_internalApiDomain&mode=embed";
    if (lockCameraToBuilding != null) {
      query = "$query&lockCameraToBuilding=$lockCameraToBuilding";
    }

    if (remoteIdentifier?.isNotEmpty == true &&
        buildingIdentifier?.isNotEmpty == true) {
      return "$base/id/$remoteIdentifier?$query&buildingid=$buildingIdentifier";
    } else if (remoteIdentifier?.isNotEmpty == true) {
      return "$base/id/$remoteIdentifier?$query";
    } else if (buildingIdentifier?.isNotEmpty == true) {
      return "$base/?$query&buildingid=$buildingIdentifier";
    }
    throw ArgumentError(
        'Missing configuration: remoteIdentifier or buildingIdentifier must be provided.');
  }
}

class DirectionsMessage {
  static const EMPTY_ID = "-1";

  // Identifier used by the map-viewer on the pre-route UI, where multiple
  // routes are calculated asynchronously.
  String? identifier;
  final String buildingIdentifier;
  final String originCategory;
  final String originIdentifier;
  final String destinationCategory;
  final String destinationIdentifier;
  final AccessibilityMode? accessibilityMode;

  DirectionsMessage({
    required this.buildingIdentifier,
    required this.originCategory,
    this.originIdentifier = EMPTY_ID,
    required this.destinationCategory,
    this.destinationIdentifier = EMPTY_ID,
    this.identifier,
    this.accessibilityMode,
  });
}

class OnPoiSelectedResult {
  final Poi poi;

  const OnPoiSelectedResult({
    required this.poi,
  });
}

class OnPoiDeselectedResult {
  final Poi poi;

  const OnPoiDeselectedResult({
    required this.poi,
  });
}

// Result callbacks.

// WYF load callback.
typedef MapViewCallback = void Function(MapViewController controller);
// POI selection callback.
typedef OnPoiSelectedCallback = void Function(
    OnPoiSelectedResult poiSelectedResult);
// POI deselection callback.
typedef OnPoiDeselectedCallback = void Function(
    OnPoiDeselectedResult poiDeselectedResult);
// Directions and navigation interceptor.
typedef OnDirectionsRequestInterceptor = void Function(
    DirectionsRequest directionsRequest);
typedef OnNavigationRequestInterceptor = void Function(
    NavigationRequest navigationRequest);

// Connection errors
class ConnectionErrors {
  static const ANDROID_NO_CONNECTION = -2;
  static const ANDROID_SOCKET_NOT_CONNECTED = -6;
  static const IOS_NO_CONNECTION = -1009;
  static const IOS_HOSTNAME_NOT_RESOLVED = -1003;

  static const List<int> values = [
    ANDROID_NO_CONNECTION,
    ANDROID_SOCKET_NOT_CONNECTED,
    IOS_NO_CONNECTION,
    IOS_HOSTNAME_NOT_RESOLVED
  ];
}
